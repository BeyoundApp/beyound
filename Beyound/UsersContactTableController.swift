//
//  UsersContactTableController.swift
//  Beyound
//
//  Created by Elder Santos on 18/06/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class UsersContactTableController: UITableViewController {

    var contactUsers: NSDictionary!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactUsers = NSDictionary()

    }
    @IBAction func exit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.getContactUsers{(completion) -> () in
            if(completion == nil){
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        
    }

    func getContactUsers(completion: @escaping (Error?) -> ()){
        
        let url = "https://tcc-beyound.firebaseio.com/influenciadores/"+(Singleton.sharedInstance.getInfluenciador().value(forKey: "uid") as! String)+"/userContacts.json"
        
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
                        self.contactUsers = jsonResult
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
        return contactUsers.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! UsersContactTableCell
        
        var empresa = self.contactUsers.object(forKey: self.contactUsers.allKeys[indexPath.row]) as! NSDictionary
        
        let name = empresa.value(forKey: "username") as! String
        let email = empresa.value(forKey: "email") as! String
        let cnpj = empresa.value(forKey: "cnpj") as! String

        let status = empresa.value(forKey: "status") as! Int
        
               DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                
                cell.labelName.text = name
                cell.labelCategory.text = email
                cell.labelAddress.text = cnpj

                if(status == 0){
                    cell.labelStatus.isHidden = true
                }else if (status == 1){
                    cell.labelStatus.isHidden = false
                    cell.labelStatus.text = "Você aceitou o contato."
                    cell.labelStatus.textColor = UIColor.green
                }else{
                    cell.labelStatus.isHidden = false
                    cell.labelStatus.text = "Você rejeitou o contato."
                    cell.labelStatus.textColor = UIColor.red
                }
            }
        }
        
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let authService = AuthService()
        
        var empresa = self.contactUsers.object(forKey: self.contactUsers.allKeys[indexPath.row]) as! NSDictionary
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        let uidUser = empresa.value(forKey: "uid") as! String
        let name = empresa.value(forKey: "username") as! String
        let email = empresa.value(forKey: "email") as! String
        let cnpj = empresa.value(forKey: "cnpj") as! String
        
        let status = empresa.value(forKey: "status") as! Int

        if(status == 0){
            
            let alertController1 = UIAlertController(title: "Contato da Empresa: "+name, message: "Você deseja aceitar o contato desta empresa?", preferredStyle: .alert)
            
            alertController1.addAction(UIAlertAction(title: "Aceitar", style: .default, handler: {
            alert -> Void in
                //SET STATUS 1 pedir email e phone
                
                let alertController = UIAlertController(title: "Dados para contato", message: "Por favor, nos informe seu email:", preferredStyle: .alert)
                
                alertController.addAction(UIAlertAction(title: "Salvar", style: .default, handler: {
                    alert -> Void in
                    let fNameField = alertController.textFields![0] as UITextField
                    let lNameField = alertController.textFields![1] as UITextField
                    
                    if (fNameField.text!.characters.count > 0 && lNameField.text!.characters.count > 0) {
                        
                        authService.setResponseContactAccept(uidUser: uidUser, uid: (Singleton.sharedInstance.getInfluenciador().value(forKey: "uid") as! String), email: fNameField.text!, phone: lNameField.text!){(error) -> () in
                            if(error == nil){
                                self.getContactUsers{(completion) ->  () in
                                
                                    if(completion == nil){
                                        
                                    }
                                    
                                }
                            }else{
                                let errorAlert = UIAlertController(title: "Erro!", message: "Erro ao processar solicitação. Tente novamente.", preferredStyle: .alert)
                                errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                                    alert -> Void in
                                }))
                                self.present(errorAlert, animated: true, completion: nil)
                            }
                        }
                        
                    } else {
                        let errorAlert = UIAlertController(title: "Error", message: "Coloque seu email e número de celular, por favor.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                            alert -> Void in
                            self.present(alertController, animated: true, completion: nil)
                        }))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }))
                
                alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: {
                    alert -> Void in
                    
                }))
                
                alertController.addTextField(configurationHandler: { (textField) -> Void in
                    textField.placeholder = "CONTATO@EMAIL.COM"
                    textField.textAlignment = .center
                })
                
                alertController.addTextField(configurationHandler: { (textField) -> Void in
                    textField.placeholder = "NÚMERO DE CELULAR"
                    textField.textAlignment = .center
                })
                
                self.present(alertController, animated: true, completion: nil)
                
            }))
           
            alertController1.addAction(UIAlertAction(title: "Rejeitar", style: .destructive, handler: {
                alert -> Void in
            
                authService.setResponseContactReject(uidUser: uidUser, uid: (Singleton.sharedInstance.getInfluenciador().value(forKey: "uid") as! String)){(error) -> () in
                    if(error == nil){
                        self.getContactUsers{(completion) ->  () in
                            
                            if(completion == nil){
                                
                            }
                            
                        }
                    }else{
                        let errorAlert = UIAlertController(title: "Erro!", message: "Erro ao processar solicitação. Tente novamente.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
                            alert -> Void in
                        }))
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                }

                
            }))
            self.present(alertController1, animated: true, completion: nil)
            
            
        }
        
    }
}

