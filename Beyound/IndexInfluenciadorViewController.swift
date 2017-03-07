//
//  IndexInfluenciadorViewController.swift
//  beyound
//
//  Created by Daniela Pereira on 24/02/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class IndexInfluenciadorViewController: UIViewController {
    
   // let instagram = Instagram(clientID: "a4af2fe2933c41e0ab2884c27d63247a", clientSecret: "cfe9a20495584620ba4524c9b5e65c35", redirectUri: "https://www.cloudrailauth.com/auth", state: "state")

    @IBAction func LogoutAction(_ sender: Any) {
        //do something with this logout button
    }
    
 @IBOutlet weak var usernameTextField: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserData()
        // Do any additional setup after loading the view.

    }
    
    func parseJson(response: Data){
        
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: response, options: []) as? NSDictionary {
                
                let dataObject = jsonResult.object(forKey: "data") as! NSDictionary
                
                let name = dataObject.value(forKey: "full_name") as! String
                
                print(name)

            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    func loadUserData(){
        
        let defaults = UserDefaults.standard
        if let accessToken = defaults.string(forKey: "accessToken"){
            var url = "https://api.instagram.com/v1/users/self/?access_token=" + accessToken

            var request = NSMutableURLRequest(url: NSURL(string: url) as! URL)
            var session = URLSession.shared
            request.httpMethod = "GET"
            
            
            var err: NSError?
            
            var task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                var err: NSError?
                
                self.parseJson(response: data!)
                
                if(err != nil) {
                    print(err!.localizedDescription)
                }
                
            })
            
            task.resume()
            
            
        }
        
        
    }

}
