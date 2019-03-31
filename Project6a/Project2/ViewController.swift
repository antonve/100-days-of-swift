import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var correctAnswer = 0
    var askedCount = 0
    var shuffledCountries = [String]()
    
    let countries = ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]
    var score = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        askQuestion()
    }
    
    func askQuestion() {
        askedCount += 1
        
        shuffledCountries = Array(countries.shuffled().prefix(3))
        correctAnswer = Int.random(in: 0...2)
        let correctCountry = shuffledCountries[correctAnswer].uppercased()
        title = "\(correctCountry) (score: \(score)/10)"
        
        for (index, button) in [button1, button2, button3].enumerated() {
            button?.setImage(UIImage(imageLiteralResourceName: shuffledCountries[index]), for: .normal)
        }
    }
    
    private func setupView() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(scoreButtonTapped))
        [button1, button2, button3].forEach {
            $0?.layer.borderWidth = 1
            $0?.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
    
    @objc func scoreButtonTapped() {
        let ac = UIAlertController(
            title: "Score",
            message: "Your score right now is \(score)/10",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: nil))
        
        present(ac, animated: true)
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        let isCorrect = sender.tag == correctAnswer
        
        if isCorrect {
            score += 1
        }
        
        if askedCount < 10 {
            nextRound(isCorrect: isCorrect, selectedCountry: shuffledCountries[sender.tag])
        } else {
            resetGame()
        }
    }
    
    private func nextRound(isCorrect: Bool, selectedCountry: String) {
        var title: String
        var message: String
        
        if isCorrect {
            title = "Correct"
            message = "Your score is \(score)"
        } else {
            title = "Wrong"
            message = "Oh no, that was the flag for \(selectedCountry)!"
        }
        
        let ac = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.askQuestion()
        })
        
        present(ac, animated: true)
    }
    
    private func resetGame() {
        let ac = UIAlertController(
            title: "Game over",
            message: "Your total score is \(score)",
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "Start a new game", style: .default) { [weak self] _ in
            self?.score = 0
            self?.askedCount = 0
            self?.askQuestion()
        })
        
        present(ac, animated: true)
    }
}
