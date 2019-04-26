import UIKit

class ViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    func setupView() {
        title = "Camera App"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
