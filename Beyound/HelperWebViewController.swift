//
//  HelperWebViewController.swift
//  Beyound
//
//  Created by Elder Santos on 07/03/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

class HelperWebViewController: UIViewController,UIWebViewDelegate {
    
    @IBOutlet weak var buttonClose: UIButton!
    @IBOutlet weak var webView: UIWebView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "accessToken")
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
            loadUserData(accessToken: accessToken)
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
        
        if (Singleton.sharedInstance.getInfluenciador().value(forKey: "answered") as! Bool){
            self.performSegue(withIdentifier: "toProfile", sender: self)
        }else{
            self.performSegue(withIdentifier: "toQuestions", sender: self)
        }
    }
    
    @IBAction func closeWebView(_ sender: Any) {
        
        //usuario fechou a webView
        self.dismiss(animated: true, completion: nil);
        
    }
    
    func parseJson(response: Data, accessToken: String){
        
        do {
            if let jsonResult = try JSONSerialization.jsonObject(with: response, options: []) as? NSDictionary {
                
                let authService = AuthService()
                let dataObject = jsonResult.object(forKey: "data") as! NSDictionary
                
                let id = dataObject.value(forKey: "id") as! String
                
                loadPosts(uid:id)
                
                authService.findInfluenciador(uid: id){ (influenciador) -> () in

                    if (influenciador != nil){
                        Singleton.sharedInstance.setInfluenciador(influenciador: influenciador!)
                        self.saveAccessToken(accessToken: accessToken)
                    }else{
                        let name = dataObject.value(forKey: "full_name") as! String
                        
                        
                        let followers = (dataObject.object(forKey: "counts") as! NSDictionary).value(forKey: "followed_by") as! Int
                        let following = (dataObject.object(forKey: "counts") as! NSDictionary).value(forKey: "follows") as! Int
                        let media = (dataObject.object(forKey: "counts") as! NSDictionary).value(forKey: "media") as! Int
                        
                        let website = dataObject.value(forKey: "website") as! String
                        let biography = dataObject.value(forKey: "bio") as! String
                        
                        
                        let username = dataObject.value(forKey: "username") as! String
                        let profile_picture = dataObject.value(forKey: "profile_picture") as! String
                        let url = NSURL(string: profile_picture)!
                        let profile = NSData(contentsOf: url as URL)
                        
                        
                        let answered = false
                        
                        let result = authService.setInfluenciador(uid: id, username: username, fullName: name, followers: followers, following: following, biography: biography, website: website, mediaCount: media, pictureData: profile, answered: answered) as Bool
                        
                        if(result){
                            authService.findInfluenciador(uid: id){ (influenciador) -> () in
                            
                                if (influenciador != nil){
                                    
                                    Singleton.sharedInstance.setInfluenciador(influenciador: influenciador!)
                                    self.saveAccessToken(accessToken: accessToken)
                                    
                                }else{
                                    self.dismiss(animated: true, completion: nil)
                                }
                                
                            }
                        }else{
                            self.dismiss(animated: true, completion: nil)
                        }
                    }


                }
                
            }
        } catch let error as NSError {
            print(error.localizedDescription)
            self.dismiss(animated: true, completion: nil)
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
    
    
    func loadUserData(accessToken: String){
        
        
            var url = "https://api.instagram.com/v1/users/self/?access_token=" + accessToken
            
            var request = NSMutableURLRequest(url: NSURL(string: url) as! URL)
            var session = URLSession.shared
            request.httpMethod = "GET"
            
            
            var err: NSError?
            
            var task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
                
                var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                var err: NSError?
                self.parseJson(response: data!, accessToken: accessToken)
                
                
                
                
                if(err != nil) {
                    print(err!.localizedDescription)
                }
                
            })
            
            task.resume()
    }

    
}
