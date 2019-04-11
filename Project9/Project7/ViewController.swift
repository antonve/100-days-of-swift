import UIKit
import Foundation

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    
    var searchTerm: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        

        DispatchQueue.global(qos: .userInitiated).async(execute: fetch)

        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits)),
            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(showSearch)),
        ]
    }

    func fetch() {
        let variation = (navigationController?.tabBarItem.tag ?? 0) + 1
        
        // let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        let urlString = "https://www.hackingwithswift.com/samples/petitions-\(variation).json"

        guard let url = URL(string: urlString) else { showError(); return }
        guard let data = try? Data(contentsOf: url) else { showError(); return }
        parse(json: data)
    }
    
    @objc func showSearch() {
        let ac = UIAlertController(title: "Search", message: nil, preferredStyle: .alert)
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems![0]
        ac.addTextField {
            $0.placeholder = "Searching for..."
        }
        
        ac.addAction(UIAlertAction(title: "Search", style: .default) { [weak self, weak ac] _ in
            guard let newSearchTerm = ac?.textFields?[0].text else {
                self?.searchTerm = nil
                return
            }
            
            if newSearchTerm == "" {
                self?.searchTerm = nil
            } else {
                self?.searchTerm = newSearchTerm
            }

            self?.refresh()
        })
        ac.addAction(UIAlertAction(title: "Nevermind", style: .default) { [weak self] _ in
            self?.searchTerm = nil
            self?.refresh()
        })
        
        present(ac, animated: true)
    }
    
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "The data provided in the app was kindly provided by We The People API of the Whitehouse", preferredStyle: .alert)
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItems![1]
        ac.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(ac, animated: true)
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        guard let jsonData = try? decoder.decode(Petitions.self, from: json) else { return }
        petitions = jsonData.results
        refresh()
    }
    
    func refresh() {
        if let searchTerm = searchTerm {
            title = "Petitions related to: \(searchTerm)"
        } else {
            title = nil
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.filterResults()

            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    
    func filterResults() {
        filteredPetitions = petitions.filter { [weak self] petition in
            guard let searchTerm = self?.searchTerm else { return true}
            
            if (petition.body.lowercased().contains(searchTerm) || petition.title.lowercased().contains(searchTerm)) {
                return true
            }
            
            return false
        }
    }
    
    func showError() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))

            self?.present(ac, animated: true)
        }
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPetitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = filteredPetitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.petition = filteredPetitions[indexPath.row]
        
        navigationController?.pushViewController(vc, animated: true)
    }
}
