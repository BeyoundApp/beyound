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
                let id = dataObject.value(forKey: "id") as! String

                let followers = (dataObject.object(forKey: "counts") as! NSDictionary).value(forKey: "followed_by") as! Int
                let following = (dataObject.object(forKey: "counts") as! NSDictionary).value(forKey: "follows") as! Int
                let media = (dataObject.object(forKey: "counts") as! NSDictionary).value(forKey: "media") as! Int

                let website = dataObject.value(forKey: "website") as! String
                let biography = dataObject.value(forKey: "bio") as! String

                
                let username = dataObject.value(forKey: "username") as! String
                let profile_picture = dataObject.value(forKey: "profile_picture") as! String
                let url = NSURL(string: profile_picture)!
                let profile = NSData(contentsOf: url as URL)

                // Move to a background thread to do some long running work
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        self.nameLabel.text = name
                        self.usernameLabel.text = "@" + username
                        self.perfil.image = UIImage(data: profile as! Data)

                    }
                }
                
                
                var authService = AuthService()
                
                let result = authService.setInfluenciador(uid: id, username: username, fullName: name, followers: followers, following: following, biography: biography, website: website, mediaCount: media, pictureData: profile) as Bool
                
                if(result){
                    loadPosts(uid:id)
                }
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
    }
    
    func loadPosts(uid: String){
        let defaults = UserDefaults.standard
        if let accessToken = defaults.string(forKey: "accessToken"){
            var url = "https://api.instagram.com/v1/users/self/media/recent/?access_token=" + accessToken
            
            var request = NSMutableURLRequest(url: NSURL(string: url) as! URL)
            var session = URLSession.shared
            request.httpMethod = "GET"
            
            
            var err: NSError?
            
            var task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                var err: NSError?
                
                
               
                    self.parsePosts(response: data!, uid:uid)
                
                
                if(err != nil) {
                    print(err!.localizedDescription)
                }
                
            })
            
            task.resume()
            
            
        }

    }
    
    func parsePosts(response: Data, uid: String){
        
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: response, options: []) as? NSDictionary {
                
                var authService = AuthService()
                
                let dataObject = jsonResult.object(forKey: "data") as! NSArray
                
                for object in dataObject as! [NSDictionary]{
                    
                    let created_time = object.value(forKey: "created_time") as! String
                    var text = ""
                    
                    let caption = (object.value(forKey: "caption") as? NSDictionary)
                    
                    let likes = (object.value(forKey: "likes") as! NSDictionary).value(forKey: "count") as! Int
                    let link = object.value(forKey: "link") as! String
                    let comments = (object.value(forKey: "comments") as! NSDictionary).value(forKey: "count") as! Int
                    let id = object.value(forKey: "id") as! String

                    let location = object.value(forKey: "location") as? NSDictionary
                    
                    
                    let tags = object.value(forKey: "tags") as? NSArray
                    
                    
                    authService.savePost(uid: uid, createdTime: created_time, caption: caption, likes: likes, link: link, comments: comments, id: id, location:location, tags: tags)
                }
                
                
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
