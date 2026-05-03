import Foundation
import Observation
import UIKit

@Observable
final class UploadViewModel {
    var selectedImage: UIImage?
    var isAnalyzing = false
    var errorMessage: String?
    var detectedItems: [DetectedItem] = []
    var showConfirmation = false

    private let recognizer = ImageRecognitionService.shared

    func analyze() async {
        guard let image = selectedImage else { return }
        isAnalyzing = true
        errorMessage = nil
        do {
            detectedItems = try await recognizer.analyze(image: image)
            showConfirmation = !detectedItems.isEmpty
        } catch {
            errorMessage = error.localizedDescription
        }
        isAnalyzing = false
    }

    func reset() {
        selectedImage = nil
        detectedItems = []
        showConfirmation = false
        errorMessage = nil
    }
}
