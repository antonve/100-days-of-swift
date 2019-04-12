import UIKit

class ViewController: UIViewController {
    @IBOutlet var wordLabel: UILabel!
    @IBOutlet var guessInput: UITextField!
    @IBOutlet var submitButton: UIButton!

    var words = [String]()
    var currentWord = ""
    var guessedLetters = [String]()

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
                let letter = String(char).uppercased()
                return guessedLetters.contains(letter) ? letter : "_"
            }
            .joined(separator: " ")
    }

    func showFinished() {
        // TODO: IMPLEMENT THIS
        print("finished")
    }

    @objc func submitTapped() {
        guard let character = guessInput.text?.uppercased()  else { return }
        guessInput.text = ""

        if guessedLetters.contains(character) {
            return
        }

        guessedLetters.append(character)
        updateWordLabel()

        if let text = wordLabel.text, !text.contains("_") {
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
