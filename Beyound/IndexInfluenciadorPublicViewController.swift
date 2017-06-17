//
//  IndexInfluenciadorViewController.swift
//  beyound
//
//  Created by Daniela Pereira on 24/02/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit


class IndexInfluenciadorPublicViewController: UIViewController {
    
    @IBAction func LogoutAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    var influenciadorId: String!
    
    var influenciador: NSDictionary!
    
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
    
    @IBOutlet weak var mediaLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //recalcula o seu ranking
        getInfluenciador(){(completion) -> () in
            if(completion == nil){
                
                self.configureView()
            }
        }
        
    }
    
    func configureView(){
     
        
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
        }
        
    }
    
    func getInfluenciador(completion: @escaping (Error?) -> ()){
        
        let url = "https://tcc-beyound.firebaseio.com/influenciadores/"+influenciadorId+".json?print=pretty"
        
        let request = NSMutableURLRequest(url: NSURL(string: url) as! URL)
        let session = URLSession.shared
        request.httpMethod = "GET"
        
        
        var err: NSError?
        
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            
            var strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
            
            var err: NSError?
            
            do{
                
                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary {
                    
                    self.influenciador = jsonResult
                    completion(nil)
                }
                
            }catch let error as NSError{
                completion(error)
                print(error)
            }
        })
        
        task.resume()
    }
}
