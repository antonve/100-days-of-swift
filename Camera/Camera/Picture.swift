import Foundation
import UIKit

struct Picture: Codable {
    let imageName: String
    let caption: String
}

extension Picture {
    var image: UIImage {
        let image = getDocumentsDirectory().appendingPathComponent(imageName)
        return UIImage(contentsOfFile: image.path)!
    }
}
