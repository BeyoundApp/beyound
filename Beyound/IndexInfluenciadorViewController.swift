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
        
        
         let influenciador = Singleton.sharedInstance.getInfluenciador()
        
         let name = influenciador.value(forKey: "fullname") as! String
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
 
    }
}
