import UIKit

class ViewController: UIViewController {
    let cluesLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24)
        label.text = "CLUES"
        label.numberOfLines = 0
        label.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        return label
    }()
    
    let answersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24)
        label.text = "ANSWERS"
        label.numberOfLines = 0
        label.textAlignment = .right
        label.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        return label
    }()
    
    let currentAnswer: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = UIFont.systemFont(ofSize: 44)
        textField.placeholder = "Tap letters to guess..."
        textField.isUserInteractionEnabled = false
        textField.textAlignment = .center
        return textField
    }()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.text = "Score: 0"
        return label
    }()
    
    let submitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("SUBMIT", for: .normal)
        return button
    }()
    
    let clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("CLEAR", for: .normal)
        return button
    }()
    
    let buttonsView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var letterButtons = [UIButton]()

    var activatedButtons = [UIButton]()
    var solutions = [String]()

    var score = 0
    var level = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupViewConstraints()
        
        setupButtons()
        setupInteraction()

        loadLevel()
    }
    
    func setupView() {
        view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(scoreLabel)
        view.addSubview(cluesLabel)
        view.addSubview(answersLabel)
        view.addSubview(currentAnswer)
        view.addSubview(submitButton)
        view.addSubview(clearButton)
        view.addSubview(buttonsView)
    }
    
    func setupViewConstraints() {
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            
            submitButton.heightAnchor.constraint(equalToConstant: 44),
            submitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submitButton.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            
            clearButton.heightAnchor.constraint(equalToConstant: 44),
            clearButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clearButton.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submitButton.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
        ])
    }
    
    func setupButtons() {
        let width = 150
        let height = 80
        
        for row in 0..<4 {
            for col in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                
                letterButton.setTitle("WWW", for: .normal)
                
                let frame = CGRect(x: col * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
            }
        }
    }

    func setupInteraction() {
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        clearButton.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)

        for button in letterButtons {
            button.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
        }
    }

    func loadLevel() {
        var clueString = ""
        var solutionString = ""
        var letterBits = [String]()

        guard let levelFileURL = Bundle.main.url(forResource: "level\(level)", withExtension: "txt") else { return }
        guard let levelContents = try? String(contentsOf: levelFileURL) else { return }

        let lines = levelContents.components(separatedBy: "\n").shuffled()

        for (index, line) in lines.enumerated() {
            let parts = line.components(separatedBy: ": ")
            let answer = parts[0]
            let clue = parts[1]

            clueString += "\(index + 1). \(clue)\n"

            let solutionWord = answer.replacingOccurrences(of: "|", with: "")
            solutionString += "\(solutionWord.count) characters \n"
            solutions.append(solutionWord)

            let bits = answer.components(separatedBy: "|")
            letterBits += bits
        }

        cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
        answersLabel.text = solutionString.trimmingCharacters(in: .whitespacesAndNewlines)

        letterBits.shuffle()

        guard letterBits.count == letterButtons.count else { return }

        for i in 0 ..< letterButtons.count {
            letterButtons[i].setTitle(letterBits[i], for: .normal)
            letterButtons[i].isHidden = false
        }
    }

    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return }

        currentAnswer.text = currentAnswer.text?.appending(buttonTitle)
        activatedButtons.append(sender)
        sender.isHidden = true
    }

    @objc func submitTapped() {
        guard let answerText = currentAnswer.text else { return }
        guard let solutionPosition = solutions.firstIndex(of: answerText) else { return }

        activatedButtons.removeAll()

        answersLabel.text = answersLabel
            .text?
            .components(separatedBy: "\n")
            .enumerated()
            .map { (index, text) in
                if index == solutionPosition {
                    return answerText
                }

                return text
            }
            .joined(separator: "\n")

        currentAnswer.text = ""

        increaseScore()
    }

    @objc func clearTapped() {
        currentAnswer.text = ""

        for button in activatedButtons {
            button.isHidden = false
        }

        activatedButtons.removeAll()
    }

    func increaseScore() {
        score += 1

        if score % 7 == 0 {
            let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
            present(ac, animated: true)
        }
    }

    func levelUp(action: UIAlertAction) {
        level += 1
        solutions.removeAll(keepingCapacity: true)

        loadLevel()
    }
}
