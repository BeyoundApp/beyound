//
//  IndexInfluenciadorViewController.swift
//  beyound
//
//  Created by Daniela Pereira on 24/02/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class IndexInfluenciadorViewController: UIViewController {
    
    @IBAction func LogoutAction(_ sender: Any) {
        //do something with this logout button
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var perfil: UIImageView!{
        didSet{
            perfil.layer.cornerRadius = 45
            perfil.layer.masksToBounds = true
        }
    }
    
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
                let username = dataObject.value(forKey: "username") as! String
                let profile_picture = dataObject.value(forKey: "profile_picture") as! String
                let url = NSURL(string: profile_picture)!
                let profile = NSData(contentsOf: url as URL)
                
                self.nameLabel.text = name
                self.usernameLabel.text = "@" + username
                self.perfil.image = UIImage(data: profile as! Data)
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
