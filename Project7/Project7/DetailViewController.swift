import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var petition: Petition?
    
    override func loadView() {
        super.loadView()
        
        webView = WKWebView()
        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let petition = petition else { return }
        let html = """
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://fonts.googleapis.com/css?family=Molengo|Tinos" rel="stylesheet">
        <style>
            body { font-size: 100%; background-color: #010101;}
            h1 { font-family: font-family: 'Tinos', serif; color: #eeeeee; }
            p { font-family: 'Molengo', sans-serif; color: #eeeeee; }
        </style>
        </head>
        <body>
        <h1>\(petition.title)</h1>
        <p>\(petition.body)</p>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
        
        title = petition.title
    }
}
