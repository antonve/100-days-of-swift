import UIKit

class ViewController: UITableViewController {
    var pictures: [Picture] = [Picture]()
    let cellIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        title = "Camera App"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(startCamera))
    }

    @objc func startCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true

        present(vc, animated: true)
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else { fatalError() }
        cell.textLabel?.text = pictures[indexPath.row].caption

        let data = try! Data(contentsOf: pictures[indexPath.row].url)
        cell.imageView?.image = UIImage(data: data)

        return cell
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        guard let url = saveImage(image) else { return }

        let picture = Picture(url: url, caption: "N/A")

        pictures.insert(picture, at: 0)
        tableView.performBatchUpdates({ [weak self] in
            self?.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        })

        dismiss(animated: true)
    }

    private func saveImage(_ image: UIImage) -> URL? {
        let name = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(name)

        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }

        do {
            try data.write(to: imagePath)
        } catch {
            return nil
        }

        return imagePath
    }

    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
