//
//  SearchResultController.swift
//  Beyound
//
//  Created by Elder Santos on 10/04/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class SearchResultController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var queryTags : NSMutableArray!
    var influencers : NSMutableDictionary!
    var allInfluencers : NSMutableDictionary!
    var allWords : NSMutableDictionary!
    var displayedResults : Array<Any> = []
        
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        influencers = NSMutableDictionary()
        displayedResults = Array()
        
        
        tableView.estimatedRowHeight = 170
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        
        self.getInfluencers{(completion) -> () in
            if(completion == nil){
                self.filterSearchResults()
            }
        }
        // Do any additional setup after loading the view.
    }

    @IBAction func segmentChanged(_ sender: Any) {
        
        if(segmentedControl.selectedSegmentIndex == 0){
            
            displayedResults = influencers.sorted { (first: (key: Any, value: Any), second:(key: Any, value: Any)) -> Bool in
                
                return ((first.value as! NSDictionary).object(forKey: "words") as! NSArray).count > ((second.value as! NSDictionary).object(forKey: "words") as! NSArray).count
                
            }
            
        }else{
            
            displayedResults = influencers.sorted { (first: (key: Any, value: Any), second:(key: Any, value: Any)) -> Bool in
                
                return ((first.value as! NSDictionary).object(forKey: "score") as! Int) > ((second.value as! NSDictionary).object(forKey: "score") as! Int)
                
            }

            
        }
        
        
        self.tableView.reloadData()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return influencers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell",
                                                 for: indexPath) as! SearchResultTableCell
        
        
        let key = (displayedResults[indexPath.row] as! NSDictionary.Iterator.Element).key
        
        let url = NSURL(string: (allInfluencers.object(forKey: key) as! NSDictionary).value(forKey: "photoURL") as! String)!
        let profile = NSData(contentsOf: url as URL)

        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                cell.imageProfile.image = UIImage(data: profile as! Data)
            }
        }
        
        cell.labelName.text = (allInfluencers.object(forKey: key) as! NSDictionary).value(forKey: "full_name") as! String
        
        cell.labelUser.text = "@" + ((allInfluencers.object(forKey: key) as! NSDictionary).value(forKey: "username") as! String)
        
        let followText = String((allInfluencers.object(forKey: key) as! NSDictionary).value(forKey: "followers") as! Int) + " seguidores e " + String((allInfluencers.object(forKey: key) as! NSDictionary).value(forKey: "following") as! Int) + " seguindo."
        
        cell.labelFollow.text = followText
        
        let likesLastPost = ((((allInfluencers.object(forKey: key) as! NSDictionary).value(forKey: "posts") as! NSArray).object(at: 0) as! NSDictionary).object(forKey: "likes") as! NSDictionary).value(forKey: "count") as! Int
        
        let followers = (allInfluencers.object(forKey: key) as! NSDictionary).value(forKey: "followers") as! Int
        
        let ratio = Double(likesLastPost) / Double(followers) * 100 as Double
        
        cell.labelRangeRatio.text = String.localizedStringWithFormat("%.2f%% de alcance aproximado.", ratio)
        
        let words = (influencers.object(forKey: key) as! NSDictionary).object(forKey: "words") as! NSArray
        
        var textWords = String()
        
        for word in words as! [String]{
            
            textWords += word + " "
            
        }
        
        cell.labelWords.text = textWords.substring(to: textWords.index(before: textWords.endIndex))
        
        return cell
        
    }
    
    func filterSearchResults(){
        
        influencers = NSMutableDictionary()
        
        for tag in queryTags{
            
            if(allWords.object(forKey: tag) != nil){
                
                var wordDictionary = (allWords.object(forKey: tag as! String) as! NSDictionary)
                
                let uids = wordDictionary.allKeys as NSArray
                
                for uid in uids{

                    if(influencers.object(forKey: uid) != nil){

                        var currentScore = (influencers.object(forKey: uid) as! NSMutableDictionary).value(forKey: "score") as! Int
                        currentScore += (wordDictionary.value(forKey: uid as! String) as! Int)
                        (influencers.object(forKey: uid) as! NSMutableDictionary).setValue(currentScore, forKey: "score")

                        var words = (influencers.object(forKey: uid) as! NSMutableDictionary).value(forKey: "words") as! NSMutableArray
                        words.add(tag)
                        (influencers.object(forKey: uid) as! NSMutableDictionary).setObject(words, forKey: "words" as NSCopying)
                    }else{

                        var influencer = NSMutableDictionary()
                        var words = NSMutableArray()
                        words.add(tag)
                        influencer.setValue((wordDictionary.value(forKey: uid as! String) as! Int), forKey: "score")
                        influencer.setObject(words, forKey: "words" as NSCopying)
                        influencers.setObject(influencer, forKey: uid as! NSCopying)
                    }
                    
                }

                
            }
            
        }

        displayedResults = influencers.sorted { (first: (key: Any, value: Any), second:(key: Any, value: Any)) -> Bool in
            
            return ((first.value as! NSDictionary).object(forKey: "words") as! NSArray).count > ((second.value as! NSDictionary).object(forKey: "words") as! NSArray).count
            
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.activityIndicator.isHidden = true

        }
    }
    
    

    func getInfluencers(completion: @escaping (Error?) -> ()){
        
        let url = "https://tcc-beyound.firebaseio.com/influenciadores.json"
        
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
                        self.allInfluencers = jsonResult.mutableCopy() as! NSMutableDictionary
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
