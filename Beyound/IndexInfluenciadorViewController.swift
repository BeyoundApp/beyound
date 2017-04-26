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
    
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var postView: UIImageView!
    var questionGrade : Int?
    var didCameFromQuestionary : Bool!
    var arrayPosts : NSArray = []
    var dictWords : NSMutableDictionary = [:]
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var perfil: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         let influenciador = Singleton.sharedInstance.getInfluenciador()
        
         let name = influenciador.value(forKey: "full_name") as! String
         let username = influenciador.value(forKey: "username") as! String
         let followers = influenciador.value(forKey: "followers") as! Int
         let following = influenciador.value(forKey: "following") as! Int
         let url = NSURL(string: influenciador.value(forKey:"photoURL") as! String)!
         let profile = NSData(contentsOf: url as URL)
        
         self.nameLabel.text = name
         self.usernameLabel.text = "@" + username
        self.following.text = String(following)
         self.followerLabel.text = String(followers)
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.perfil.image = UIImage(data: profile as! Data)
            }
        }        //recalcula o seu ranking
        getPosts(){(completion) -> () in
            if(completion == nil){
                
                let postUrl = NSURL(string: ((((self.arrayPosts[0] as! NSDictionary).object(forKey: "images") as! NSDictionary).object(forKey: "standard_resolution") as! NSDictionary).value(forKey: "url") as! String))
                let firstPost = NSData(contentsOf: postUrl as! URL)
                
                DispatchQueue.global(qos: .background).async {
                    // Background Thread
                    DispatchQueue.main.async {
                        self.postView.image = UIImage(data: firstPost as! Data)
                    }
                }
               
                self.calculateScores()
            }
        }
        
    }
    
    func getPosts(completion: @escaping (Error?) -> ()){
        
        let influenciador = Singleton.sharedInstance.getInfluenciador() as NSDictionary
        let uid = influenciador.value(forKey: "uid") as! String
        
        let url = "https://tcc-beyound.firebaseio.com/influenciadores/"+uid+"/posts.json?print=pretty"
        
        let request = NSMutableURLRequest(url: NSURL(string: url) as! URL)
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        
        var err: NSError?
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)

            var err: NSError?
            
            do{
                
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSArray {
                    
                    self.arrayPosts = jsonResult
                    completion(nil)
                }
                
            }catch let error as NSError{
                completion(error)
                print(error)
            }
        })
        
        task.resume()
    }

    func calculateScores(){
        
        self.dictWords = NSMutableDictionary()
        
        let influenciador = Singleton.sharedInstance.getInfluenciador() as NSDictionary
        let uid = influenciador.value(forKey: "uid") as! String

        let jsonResult = self.arrayPosts
        
        let followers = Singleton.sharedInstance.getInfluenciador().value(forKey: "followers") as! Int
        let following = Singleton.sharedInstance.getInfluenciador().value(forKey: "following") as! Int
        
        let ffRatio = Double(followers)/Double(following) as Double
        
        //instancia o AuthService
        let authService = AuthService()
        
        //resultado do questionario
        var questionaryTotal = Int()
        if(self.didCameFromQuestionary == true){
            questionaryTotal = self.questionGrade!
            authService.updateInfluenciadorQuestionary(uid: uid, questionaryTotal: questionaryTotal, questionaryResult: Singleton.sharedInstance.getQuestionaryResult()){(completion) -> () in
                
            }
        }else{
            questionaryTotal = Singleton.sharedInstance.getInfluenciador().value(forKey: "questionaryTotal") as! Int
        }
        
        for item in jsonResult as! [NSDictionary] {
            
            var baseScore = questionaryTotal + Int(ffRatio*100) as Int

            //quantidade de likes desse post
            let count = (item.object(forKey: "likes") as! NSDictionary).value(forKey: "count") as! Int
            
            //numero comentarios
            let comments = (item.object(forKey: "comments") as! NSDictionary).value(forKey: "count") as! Int

            
            //verifica se o numero de likes alcançac o total de 1% de seguidores
            if (Double(count) > Double(followers)*0.01){
                //quantidade de hashtags do post
                var numberTags = 0 as Int
                let tags = (item.object(forKey: "tags") as? NSDictionary)
                if((tags) != nil){
                    numberTags = (tags?.count)!
                }
                
                let caption = item.object(forKey: "caption") as? NSDictionary
                
                //verifica se o post tem legenda
                if((caption) != nil){
                    
                    baseScore += count * 15 + numberTags * 10 + comments * 5
                    
                    //palavras da legenda desse post
                    let subtitle = caption?.value(forKey: "text") as! String
                    let components = subtitle.components(separatedBy: CharacterSet.init(charactersIn: " ,.;:\n#@"))
                    
                    
                    for var i in (0..<components.count).reversed(){
                        var dictionary = [[String: AnyObject]]()
                        let word = components
                        
                        if word[i].isEmpty == false{
                            
                            if(!word[i].containsEmoji){
                                var currentScore = CLongLong(baseScore)
                                
                                var wordDictionary = NSMutableDictionary()
                                
                                wordDictionary.setValue(currentScore, forKey: uid)
                                
                                dictWords.setObject(wordDictionary, forKey: word[i].lowercased() as NSCopying)
                            }
                        }
                    }
                    
                }
            }
        }
        authService.saveScore(words: dictWords){(success) -> () in
            
        }
    }
    
}
extension String {
    var containsEmoji: Bool {
        for scalar in unicodeScalars {
            switch scalar.value {
            case 0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0xFE00...0xFE0F,   // Variation Selectors
            0x1F900...0x1F9FF:   // Various (e.g. 🤖)
                return true
            default:
                continue
            }
        }
        return false
    }
}

extension UIView {
    
    @IBInspectable var shadow: Bool {
        get {
            return layer.shadowOpacity > 0.0
        }
        set {
            if newValue == true {
                self.addShadow()
            }
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return self.layer.cornerRadius
        }
        set {
            self.layer.cornerRadius = newValue
            
            // Don't touch the masksToBound property if a shadow is needed in addition to the cornerRadius
            if shadow == false {
                self.layer.masksToBounds = true
            }
        }
    }
    
    
    func addShadow(shadowColor: CGColor = UIColor.black.cgColor,
                   shadowOffset: CGSize = CGSize(width: 4.0, height: 6.0),
                   shadowOpacity: Float = 0.4,
                   shadowRadius: CGFloat = 3.0) {
        layer.shadowColor = shadowColor
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}
