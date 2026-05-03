import Foundation
import UIKit

final class ImageRecognitionService {
    static let shared = ImageRecognitionService()

    /// Uploads `image` to the API and returns detected items.
    func analyze(image: UIImage) async throws -> [DetectedItem] {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw APIError.networkError(URLError(.cannotDecodeContentData))
        }

        let endpoint = "\(APIService.baseURL)/images/analyze"
        guard let url = URL(string: endpoint) else { throw APIError.invalidURL }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "multipart/form-data; boundary=\(boundary)",
            forHTTPHeaderField: "Content-Type"
        )
        request.httpBody = buildMultipartBody(imageData: imageData, boundary: boundary)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError(URLError(.badServerResponse))
        }
        guard (200..<300).contains(http.statusCode) else {
            throw APIError.serverError(http.statusCode)
        }

        do {
            let result = try JSONDecoder().decode(ImageAnalysisResponse.self, from: data)
            return result.detectedItems
        } catch {
            throw APIError.decodingError(error)
        }
    }

    // MARK: - Private

    private func buildMultipartBody(imageData: Data, boundary: String) -> Data {
        var body = Data()
        let crlf = "\r\n"

        body.append("--\(boundary)\(crlf)".utf8Data)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\(crlf)".utf8Data)
        body.append("Content-Type: image/jpeg\(crlf)\(crlf)".utf8Data)
        body.append(imageData)
        body.append("\(crlf)--\(boundary)--\(crlf)".utf8Data)
        return body
    }
}

private extension String {
    var utf8Data: Data { Data(utf8) }
}
