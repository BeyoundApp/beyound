//
//  HelperWebViewController.swift
//  Beyound
//
//  Created by Elder Santos on 07/03/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class HelperWebViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var webView: UIWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView.loadRequest(URLRequest(url: URL(string: "https://api.instagram.com/oauth/authorize/?client_id=a4af2fe2933c41e0ab2884c27d63247a&redirect_uri=http://www.beyound.com.br/&response_type=token")!))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        var urlString: String = request.url!.absoluteString
        
        var UrlPartsIfSuccess: [String] = urlString.components(separatedBy: "http://www.beyound.com.br/#access_token=")
        
        if UrlPartsIfSuccess.count > 1 {
            
            //salva o accessToken
            var accessToken = UrlPartsIfSuccess[1] as! String
            saveAccessToken(accessToken: accessToken)
            webView.stopLoading()
        }else{
            var UrlPartsIfError: [String] = urlString.components(separatedBy: "error")
            
            if UrlPartsIfError.count > 1 {
            
                //deu erro, provavelmente usuario negou acesso
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        return true;
    }

    func saveAccessToken(accessToken: String) {
        
        let defaults = UserDefaults.standard
        defaults.set(accessToken, forKey: "accessToken")
        
        self.performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    @IBAction func closeWebView(_ sender: Any) {
        
        //usuario fechou a webView
        self.dismiss(animated: true, completion: nil);
        
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
