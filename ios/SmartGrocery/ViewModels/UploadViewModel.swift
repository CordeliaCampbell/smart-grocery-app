import Foundation
import Observation
import UIKit

@Observable
final class UploadViewModel {
    var selectedImage: UIImage?
    var isPreparing = false
    var errorMessage: String?
    var detectedItems: [DetectedItem] = []
    var showConfirmation = false


    func analyze() async {
        isPreparing = true
        errorMessage = nil
        detectedItems = [
            DetectedItem(name: "", category: "Other", confidence: 1.0)
        ]
        showConfirmation = true
        isPreparing = false
    }

    func reset() {
        selectedImage = nil
        detectedItems = []
        showConfirmation = false
        errorMessage = nil
    }
}
