//
//  SearchResultController.swift
//  Beyound
//
//  Created by Elder Santos on 10/04/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class SearchResultController: UIViewController {

    var queryTags : NSMutableArray!
    var influencers : NSMutableDictionary!
    var allWords : NSMutableDictionary!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        queryTags = ["De", "view", "Fora" ,"Temer", "Kaiser", "Melhor", "Rio", "THE"]
        
        
        self.getScores(){(completion) -> () in
            if(completion == nil){
        
                self.filterSearchResults()
                
            }
        
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    func filterSearchResults(){
        
        influencers = NSMutableDictionary()
        
        for tag in queryTags{
            
            if(allWords.object(forKey: tag) != nil){
                
                for inf in allWords.object(forKey: tag) as! [NSMutableDictionary]{
                    
                    let uids = inf.allKeys as NSArray
                    
                    for uid in uids{
                        
                        if(influencers.object(forKey: uid) != nil){
                            
                            var currentScore = (influencers.object(forKey: uid) as! NSMutableDictionary).value(forKey: "score") as! Int
                            currentScore += (inf.value(forKey: uid as! String) as! Int)
                            (influencers.object(forKey: uid) as! NSMutableDictionary).setValue(currentScore, forKey: "score")
                            
                            var words = (influencers.object(forKey: uid) as! NSMutableDictionary).value(forKey: "words") as! NSMutableArray
                            words.add(tag)
                            (influencers.object(forKey: uid) as! NSMutableDictionary).setObject(words, forKey: "words" as NSCopying)
                        }else{
                            
                            var influencer = NSMutableDictionary()
                            var words = NSMutableArray()
                            words.add(tag)
                            influencer.setValue((inf.value(forKey: uid as! String) as! Int), forKey: "score")
                            influencer.setObject(words, forKey: "words" as NSCopying)

                        }
                        
                    }
                    
                }
                
            }
            
        }
        
        print(influencers)
    }
    

    func getScores(completion: @escaping (Error?) -> ()){
        
        let url = "https://tcc-beyound.firebaseio.com/scores.json"
        
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
                        self.allWords = jsonResult.mutableCopy() as! NSMutableDictionary
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


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}