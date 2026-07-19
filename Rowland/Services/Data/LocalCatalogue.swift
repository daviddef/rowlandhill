import Foundation
import SQLite3

/// The catalogue, shipped in the app bundle.
///
/// WHY THIS EXISTS. Browsing a catalogue does not need a server. Every network-backed screen in
/// this app pointed at `api.rowlandhill.app`, which has never been deployed — the domain isn't
/// even registered — so the Catalogue tab was a dead end that spun and then apologised.
///
/// The corpus is ~132k stamps of text: 31 MB as SQLite with an FTS5 index. That fits in the
/// bundle comfortably, searches in microseconds, works on a plane, and costs nothing per month.
/// It removes the domain, the API deployment and the hosting bill from the critical path for
/// the one feature that never needed them.
///
/// WHAT THIS IS NOT. Images are Wikimedia Commons URLs, so thumbnails still need a connection —
/// the text is local, the pictures are not. Identification is unaffected and still requires the
/// model and the server. This makes one tab work, not the product.
final class LocalCatalogue {
    static let shared = LocalCatalogue()

    private var db: OpaquePointer?
    private let queue = DispatchQueue(label: "app.rowlandhill.catalogue")

    /// Nil when the bundled database is missing, so callers can fall back to the API rather
    /// than crashing. Ship-time asset, but a failed copy shouldn't take the tab down.
    private(set) var isAvailable = false

    private init() {
        guard let path = Bundle.main.path(forResource: "catalogue", ofType: "sqlite") else {
            return
        }
        if sqlite3_open_v2(path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK {
            isAvailable = true
        }
    }

    // MARK: - Search

    /// Full-text search over country, subject and description, newest-known first.
    /// `query` may be empty, in which case this browses rather than searches.
    func search(query: String, country: String?, yearFrom: Int?, yearTo: Int?,
                page: Int, pageSize: Int = 40) -> [Stamp] {
        queue.sync {
            guard isAvailable else { return [] }

            var sql: String
            var binds: [String] = []
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            let isBrowse = trimmed.isEmpty || trimmed == "*"

            if isBrowse {
                sql = "SELECT stamp_id,country,year,subject,denom,image_url,description "
                    + "FROM stamps WHERE 1=1"
            } else {
                // FTS5 needs a sanitised query: bare punctuation is a syntax error, not a
                // no-match, and a thrown syntax error would read to the user as "no results".
                let terms = trimmed
                    .components(separatedBy: CharacterSet.alphanumerics.inverted)
                    .filter { !$0.isEmpty }
                guard !terms.isEmpty else { return [] }
                let match = terms.map { "\($0)*" }.joined(separator: " ")
                sql = "SELECT s.stamp_id,s.country,s.year,s.subject,s.denom,s.image_url,"
                    + "s.description FROM stamps_fts f JOIN stamps s ON s.stamp_id=f.stamp_id "
                    + "WHERE stamps_fts MATCH ?"
                binds.append(match)
            }

            if let c = country, !c.isEmpty {
                sql += isBrowse ? " AND country = ?" : " AND s.country = ?"
                binds.append(c)
            }
            if let y = yearFrom { sql += isBrowse ? " AND year >= \(y)" : " AND s.year >= \(y)" }
            if let y = yearTo { sql += isBrowse ? " AND year <= \(y)" : " AND s.year <= \(y)" }

            sql += " LIMIT \(pageSize) OFFSET \(max(0, page - 1) * pageSize)"

            var stmt: OpaquePointer?
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
            defer { sqlite3_finalize(stmt) }

            let transient = unsafeBitCast(-1, to: sqlite3_destructor_type.self)
            for (i, b) in binds.enumerated() {
                sqlite3_bind_text(stmt, Int32(i + 1), b, -1, transient)
            }

            var out: [Stamp] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                out.append(makeStamp(stmt))
            }
            return out
        }
    }

    /// Distinct country names, for the filter sheet. Cheap enough to call on demand.
    func countries() -> [String] {
        queue.sync {
            guard isAvailable else { return [] }
            var stmt: OpaquePointer?
            let sql = "SELECT DISTINCT country FROM stamps ORDER BY country"
            guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return [] }
            defer { sqlite3_finalize(stmt) }
            var out: [String] = []
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let c = sqlite3_column_text(stmt, 0) { out.append(String(cString: c)) }
            }
            return out
        }
    }

    func totalCount() -> Int {
        queue.sync {
            guard isAvailable else { return 0 }
            var stmt: OpaquePointer?
            guard sqlite3_prepare_v2(db, "SELECT COUNT(*) FROM stamps", -1, &stmt, nil)
                    == SQLITE_OK else { return 0 }
            defer { sqlite3_finalize(stmt) }
            return sqlite3_step(stmt) == SQLITE_ROW ? Int(sqlite3_column_int(stmt, 0)) : 0
        }
    }

    // MARK: - Row mapping

    private func text(_ stmt: OpaquePointer?, _ col: Int32) -> String? {
        guard let c = sqlite3_column_text(stmt, col) else { return nil }
        let s = String(cString: c)
        return s.isEmpty ? nil : s
    }

    private func makeStamp(_ stmt: OpaquePointer?) -> Stamp {
        let stampID = text(stmt, 0) ?? ""
        let country = text(stmt, 1) ?? "Unknown"
        let year = Int(sqlite3_column_int(stmt, 2))
        let imageURL = text(stmt, 5).flatMap(URL.init(string:))

        return Stamp(
            // Local rows have no server id. Hash the StampID so the value is stable across
            // launches — SwiftUI diffing and Hashable both depend on it not moving.
            id: abs(stampID.hashValue),
            stampID: stampID,
            uuid: UUID(),
            issuer: Issuer(id: 0, name: country, countryISO: nil, countryName: country),
            series: nil,
            format: .stamp,
            issueDate: nil,
            issueYear: year > 0 ? year : nil,
            denomination: nil,
            currency: nil,
            denominationText: text(stmt, 4),
            colour: [],
            printMethod: nil,
            perforationType: nil,
            perfGaugeH: nil,
            perfGaugeV: nil,
            watermark: nil,
            paperType: nil,
            subject: text(stmt, 3),
            description: text(stmt, 6),
            designer: nil,
            engraver: nil,
            printer: nil,
            topics: [],
            catalogueRefs: [],
            primaryImageURL: imageURL,
            thumbnailURL: imageURL,
            valuation: nil,
            // Image-tier, not catalogue-tier: an issuer, a year and a licensed image, but no
            // catalogue number. Saying so in the data keeps the UI honest about what it holds.
            sourceTier: .aiExtracted,
            confidence: 0.5
        )
    }
}
