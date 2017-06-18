//
//  UsersTableViewController.swift
//  FirebaseAppDemo
//
//  Created by Frezy Stone Mboumba on 10/2/16.
//  Copyright © 2016 MaranathApp. All rights reserved.
//

import UIKit

class UsersTableViewController: UITableViewController {

    var reachedInfluencers: NSDictionary!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reachedInfluencers = NSDictionary()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.getReachedInfluencers{(completion) -> () in
            if(completion == nil){
                self.tableView.reloadData()
            }
        }
        
        
    }
    
    func getReachedInfluencers(completion: @escaping (Error?) -> ()){
        
        let url = "https://tcc-beyound.firebaseio.com/users/"+Singleton.sharedInstance.getUserLoggedId()+"/reachedInfluencers.json"
        
        let request = NSMutableURLRequest(url: NSURL(string: url) as! URL)
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        var err: NSError?
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            var err: NSError?
            var string = String(data: data!, encoding: .utf8)
            
            if (string?.contains("null"))!{
                
                completion(nil)
                
            }else{
                
                do{
                    
                    if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                        self.reachedInfluencers = jsonResult
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

    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return reachedInfluencers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! UsersTableViewCell

        var influenciador = self.reachedInfluencers.object(forKey: self.reachedInfluencers.allKeys[indexPath.row]) as! NSDictionary

        let name = influenciador.value(forKey: "full_name") as! String
        let username = influenciador.value(forKey: "username") as! String
        let website = influenciador.value(forKey: "website") as! String
        let url = NSURL(string: influenciador.value(forKey:"photoURL") as! String)!
        let profile = NSData(contentsOf: url as URL)

        cell.usernameLabel.text = username
        cell.emailLabel.text = name
        cell.countryLabel.text = website
        
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                cell.userImageView.image = UIImage(data: profile as! Data)
            }
        }
        
        return cell
    }
    
}
