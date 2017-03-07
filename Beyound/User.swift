

import Foundation
import Firebase
import FirebaseDatabase


struct User {
    
    var username: String?
    var address: String?
    var cnpj: String!
    var email: String?
    var category: String?
    var photoURL: String!
    var biography: String?
    var uid: String!
    var ref: FIRDatabaseReference?
    var key: String?
    var firstLastName: String!
    
    init(snapshot: FIRDataSnapshot){
        
        key = snapshot.key
        ref = snapshot.ref
        username = (snapshot.value! as! NSDictionary)["username"] as? String
        address = (snapshot.value! as! NSDictionary)["address"] as? String
        cnpj = (snapshot.value! as! NSDictionary)["cnpj"] as! String
        email = (snapshot.value! as! NSDictionary)["email"] as? String
        category = (snapshot.value! as! NSDictionary)["category"] as? String
        uid = (snapshot.value! as! NSDictionary)["uid"] as! String
        biography = (snapshot.value! as! NSDictionary)["biography"] as? String
        photoURL = (snapshot.value! as! NSDictionary)["photoURL"] as! String
        firstLastName = (snapshot.value! as! NSDictionary)["firstLastName"] as! String

    }
    
    
//    func toAnyObject() -> [String: Any] {
//        return ["email"]
//    }
    
}
