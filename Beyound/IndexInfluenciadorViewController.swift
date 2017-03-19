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
    
    var questionGrade : Int?
    var didCameFromQuestionary : Bool!
    var arrayPosts : NSArray = []
    var dictWords : NSMutableDictionary = [:]
    
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
        
        
         let influenciador = Singleton.sharedInstance.getInfluenciador()
        
         let name = influenciador.value(forKey: "full_name") as! String
         let username = influenciador.value(forKey: "username") as! String
         let url = NSURL(string: influenciador.value(forKey:"photoURL") as! String)!
         let profile = NSData(contentsOf: url as URL)
        
         self.nameLabel.text = name
         self.usernameLabel.text = "@" + username
        
         DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.perfil.image = UIImage(data: profile as! Data)
            }
         }
        
        //recalcula o seu ranking
        getPosts(){(completion) -> () in
            if(completion == nil){
                self.getScores(){(completion2) -> () in
                    if(completion2 == nil){
                        self.calculateScores()
                    }
                }
            }
        }
    }
    
    private func calcuateDaysBetweenTwoDates(start: Date, end: Date) -> Int {
        
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: .day, in: .era, for: start) else {
            return 0
        }
        guard let end = currentCalendar.ordinality(of: .day, in: .era, for: end) else {
            return 0
        }
        return end - start
    }
    
    func getScores(completion: @escaping (Error?) -> ()){
        
        let influenciador = Singleton.sharedInstance.getInfluenciador() as NSDictionary
        let uid = influenciador.value(forKey: "uid") as! String
        
        let url = "https://tcc-beyound.firebaseio.com/scores/"+uid+".json?print=pretty"
        
        let request = NSMutableURLRequest(url: NSURL(string: url) as! URL)
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        var err: NSError?
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var err: NSError?
            var string = String(data: data!, encoding: .utf8)

            if string == "null\n"{
                
                completion(nil)
                
            }else{

                do{
                    
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        self.dictWords = jsonResult.mutableCopy() as! NSMutableDictionary
                        completion(nil)
                    }
                }catch let error as NSError{
                    print(error)
                    completion(nil)
                }
        
            }
        })
        task.resume()
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
        let influenciador = Singleton.sharedInstance.getInfluenciador() as NSDictionary
        let uid = influenciador.value(forKey: "uid") as! String

        let jsonResult = self.arrayPosts
        
        //calcula frequencia
        let firstPostDate = NSDate(timeIntervalSince1970: Double((jsonResult[0] as! NSDictionary).value(forKey: "created_time") as! String)!) as NSDate
        let lastPostDate = NSDate(timeIntervalSince1970: Double((jsonResult.lastObject as! NSDictionary).value(forKey: "created_time") as! String)!) as NSDate
        
        //frequencia tem que ser negativa pois quanto maior o calculo abaixo, pior o ranking
        let freq = self.calcuateDaysBetweenTwoDates(start: firstPostDate as Date, end: lastPostDate as Date)
        
        let followers = Singleton.sharedInstance.getInfluenciador().value(forKey: "followers") as! Int
        let following = Singleton.sharedInstance.getInfluenciador().value(forKey: "following") as! Int
        
        let ffRatio = Double(followers)/Double(following) as Double
        
        //instancia o AuthService
        let authService = AuthService()
        
        //resultado do questionario
        var questionaryResult = Int()
        if(self.didCameFromQuestionary == true){
            questionaryResult = self.questionGrade!
            authService.updateInfluenciadorQuestionary(uid: uid, questionaryTotal: questionaryResult){(completion) -> () in
                
            }
        }else{
            questionaryResult = Singleton.sharedInstance.getInfluenciador().value(forKey: "questionaryTotal") as! Int
        }
        
        
        var newWords = NSDictionary()
        
        var baseScore = self.questionGrade! + freq * 5 + Int(ffRatio*10) as Int
        
        for item in jsonResult as! [NSDictionary] {
            
            //quantidade de likes desse post
            let count = (item.object(forKey: "likes") as! NSDictionary).value(forKey: "count") as! Int
            
            //quantidade de hashtags do post
            var numberTags = 0 as Int
            let tags = (item.object(forKey: "tags") as? NSDictionary)
            if((tags) != nil){
                numberTags = (tags?.count)!
            }
            
            let caption = item.object(forKey: "caption") as? NSDictionary
            
            //verifica se o post tem legenda
            if((caption) != nil){
            
                baseScore += count * 15 + numberTags * 10
                
                //palavras da legenda desse post
                let subtitle = caption?.value(forKey: "text") as! String
                let components = subtitle.components(separatedBy: CharacterSet.init(charactersIn: " ,.;:#"))
                
                
                for var i in (0..<components.count).reversed(){
                    var dictionary = [[String: AnyObject]]()
                    let word = components
                    
                    if word[i].isEmpty == false{
                    
                        if(dictWords.object(forKey: word[i]) != nil){
                            var currentScore = dictWords.object(forKey: word[i]) as! CLongLong
                            currentScore += baseScore
                            dictWords.setObject(currentScore, forKey: word[i] as NSCopying)
                        }else{
                            var currentScore = CLongLong(baseScore)
                            dictWords.setObject(currentScore, forKey: word[i] as NSCopying)

                        }
                    }
                }
            }
        }
        authService.saveScore(uid: uid, words: dictWords){(success) -> () in
            
        }
    }
    
}
