import Foundation

// MARK: - StampScan API Client
//
// Base URL: https://api.stampscan.app/v1
// Auth: Bearer JWT (obtained via /auth/apple)
// All endpoints return JSON matching the Stamp model in Models/Stamp.swift

final class StampAPIClient {
    private let baseURL = URL(string: "https://api.stampscan.app/v1")!
    private let session: URLSession
    private var authToken: String? = nil

    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        config.waitsForConnectivity = true
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: config)
    }

    func setAuthToken(_ token: String) {
        self.authToken = token
    }

    // MARK: - Stamp Lookups

    /// GET /v1/stamps/{stampID}
    /// Fetch full stamp detail by StampID (e.g., "SID-GB-1840-0001")
    func fetchStamp(id stampID: String) async throws -> Stamp {
        try await get("/stamps/\(stampID)")
    }

    /// GET /v1/stamps/by-catalogue/{catalogue}/{number}
    /// Reverse lookup by catalogue number (e.g., catalogue: "sg", number: "1")
    func fetchStampByCatalogue(catalogue: String, number: String) async throws -> Stamp {
        try await get("/stamps/by-catalogue/\(catalogue)/\(number)")
    }

    // MARK: - Search

    /// GET /v1/search?q={query}&country={iso}&year_from={y}&year_to={y}&topic={topic}&page={n}
    func search(
        query: String,
        country: String? = nil,
        yearFrom: Int? = nil,
        yearTo: Int? = nil,
        topic: String? = nil,
        page: Int = 1,
        perPage: Int = 40
    ) async throws -> SearchResponse {
        var params: [String: String] = [
            "q": query,
            "page": String(page),
            "per_page": String(perPage),
        ]
        if let c = country  { params["country"] = c }
        if let y = yearFrom { params["year_from"] = String(y) }
        if let y = yearTo   { params["year_to"] = String(y) }
        if let t = topic    { params["topic"] = t }

        return try await get("/search", params: params)
    }

    /// POST /v1/stamps/search-by-embedding
    /// Vector similarity search (used for server-side fallback when on-device misses)
    func searchByEmbedding(_ embedding: [Float], topK: Int = 5) async throws -> [EmbeddingMatch] {
        struct Body: Encodable { let embedding: [Float]; let top_k: Int }
        struct Response: Decodable { let matches: [Match] }
        struct Match: Decodable { let stamp_id: String; let score: Double }

        let body = Body(embedding: embedding, top_k: topK)
        let response: Response = try await post("/stamps/search-by-embedding", body: body)
        return response.matches.map { EmbeddingMatch(stampID: $0.stamp_id, score: $0.score) }
    }

    // MARK: - Catalogue Translation

    /// POST /v1/stamps/translate-catalogue
    /// Bulk translate catalogue numbers to StampIDs
    func translateCatalogue(catalogue: String, numbers: [String]) async throws -> [CatalogueTranslation] {
        struct Body: Encodable { let catalogue: String; let numbers: [String] }
        struct Response: Decodable { let translations: [CatalogueTranslation] }

        let response: Response = try await post(
            "/stamps/translate-catalogue",
            body: Body(catalogue: catalogue, numbers: numbers)
        )
        return response.translations
    }

    // MARK: - Collection (requires auth)

    /// GET /v1/me/collection
    func fetchCollection() async throws -> [CollectionItem] {
        try await get("/me/collection")
    }

    /// POST /v1/me/collection
    func addToCollection(stampID: String, condition: CollectionItem.Condition, isUsed: Bool) async throws -> CollectionItem {
        struct Body: Encodable {
            let stamp_id: String
            let condition: String
            let is_used: Bool
        }
        return try await post("/me/collection", body: Body(stamp_id: stampID, condition: condition.rawValue, is_used: isUsed))
    }

    /// DELETE /v1/me/collection/{itemId}
    func removeFromCollection(itemId: Int) async throws {
        try await delete("/me/collection/\(itemId)")
    }

    // MARK: - Scan Logging

    /// POST /v1/scans — log a scan attempt for ML training data
    func logScan(
        imageKey: String?,
        matchedStampID: String?,
        confidence: Double,
        topCandidates: [(String, Double)],
        modelVersion: String,
        userConfirmed: Bool? = nil
    ) async throws {
        struct Body: Encodable {
            let image_s3_key: String?
            let matched_stamp_id: String?
            let confidence: Double
            let top_candidates: [[String: String]]
            let model_version: String
            let user_confirmed: Bool?
        }

        let candidatesEncoded = topCandidates.map { ["stamp_id": $0.0, "score": String($0.1)] }
        let body = Body(
            image_s3_key: imageKey,
            matched_stamp_id: matchedStampID,
            confidence: confidence,
            top_candidates: candidatesEncoded,
            model_version: modelVersion,
            user_confirmed: userConfirmed
        )
        try await post("/scans", body: body) as EmptyResponse
    }

    // MARK: - Auth

    /// POST /v1/auth/apple — exchange Apple ID token for StampScan JWT
    func authenticateWithApple(identityToken: String) async throws -> AuthResponse {
        struct Body: Encodable { let identity_token: String }
        return try await post("/auth/apple", body: Body(identity_token: identityToken))
    }

    // MARK: - Generic HTTP Helpers

    private func get<T: Decodable>(_ path: String, params: [String: String] = [:]) async throws -> T {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !params.isEmpty {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        addAuthHeader(to: &request)
        return try await perform(request)
    }

    @discardableResult
    private func post<B: Encodable, T: Decodable>(_ path: String, body: B) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        addAuthHeader(to: &request)
        return try await perform(request)
    }

    private func delete(_ path: String) async throws {
        var request = URLRequest(url: baseURL.appendingPathComponent(path))
        request.httpMethod = "DELETE"
        addAuthHeader(to: &request)
        let (_, response) = try await session.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 204 else {
            throw APIError.serverError(0)
        }
    }

    private func addAuthHeader(to request: inout URLRequest) {
        if let token = authToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        switch httpResponse.statusCode {
        case 200...299:
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        case 401:
            throw APIError.unauthorized
        case 402:
            throw APIError.subscriptionRequired
        case 404:
            throw APIError.notFound
        case 429:
            throw APIError.rateLimited
        default:
            throw APIError.serverError(httpResponse.statusCode)
        }
    }

    // MARK: - Response Types

    struct SearchResponse: Decodable {
        let stamps: [Stamp]
        let total: Int
        let page: Int
        let perPage: Int
        let totalPages: Int

        enum CodingKeys: String, CodingKey {
            case stamps, total, page
            case perPage = "per_page"
            case totalPages = "total_pages"
        }
    }

    struct CatalogueTranslation: Decodable {
        let catNumber: String
        let stampID: String?
        let confidence: Double

        enum CodingKeys: String, CodingKey {
            case catNumber = "cat_number"
            case stampID = "stamp_id"
            case confidence
        }
    }

    struct AuthResponse: Decodable {
        let token: String
        let userId: String
        let subscription: SubscriptionTier

        enum CodingKeys: String, CodingKey {
            case token
            case userId = "user_id"
            case subscription
        }
    }

    private struct EmptyResponse: Decodable {}

    // MARK: - Errors

    enum APIError: LocalizedError {
        case invalidResponse
        case unauthorized
        case subscriptionRequired
        case notFound
        case rateLimited
        case serverError(Int)

        var errorDescription: String? {
            switch self {
            case .invalidResponse:       return "Invalid server response"
            case .unauthorized:          return "Please sign in to continue"
            case .subscriptionRequired:  return "This feature requires StampScan Pro"
            case .notFound:              return "Stamp not found"
            case .rateLimited:           return "Too many requests — please wait a moment"
            case .serverError(let code): return "Server error (\(code))"
            }
        }
    }
}
