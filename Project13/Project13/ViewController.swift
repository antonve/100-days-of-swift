import UIKit

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var intensity: UISlider!
    var currentImage: UIImage!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Instafilter"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(importPicture))
    }

    @objc func importPicture() {
       let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    @IBAction func changeFilter(_ sender: Any) {
    }

    @IBAction func save(_ sender: Any) {
    }

    @IBAction func intensityChanged(_ sender: Any) {
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        dismiss(animated: true)

        currentImage = image
    }
}
