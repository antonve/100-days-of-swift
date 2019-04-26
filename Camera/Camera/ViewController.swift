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

        return cell
    }
}
