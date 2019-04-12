import UIKit

class ViewController: UIViewController {
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var guessInput: UITextField!
    @IBOutlet var submitButton: UIButton!
    @IBOutlet var livesLabel: UILabel!

    var words = [String]()
    var currentWord = ""
    var guessedLetters = [String]()
    var lives = 0 {
        didSet {
            DispatchQueue.main.async {
                self.livesLabel.text = "Lives: \(self.lives)"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        loadWords()
    }

    func setupView() {
        guessInput.delegate = self
        title = "Hangman"
        navigationController?.navigationBar.prefersLargeTitles = true

        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
    }

    func loadWords() {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            guard let url = Bundle.main.url(forResource: "words", withExtension: "txt") else { return }
            guard let words = try? String(contentsOf: url) else { return }

            self.words = words.components(separatedBy: "\n")
            DispatchQueue.main.async(execute: self.loadNewWord)
        }
    }

    func loadNewWord() {
        guard let newWord = self.words.randomElement() else {
            showFinished();
            return
        }

        currentWord = newWord
        guessedLetters.removeAll(keepingCapacity: true)

        lives = currentWord.count

        updateWordLabel()
    }

    func updateWordLabel() {
        wordLabel.text = Array(currentWord)
            .map { char in
                let letter = String(char).uppercased()
                return guessedLetters.contains(letter) ? letter : "_"
            }
            .joined(separator: " ")
    }

    func showFinished() {
        let ac = UIAlertController(title: "Wow!", message: "You've managed to find all words!", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Play again", style: .default, handler: { [weak self] _ in
            self?.loadWords()
        }))
        present(ac, animated: true)
    }

    func die() {
        let ac = UIAlertController(title: "Aww, you've ran out of lives!", message: "The word we were looking for was \(currentWord)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Try again", style: .default, handler: { [weak self] _ in
            self?.loadWords()
        }))
        present(ac, animated: true)
    }

    @objc func submitTapped() {
        guard let character = guessInput.text?.uppercased()  else { return }
        guard character != "" else { return }

        guessInput.text = ""

        if guessedLetters.contains(character) {
            return
        }

        if !currentWord.uppercased().contains(character) {
            lives -= 1
        }

        if lives == 0 {
            die()
        }

        guessedLetters.append(character)
        updateWordLabel()

        if let text = wordLabel.text, !text.contains("_") {
            guessedLetters.removeAll(keepingCapacity: true)
            words.removeAll(where: { $0 == currentWord })
            loadNewWord()
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let text = textField.text else { return true }

        let newLength = text.count + string.count - range.length
        return newLength <= 1
    }
}
