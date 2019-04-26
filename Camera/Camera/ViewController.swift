import UIKit

class ViewController: UITableViewController {
    var pictures: [Picture] = [Picture]()
    let cellIdentifier = "Cell"
    let storageKey = "pictures"

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        restore()
    }

    func setupView() {
        title = "Camera App"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(startCamera))
    }

    func restore() {
        let defaults = UserDefaults.standard
        let decoder = JSONDecoder()

        guard let data = defaults.object(forKey: storageKey) as? Data else { return }
        guard let pictures = try? decoder.decode([Picture].self, from: data) else { return }

        self.pictures = pictures
    }

    func save() {
        let defaults = UserDefaults.standard
        let encoder = JSONEncoder()

        guard let data = try? encoder.encode(pictures) else { return }
        defaults.set(data, forKey: storageKey)
    }

    @objc func startCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true

        present(vc, animated: true)
    }

    func addPicture(_ picture: Picture) {
        pictures.insert(picture, at: 0)
        tableView.performBatchUpdates({ [weak self] in
            self?.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        })

        save()
    }

    func updatePictureCaption(_ picture: Picture) {
        pictures = pictures.map { p in
            p.imageName == picture.imageName ? picture : p
        }
        tableView.reloadData()
        save()
    }

    func deletePicture(_ pictureIndex: Int) {
        pictures.remove(at: pictureIndex)
        tableView.reloadData()
        save()
    }

    func presentEditCaption(for picture: Picture) {
        let ac = UIAlertController(title: "Edit caption", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Save", style: .default) { [weak self, weak ac] _ in
            guard let self = self else { return }
            guard let caption = ac?.textFields?[0].text else { return }

            let newPicture = Picture(imageName: picture.imageName, caption: caption)
            self.updatePictureCaption(newPicture)
        })

        present(ac, animated: true)
    }

    func presentDeleteWarning(pictureIndex: Int) {
        let ac = UIAlertController(title: "Are you sure you want to delete this picture?", message: nil, preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.deletePicture(pictureIndex)
        })

        present(ac, animated: true)
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) else { fatalError() }
        cell.textLabel?.text = pictures[indexPath.row].caption

        cell.imageView?.image = pictures[indexPath.row].image

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PictureViewController(picture: pictures[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (_, _) in
            guard let self = self else { return }
            self.presentEditCaption(for: self.pictures[indexPath.row])
        }

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { [weak self] (_, _) in
            guard let self = self else { return }
            self.presentDeleteWarning(pictureIndex: indexPath.row)
        }

        edit.backgroundColor = .green

        return [edit, delete]
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        guard let imageName = saveImage(image) else { return }

        let picture = Picture(imageName: imageName, caption: "N/A")

        addPicture(picture)

        dismiss(animated: true)
    }

    private func saveImage(_ image: UIImage) -> String? {
        let name = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(name)

        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }

        do {
            try data.write(to: imagePath)
        } catch {
            return nil
        }

        return name
    }
}
