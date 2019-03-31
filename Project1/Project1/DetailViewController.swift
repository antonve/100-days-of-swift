import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var totalImages: Int?
    var selectedImagePosition: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let selectedImage = selectedImage else { return }
        imageView.image = UIImage(named: selectedImage)
        
        title = selectedImage
        
        navigationItem.largeTitleDisplayMode = .never
        
        guard let totalImages = totalImages else { return }
        guard let selectedImagePosition = selectedImagePosition else { return }
        title = "\(selectedImagePosition) of \(totalImages)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
}
