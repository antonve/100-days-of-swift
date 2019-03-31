import UIKit

class ViewController: UIViewController {
    
    let views = [
        "label1": createLabel(text: "THESE", backgroundColor: .red),
        "label2": createLabel(text: "ARE", backgroundColor: .cyan),
        "label3": createLabel(text: "SOME", backgroundColor: .yellow),
        "label4": createLabel(text: "AWESOME", backgroundColor: .green),
        "label5": createLabel(text: "LABELS", backgroundColor: .orange),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for label in views.values {
            view.addSubview(label)
        }
//
//        for label in views.keys {
//            view.addConstraints(NSLayoutConstraint.constraints(
//                withVisualFormat: "H:|[\(label)]|",
//                options: [],
//                metrics: nil,
//                views: views
//            ))
//        }
//
//        let metrics = [
//            "labelHeight": 88,
//        ]
//
//        view.addConstraints(NSLayoutConstraint.constraints(
//            withVisualFormat: "V:|[label1(labelHeight@999)]-[label2(label1)]-[label3(label1)]-[label4(label1)]-[label5(label1)]-(>=10)-|",
//            options: [],
//            metrics: metrics,
//            views: views
//        ))
        
        var previousLabel: UILabel?
        
        for label in views.values {
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
            label.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.2, constant: -10) .isActive = true
            
            if let prev = previousLabel {
                label.topAnchor.constraint(equalTo: prev.bottomAnchor, constant: 10).isActive = true
            } else {
                label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
            }
            
            previousLabel = label
        }
    }

    static func createLabel(text: String, backgroundColor: UIColor) -> UILabel {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        label.backgroundColor = backgroundColor
        label.sizeToFit()
        
        return label
    }
}

