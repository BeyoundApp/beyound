import Foundation
import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

struct AuthService {
    
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference! {
        return FIRStorage.storage().reference()
    }
    
    
    // 1 - Creating the Signup function
    
    func signUp (firstLastName: String, username: String, address: String, cnpj: String, email: String, category: String, biography: String, password: String, pictureData: NSData!) {
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                
                self.setUserInfo(firstLastName:firstLastName,user:user, username:username, address:address, cnpj:cnpj, category: category, biography: biography, password: password, pictureData: pictureData)
            } else {
                print(error!.localizedDescription)
            }
        })
        
    
    }
    
    
    // 2 - Save the User Profile Picture to Firebase Storage, Assign to the new user a username and Photo URL
    
    private func setUserInfo(firstLastName: String,user: FIRUser!, username: String, address: String, cnpj: String, category: String, biography: String, password: String, pictureData: NSData!){
        
        let imagePath = "profileImage\(user.uid)/userPic.jpg"
        
        let imageRef = storageRef.child(imagePath)
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
            
            if error == nil {
                
                let changeRequest = user.profileChangeRequest()
                changeRequest.displayName = username
                
                if let photoURL = newMetaData!.downloadURL() {
                    changeRequest.photoURL = photoURL
                }
                
                changeRequest.commitChanges(completion: { (error) in
                    if error == nil {
                        
                        self.saveUserInfo(firstLastName: firstLastName,user:user, username: username, address: address, cnpj: cnpj, category: category, biography: biography, password: password)
                        
                        
                    }else{
                        print(error!.localizedDescription)
 
                    }
                })
                
                
            }
            else {
                print(error!.localizedDescription)
            }
            
        }
        
        
        
    }
    
    // 3 - Save the User Info to Firebase Database
    
    private func saveUserInfo(firstLastName: String,user: FIRUser!, username: String, address: String, cnpj: String, category: String, biography: String, password: String){
        
        let userInfo = ["firstLastName":firstLastName,"email": user.email!, "username": username, "address": address, "cnpj":cnpj, "category": category, "biography":biography, "uid": user.uid, "photoURL": String(describing: user.photoURL!)]
        
        let userRef = dataBaseRef.child("users").child(user.uid)
        
        userRef.setValue(userInfo) { (error, ref) in
            if error == nil {
                print("user info saved successfully")
                self.logIn(email: user.email!, password: password)
            }else {
                print(error!.localizedDescription)

            }
        }
        
        
    }
    
    
   // 4 - Logging the user in function
    
    
    func logIn(email: String, password: String){
        
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                if let user = user {
                    
                    print("\(user.displayName!) se logou com sucesso!")
                    
                    let appDel : AppDelegate = UIApplication.shared.delegate as! AppDelegate
                    appDel.logUser()
                }
                
                
            }
            else {
                print(error!.localizedDescription)
  
            }
        })
        
    }
    
    
    //update para influenciador que já está registrado
    
    public func updateInfluenciador(uid: String, username: String, fullName: String, followers: Int, following: Int, biography: String, website: String, mediaCount: Int, completion: @escaping (Error?) -> ()){
        
        let userInfo = ["uid":uid,"username": username, "full_name": fullName, "followers": followers, "following":following, "media_count": mediaCount, "biography":biography, "website":website] as [String : Any]
        
        let userRef = self.dataBaseRef.child("influenciadores").child(uid)
        
        userRef.updateChildValues(userInfo) { (error, ref) in
            if error == nil {
                print("user info saved successfully")
                completion(nil)
            }else {
                print(error!.localizedDescription)
                completion(error)
            }
        }
        
    }
    
    // SET E SAVE INFLUENCIADORES
    public func setInfluenciador(uid: String, username: String, fullName: String, followers: Int, following: Int, biography: String, website: String, mediaCount: Int, pictureData: NSData!, answered: Bool, questionaryTotal: Int,score:Int,  completion: @escaping (Error?) -> ()){
        
        let imagePath = "profileImage\(uid)/userPic.jpg"
        
        let imageRef = storageRef.child(imagePath)
        
        let metaData = FIRStorageMetadata()
        metaData.contentType = "image/jpeg"
        
        
        imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
            
            
            if error == nil {
                
                if let photoURL = newMetaData!.downloadURL() {
                    
                    let userInfo = ["uid":uid,"username": username, "full_name": fullName, "followers": followers, "following":following, "media_count": mediaCount, "biography":biography, "website":website, "photoURL": String(describing:photoURL), "answered": answered, "questionaryTotal": questionaryTotal, "score": score] as [String : Any]
                    
                    let userRef = self.dataBaseRef.child("influenciadores").child(uid)
                    
                    userRef.updateChildValues(userInfo) { (error, ref) in
                        if error == nil {
                            print("user info saved successfully")
                            completion(nil)
                        }else {
                            print(error!.localizedDescription)
                        }
                        
                        completion(error)
                    }

                    
                }else{
                    print(error!.localizedDescription)
                    completion(error)

                }
                
            }else {
                print(error!.localizedDescription)
                completion(error)
            }
            
        }
        
        
    }
    
    private func saveInfluenciador(uid: String, username: String, fullName: String, followers: Int, following: Int, biography: String, website: String, mediaCount: Int, photoURL: String, answered: Bool) -> Bool{
        
        let userInfo = ["uid":uid,"username": username, "full_name": fullName, "followers": followers, "following":following, "media_count": mediaCount, "biography":biography, "website":website, "photoURL": photoURL, "answered": answered] as [String : Any]
        
        let userRef = dataBaseRef.child("influenciadores").child(uid)
        
        var success = false
        
        userRef.updateChildValues(userInfo) { (error, ref) in
            if error == nil {
                print("user info saved successfully")
                success = true
            }else {
                print(error!.localizedDescription)
            }
        }

        return success
    }

    public func saveScore(words: NSDictionary, completion: @escaping (Bool) -> ()){
        
        let scoreInfo = words
        let scoreRef = dataBaseRef.child("scores")
        
        scoreRef.updateChildValues(scoreInfo as! [AnyHashable : Any]) { (error, ref) in
            if error == nil {
                completion(true)
                print("scores info saved successfully")
            }else {
                completion(false)
                print(error!.localizedDescription)
            }
        }
        
    }
    
    public func updateInfluenciadorQuestionary(uid:String, questionaryTotal : Int, questionaryResult: NSMutableDictionary, completion: @escaping (Bool) -> ()){
        
        let userInfo = ["questionaryTotal":questionaryTotal, "answered": 1 , "questionaryResult": questionaryResult] as [String : Any]

        let userRef = dataBaseRef.child("influenciadores").child(uid)
        
        userRef.updateChildValues(userInfo) { (error, ref) in
            if error == nil {
                completion(true)
            }else {
                completion(false)
                print(error!.localizedDescription)
            }
        }

        
    }
    
    public func updateInfluenciadorScore(uid:String, score : Int, completion: @escaping (Bool) -> ()){
        
        let userInfo = ["score":score]
        let userRef = dataBaseRef.child("influenciadores").child(uid)
        
        userRef.updateChildValues(userInfo) { (error, ref) in
            if error == nil {
                completion(true)
            }else {
                completion(false)
                print(error!.localizedDescription)
            }
        }
        
        
    }

    public func updateInfluenciadorQuestionaryAndScore(uid:String, questionaryTotal : Int, questionaryResult: NSMutableDictionary, score : Int, completion: @escaping (Bool) -> ()){
        
        let userInfo = ["questionaryTotal":questionaryTotal, "answered": 1, "score":score, "questionaryResult": questionaryResult] as [String : Any]
        let userRef = dataBaseRef.child("influenciadores").child(uid)
        
        userRef.updateChildValues(userInfo) { (error, ref) in
            if error == nil {
                completion(true)
            }else {
                completion(false)
                print(error!.localizedDescription)
            }
        }
        
        
    }
    
    public func savePost(uid: String ,createdTime: String, caption: NSDictionary?, likes:Int, link:String, comments:Int, id: String, location: NSDictionary?, tags: NSArray?){
        
        let postInfo = ["created_time":createdTime, "caption":caption, "likes":likes, "link":link, "comments":comments, "id":id, "location":location, "tags":tags] as [String : Any]
        
        let postRef = dataBaseRef.child("influenciadores").child(uid).child("posts").child(id)

        postRef.updateChildValues(postInfo) { (error, ref) in
            if error == nil {
                print("post info saved successfully")
            }else {
                print(error!.localizedDescription)
            }
        }

        
        
    }
    
    public func savePosts(uid: String, posts : NSArray?, completion: @escaping () -> ()){
        
        
        let postRef = dataBaseRef.child("influenciadores").child(uid)
        
        let postsData = ["posts" : posts ?? "error"] as [String : Any]
        
        postRef.updateChildValues(postsData) { (error, ref) in
            if error == nil {
                print("posts info saved successfully")
                completion()
            }else {
                print(error!.localizedDescription)
                completion()
            }
        }
        
        
        
    }
    
    public func findInfluenciador(uid: String, completion: @escaping (NSDictionary?) -> ()) {
        
        let find = dataBaseRef.child("influenciadores").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                // Get user value
                let influenciador = snapshot.value as? NSDictionary
                completion(influenciador)
            }) { (error) in
                completion(nil)
                print(error.localizedDescription)
        }
    }
    
    public func findScores(uid: String, completion: @escaping (NSDictionary?) -> ()){
        let find = dataBaseRef.child("scores").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let score = snapshot.value as? NSDictionary
            completion(score)
        }) { (error) in
            completion(nil)
            print(error.localizedDescription)
        }
    }
    
    //com autenticacao requerida
    //    // SET E SAVE INFLUENCIADORES
    
//        public func signupInfluenciador(uid: String, username: String, fullName: String, followers: Int, following: Int, biography: String, website: String, mediaCount: Int, pictureData: NSData!) -> Bool{
//    
//            var success = false
//            FIRAuth.auth()?.createUser(withEmail: username+"@testings.com", password: uid+"123", completion: { (user, error) in
//                if error == nil {
//    
//                    success = self.setInfluenciador(user:user, uid: uid, username: username, fullName: fullName, followers: followers, following: following, biography: biography, website: website, mediaCount: mediaCount, pictureData: pictureData)
//                } else {
//                    print(error!.localizedDescription)
//                }
//            })
//    
//            return success
//        }
//    
//    
//        private func setInfluenciador(user: FIRUser!, uid: String, username: String, fullName: String, followers: Int, following: Int, biography: String, website: String, mediaCount: Int, pictureData: NSData!) -> Bool{
//    
//            let imagePath = "profileImage\(user.uid)/userPic.jpg"
//    
//            let imageRef = storageRef.child(imagePath)
//    
//            let metaData = FIRStorageMetadata()
//            metaData.contentType = "image/jpeg"
//    
//            var success = false
//    
//            imageRef.put(pictureData as Data, metadata: metaData) { (newMetaData, error) in
//    
//    
//                if error == nil {
//    
//                    let changeRequest = user.profileChangeRequest()
//                    changeRequest.displayName = username
//    
//                    if let photoURL = newMetaData!.downloadURL() {
//                        changeRequest.photoURL = photoURL
//                    }
//    
//                    changeRequest.commitChanges(completion: { (error) in
//                        if error == nil {
//    
//                            let result = self.saveInfluenciador(user:user, uid: uid ,username:username, fullName:fullName, followers:followers, following:following, biography:biography, website: website,mediaCount:mediaCount)
//                            success = result;
//    
//                        }else{
//                            print(error!.localizedDescription)
//    
//                        }
//                    })
//                }else {
//                    print(error!.localizedDescription)
//                }
//    
//            }
//    
//            return success
//    
//        }
//    
//        private func saveInfluenciador(user: FIRUser!, uid: String, username: String, fullName: String, followers: Int, following: Int, biography: String, website: String, mediaCount: Int) -> Bool{
//    
//            let userInfo = ["uid":uid,"username": username, "full_name": fullName, "followers": followers, "following":following, "media_count": mediaCount, "biography":biography, "website":website, "photoURL": String(describing: user.photoURL!)] as [String : Any]
//    
//            let userRef = dataBaseRef.child("influenciadores").child(uid)
//    
//            var success = false
//    
//            userRef.setValue(userInfo) { (error, ref) in
//                if error == nil {
//                    print("user info saved successfully")
//                    success = true
//                }else {
//                    print(error!.localizedDescription)
//                }
//            }
//            
//            return success
//        }
//
    
    
    
    
  
    
}


extension LoginViewController {
    
    func resetPassword (){
        var email = ""
        let alertController = UIAlertController(title: "Trocar de Senha", message: "Um email para enviar as informaçöes de troca de senha foi enviado para o email a seguir: \(email) ", preferredStyle: .alert)
        alertController.addTextField(configurationHandler: { (textfield) in
            textfield.placeholder = "contato@mail.com"
            
        })
        let textField = alertController.textFields!.first
        email = textField!.text!
        alertController.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))

        

        FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
            if error == nil {
                
                self.present(alertController, animated: true, completion: nil)
                
            }else {
                print(error!.localizedDescription)
                
            }
        })
        
    }
    
    
}
