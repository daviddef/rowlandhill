import Foundation
import SwiftUI

// MARK: - Core Stamp Model
// Mirrors the PostgreSQL `stamps` table + joined data from issuers, valuations, catalogue_references

struct Stamp: Identifiable, Codable, Hashable {
    // Identity
    let id: Int
    let stampID: String          // StampID: "SID-GB-1840-0001"
    let uuid: UUID

    // Classification
    let issuer: Issuer
    let series: Series?
    let format: StampFormat

    // Issue details
    let issueDate: String?       // ISO 8601 or "circa YYYY"
    let issueYear: Int?
    let denomination: Double?
    let currency: String?
    let denominationText: String? // "2d", "5 Pf", "XXIV Kreuzer"
    let colour: [String]

    // Physical characteristics
    let printMethod: PrintMethod?
    let perforationType: PerforationType?
    let perfGaugeH: Double?
    let perfGaugeV: Double?
    let watermark: String?
    let paperType: String?

    // Design
    let subject: String?
    let description: String?     // AI-generated, human-reviewed
    let designer: String?
    let engraver: String?
    let printer: String?

    // Thematic
    let topics: [String]

    // Cross-catalogue refs (populated on detail fetch)
    var catalogueRefs: [CatalogueRef]

    // Images
    var primaryImageURL: URL?
    var thumbnailURL: URL?

    // Valuations (only loaded for Pro subscribers)
    var valuation: StampValuation?

    // Data quality
    let sourceTier: DataSourceTier
    let confidence: Double

    // MARK: Computed helpers
    var displayName: String { subject ?? stampID }
    var formattedDenomination: String { denominationText ?? (denomination.map { String($0) } ?? "—") }
    var formattedDate: String { issueDate ?? (issueYear.map { String($0) } ?? "Unknown") }

    // CodingKeys to map snake_case API to camelCase
    enum CodingKeys: String, CodingKey {
        case id, uuid, issuer, series, format
        case stampID = "stamp_id"
        case issueDate = "issue_date"
        case issueYear = "issue_year"
        case denomination, currency
        case denominationText = "denomination_text"
        case colour
        case printMethod = "print_method"
        case perforationType = "perforation_type"
        case perfGaugeH = "perf_gauge_h"
        case perfGaugeV = "perf_gauge_v"
        case watermark
        case paperType = "paper_type"
        case subject, description, designer, engraver, printer, topics
        case catalogueRefs = "catalogue_refs"
        case primaryImageURL = "primary_image_url"
        case thumbnailURL = "thumbnail_url"
        case valuation
        case sourceTier = "source_tier"
        case confidence
    }
}

// MARK: - Supporting Types

struct Issuer: Codable, Hashable {
    let id: Int
    let name: String
    let countryISO: String?
    let countryName: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case countryISO = "country_iso"
        case countryName = "country_name"
    }
}

struct Series: Codable, Hashable {
    let id: Int
    let name: String
    let issueDate: String?
    let printer: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case issueDate = "issue_date"
        case printer
    }
}

struct CatalogueRef: Codable, Hashable, Identifiable {
    var id: String { "\(catalogue)-\(number)" }
    let catalogue: String        // "scott", "sg", "michel" etc.
    let catalogueName: String
    let number: String
    let isPrimary: Bool
    let confirmed: Bool

    enum CodingKeys: String, CodingKey {
        case catalogue
        case catalogueName = "catalogue_name"
        case number
        case isPrimary = "is_primary"
        case confirmed
    }
}

struct StampValuation: Codable, Hashable {
    let mintTypical: Double?
    let mintMin: Double?
    let mintMax: Double?
    let usedTypical: Double?
    let usedMin: Double?
    let usedMax: Double?
    let currency: String
    let sourceType: String       // "auction_realised" | "catalogue_value"
    let asOf: String?

    enum CodingKeys: String, CodingKey {
        case mintTypical = "mint_typical"
        case mintMin = "mint_min"
        case mintMax = "mint_max"
        case usedTypical = "used_typical"
        case usedMin = "used_min"
        case usedMax = "used_max"
        case currency
        case sourceType = "source_type"
        case asOf = "as_of"
    }

    var mintDisplayPrice: String {
        guard let price = mintTypical else { return "—" }
        return "$\(Int(price))"
    }

    var usedDisplayPrice: String {
        guard let price = usedTypical else { return "—" }
        return "$\(Int(price))"
    }
}

// MARK: - Enums

enum StampFormat: String, Codable, CaseIterable {
    case stamp, minisheet, bookletPane = "booklet_pane", coil, imperforate
    case revenue, airmail, postageDue = "postage_due", official, cinderella
    case error, proof, firstDayCover = "first_day_cover"

    var displayName: String {
        switch self {
        case .stamp:          return "Stamp"
        case .minisheet:      return "Mini Sheet"
        case .bookletPane:    return "Booklet Pane"
        case .coil:           return "Coil"
        case .imperforate:    return "Imperforate"
        case .revenue:        return "Revenue"
        case .airmail:        return "Airmail"
        case .postageDue:     return "Postage Due"
        case .official:       return "Official"
        case .cinderella:     return "Cinderella"
        case .error:          return "Error / EFO"
        case .proof:          return "Proof"
        case .firstDayCover:  return "First Day Cover"
        }
    }
}

enum PrintMethod: String, Codable {
    case lithography, recessEngraving = "recess_engraving", typography
    case photogravure, offset, letterpress, embossed, digital, mixed, unknown
}

enum PerforationType: String, Codable {
    case line, comb, harrow, serpentine, rouletted, imperforate, syncopated
}

enum DataSourceTier: String, Codable {
    case official, licensed, contributed, scraped, aiExtracted = "ai_extracted"

    var badge: String {
        switch self {
        case .official:    return "✓ Official"
        case .licensed:    return "✓ Licensed"
        case .contributed: return "Community"
        case .scraped:     return "Imported"
        case .aiExtracted: return "AI"
        }
    }
}

// MARK: - Collection Item

struct CollectionItem: Identifiable, Codable {
    let id: Int
    let stamp: Stamp
    var condition: Condition
    var isUsed: Bool
    var quantity: Int
    var purchasePrice: Double?
    var purchaseDate: Date?
    var notes: String?
    var userImageURL: URL?

    enum Condition: String, Codable, CaseIterable {
        case superb, vf, fine, vg, good, fair, poor

        var displayName: String { rawValue.uppercased() }
        var numericScore: Int {
            switch self {
            case .superb: return 100; case .vf: return 85; case .fine: return 70
            case .vg: return 55; case .good: return 40; case .fair: return 25; case .poor: return 10
            }
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, stamp, condition, quantity, notes
        case isUsed = "is_used"
        case purchasePrice = "purchase_price"
        case purchaseDate = "purchase_date"
        case userImageURL = "user_image_url"
    }
}

// MARK: - Scan Result

struct ScanResult {
    let stamp: Stamp
    let confidence: Double
    let topCandidates: [(stamp: Stamp, score: Double)]

    var confidenceLabel: String {
        switch confidence {
        case 0.9...:  return "High confidence"
        case 0.7..<0.9: return "Good match"
        case 0.5..<0.7: return "Possible match"
        default:      return "Low confidence"
        }
    }

    var confidenceColor: Color {
        switch confidence {
        case 0.9...:  return .green
        case 0.7..<0.9: return .yellow
        default:      return .orange
        }
    }
}
