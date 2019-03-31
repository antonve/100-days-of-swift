//
//  DetailViewController.swift
//  FlagsList
//
//  Created by Anton Van Eechaute on 3/16/19.
//  Copyright © 2019 Anton Van Eechaute. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var country: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let country = country else { return }
        
        title = country.uppercased()
        navigationItem.largeTitleDisplayMode = .never
        
        imageView.image = UIImage(named: country)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    }
    
    @objc func shareTapped() {
        guard let image = imageView.image else { return }
        guard let country = country else { return }
        
        let vc = UIActivityViewController(activityItems: [country, image], applicationActivities: nil)
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}
