//
//  AddMoneyCCStep2ViewController.swift
//  ModernWallet
//
//  Created by Bozidar Nikolic on 6/29/17.
//  Copyright © 2017 Lykkex. All rights reserved.
//

import UIKit
import WalletCore
import WebKit

class AddMoneyCCStep2ViewController: UIViewController {
    
    var webView: WKWebView!
    var paymentUrl: LWPacketGetPaymentUrl?

    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let paymentUrl = self.paymentUrl else {return}
        guard let urlString = paymentUrl.urlString else {return}
        guard let url = URL(string: urlString) else {return}
        
        webView.load(URLRequest(url: url))
        
        // Do any additional setup after loading the view.
//        self.view.backgroundColor = UIColor.clear
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func submitAciton(_ sender: UIButton) {
        
//        let parentVC = self.parent as! LWAddMoneyViewController
//        parentVC.nextActionCCStep2()
    }
    
    @IBAction func dismissViewController(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddMoneyCCStep2ViewController: WKUIDelegate {
    
}
