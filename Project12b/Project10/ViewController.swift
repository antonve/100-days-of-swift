import UIKit

class ViewController: UICollectionViewController {
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()

        load()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Cannot deqeue person cell")
        }

        let person = people[indexPath.item]

        cell.nameLabel.text = person.name

        let image = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: image.path)

        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7

        return cell
    }

    @objc func addNewPerson() {
        let picker = UIImagePickerController()

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        }

        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]

        let ac = UIAlertController(title: "Do you want to rename this person?", message: nil, preferredStyle: .alert)

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "Yes", style: .default) { [weak self, weak person] _ in
            guard let person = person else { return }
            self?.renamePersonDialog(person)
        })

        present(ac, animated: true)
    }

    func renamePersonDialog(_ person: Person) {
        let ac = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
            guard let newName = ac?.textFields?[0].text else { return }
            person.name = newName

            self?.save()
            self?.collectionView.reloadData()
        })

        present(ac, animated: true)
    }

    func load() {
        let defaults = UserDefaults.standard
        guard let loadedPeople = defaults.object(forKey: "people") as? Data else { return }

        let decoder = JSONDecoder()
        guard let decodedPeople = try? decoder.decode([Person].self, from: loadedPeople) else { return }

        people = decodedPeople
    }

    func save() {
        let encoder = JSONEncoder()
        guard let encodedPeople = try? encoder.encode(people) else { return }

        let defaults = UserDefaults.standard
        defaults.set(encodedPeople, forKey: "people")
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }

        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)

        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }

        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        save()
        collectionView.reloadData()

        dismiss(animated: true)
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
