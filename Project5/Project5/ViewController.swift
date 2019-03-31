import UIKit

class ViewController: UITableViewController {
    var allWords =  ["silkworm"]
    var usedWords = [String]()
    
    enum WordCheckResult {
        case correct
        case alreadyUsed
        case misspelled
        case incorrect
        case tooShort
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") else { return }
        guard let startWords = try? String(contentsOf: startWordsURL) else { return }
        
        let words = startWords.components(separatedBy: "\n")
        if words.count != 0 {
            allWords = words
        }
        
        startGame()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForAnswer))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(startGame))
    }
    

    @objc func startGame() {
        title = allWords.randomElement()
        usedWords.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    @objc func promptForAnswer() {
        let ac = UIAlertController(title: "Enter answer", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default) { [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        })
        
        present(ac, animated: true)
    }
    
    func submit(_ answer: String) {
        switch checkWord(answer) {
        case .tooShort:
            presentError(
                title: "Answser is too short",
                message: "Answer should be at least three characters"
            )
        case .alreadyUsed:
            presentError(
                title: "Word used already",
                message:  "Be more original!"
            )
        case .incorrect:
            guard let correctAnswer = title?.lowercased() else { return }
            presentError(
                title: "Word not possible",
                message:  "You can't spell that word from \(correctAnswer)"
            )
        case .misspelled:
            presentError(
                title: "Word not recognized",
                message:  "You can't just make them up, you know!"
            )
        case .correct:
            usedWords.insert(answer.lowercased(), at: 0)
            tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
    }
    
    func checkWord(_ answer: String) -> WordCheckResult {
        let word = answer.lowercased()
        
        guard isPossible(word: word) else { return .incorrect }
        guard isOriginal(word: word) else { return .alreadyUsed }
        guard isReal(word: word) else { return .misspelled }
        guard isLongEnough(word: word) else { return .tooShort }
        
        return .correct
    }
    
    func presentError(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try again", style: .default))
        
        present(ac, animated: true)
    }
    
    func isLongEnough(word: String) -> Bool {
        return word.count >= 3
    }
    
    func isPossible(word: String) -> Bool {
        guard var tempWord = title?.lowercased() else { return false }
        
        for letter in word {
            guard let index = tempWord.firstIndex(of: letter) else { return false }
            tempWord.remove(at: index)
        }
        
        return true
    }
    
    func isOriginal(word: String) -> Bool {
        return !usedWords.contains(word)
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
}

extension ViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usedWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Word", for: indexPath)
        cell.textLabel?.text = usedWords[indexPath.row]
        
        return cell
    }
}
