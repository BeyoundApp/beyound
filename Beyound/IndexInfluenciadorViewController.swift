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
        recalculateRanking()
 
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
    
    func recalculateRanking(){
        
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
                
                var totalLikes = 0 as Int
                var totalHashTags = 0 as Int
                
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSArray {
                    
                    for item in jsonResult as! [NSDictionary] {
                        
                        //quantidade de likes desse post
                        let count = (item.object(forKey: "likes") as! NSDictionary).value(forKey: "count") as! Int
                        
                        //quantidade de hashtags do post
                        var numberTags = 0 as Int
                        let tags = (item.object(forKey: "tags") as? NSDictionary)
                        if((tags) != nil){
                            numberTags = (tags?.count)!
                        }
                        
                        totalHashTags += numberTags
                        
                        let caption = item.object(forKey: "caption") as? NSDictionary
                        
                        //verifica se o post tem legenda
                        if((caption) != nil){
                            
                            //palavras da legenda desse post
                            let subtitle = caption?.value(forKey: "text") as! String
                            let components = subtitle.components(separatedBy: CharacterSet.init(charactersIn: " ,.;:"))
                            
                            
                            for var i in (0..<components.count).reversed(){
                                var dictionary = [[String: AnyObject]]()
                                let word = components
                            
                                if word[i].isEmpty == false{
                                    dictionary.append(["nome" : word[i] as AnyObject, "like" : count as AnyObject])

                                    
                                    totalLikes += count
                                }
                            }
                        }
                    }
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

                    //verifica se acabou de finalizar o questionario
                    if(self.didCameFromQuestionary == true){
                        
                        let newScore = self.questionGrade! + totalLikes * 15 + totalHashTags * 10 + freq * 5 + Int(ffRatio*10)
                        authService.updateInfluenciadorQuestionaryAndScore(uid: uid, questionaryTotal: self.questionGrade!, score: newScore){(success) -> () in
                            if(success){
                                print("updated score")
                            }
                        }
                    }else{
                        
                        let currentQuestionGrade = Singleton.sharedInstance.getInfluenciador().value(forKey: "questionaryTotal") as! Int
                        
                        let newScore = currentQuestionGrade + totalLikes * 15 + totalHashTags * 10 + freq * 5 + Int(ffRatio*10)
                        authService.updateInfluenciadorScore(uid: uid, score: newScore){(success) -> () in
                            if(success){
                                print("updated score")
                            }
                        }

                    }
                    
                }
                
            }catch let error as NSError{
                print(error)
            }
        })
        
        task.resume()
    }

}
