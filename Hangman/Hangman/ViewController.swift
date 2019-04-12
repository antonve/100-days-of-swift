import UIKit

class ViewController: UIViewController {
    @IBOutlet var wordLabel: UILabel!

    var words = [String]()
    var currentWord = ""
    var guessedLetters = [Character]()

    override func viewDidLoad() {
        super.viewDidLoad()

        loadWords()
    }

    func loadWords() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let url = Bundle.main.url(forResource: "words", withExtension: "txt") else { return }
            guard let words = try? String(contentsOf: url) else { return }

            self.words = words.components(separatedBy: "\n")
            self.loadNewWord()
        }
    }

    func loadNewWord() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let newWord = self.words.randomElement() else {
                self.showFinished();
                return
            }

            self.currentWord = newWord
            self.guessedLetters.removeAll(keepingCapacity: true)

            DispatchQueue.main.async(execute: self.updateWordLabel)
        }
    }

    func updateWordLabel() {
        wordLabel.text = Array(currentWord)
            .map { char in
                guessedLetters.contains(char) ? String(char) : "_"
            }
            .joined(separator: " ")
    }

    func showFinished() {
        // TODO: IMPLEMENT THIS
        print("finished")
    }
}
