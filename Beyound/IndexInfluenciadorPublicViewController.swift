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
    
    var reachedInfluencers: NSDictionary!

    
    @IBOutlet weak var following: UILabel!
    @IBOutlet weak var followerLabel: UILabel!
    @IBOutlet weak var postView: UIImageView!
    var questionGrade : Int?
    var didCameFromQuestionary : Bool!
    var arrayPosts : NSArray = []
    var dictWords : NSMutableDictionary = [:]
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var perfil: UIImageView!
    
    @IBOutlet weak var mediaLabel: UILabel!
    
    @IBOutlet weak var buttonContact: UIButton!
    @IBAction func requestContact(_ sender: Any) {
        
        self.activityIndicator.isHidden = false
        self.buttonContact.isEnabled = false;
        
        let authService = AuthService()
        authService.setReachedInfluenciador(uidUser: Singleton.sharedInstance.getUserLoggedId(), nameUser: Singleton.sharedInstance.getUserLoggedName(), emailUser: Singleton.sharedInstance.getUserLoggedEmail(), cnpjUser: Singleton.sharedInstance.getUserLoggedCnpj(), uid: influenciador.value(forKey: "uid") as! String, username: influenciador.value(forKey: "username") as! String, fullName: influenciador.value(forKey: "full_name") as! String, website: influenciador.value(forKey: "website") as! String, photoURL: influenciador.value(forKey: "photoURL") as! String){ (error) -> () in
        
            if(error == nil){
                
                self.buttonContact.setTitle("Contato solicitado!", for: UIControlState.normal)
                self.activityIndicator.isHidden = true
                
            }else{
                
                let alertController = UIAlertController(title: "Erro!", message: "Erro no processamento da solicitação. Tente novamente.", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)

                
                self.buttonContact.isEnabled = true
                self.activityIndicator.isHidden = true

            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reachedInfluencers = NSDictionary()
        
        self.getReachedInfluencers{(completion) -> () in
            if(completion == nil){
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        if(self.reachedInfluencers.value(forKey: self.influenciador.value(forKey: "uid") as! String) == nil){
                            
                            self.buttonContact.setTitle("Solicitar Contato", for: UIControlState.normal)
                            self.buttonContact.isEnabled = true
                        }else{
                            
                            self.buttonContact.setTitle("Contato já solicitado!", for: UIControlState.normal)
                            self.buttonContact.isEnabled = false
                            
                        }
                        
                        self.activityIndicator.isHidden = true
                    }
                }
                
                
            }
        }

        
        self.configureView()
        
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

    
}
