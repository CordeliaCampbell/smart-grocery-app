import Foundation

/// Item detected by the Vision API from an uploaded photo.
struct DetectedItem: Codable, Identifiable {
    let id = UUID()
    let name: String
    let category: String
    let confidence: Double

    enum CodingKeys: String, CodingKey {
        case name, category, confidence
    }
}

struct ImageAnalysisResponse: Decodable {
    let detectedItems: [DetectedItem]
    let imageId: Int

    enum CodingKeys: String, CodingKey {
        case detectedItems = "detected_items"
        case imageId       = "image_id"
    }
}
