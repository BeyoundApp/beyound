//
//  File.swift
//  FirebaseAppDemo
//
//  Created by Frezy Stone Mboumba on 10/2/16.
//  Copyright © 2016 MaranathApp. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import FirebaseAuth
import Firebase

struct Post {
    
    var username: String!
    var firstLastName: String!
    var uid: String!
    var postId: String!
    var postType: String!
    var postText: String!
    var postPicUrl: String!
    var postDate: NSNumber!
    var ref: FIRDatabaseReference!
    var key: String?
    
    init(snapshot: FIRDataSnapshot){
        
        self.ref = snapshot.ref
        self.key = snapshot.key
        self.firstLastName = (snapshot.value! as! NSDictionary)["firstLastName"] as! String
        self.username = (snapshot.value! as! NSDictionary)["username"] as! String
        self.postId = (snapshot.value! as! NSDictionary)["postId"] as! String
        self.postType = (snapshot.value! as! NSDictionary)["postType"] as! String
        self.postPicUrl = (snapshot.value! as! NSDictionary)["postPicUrl"] as! String
        self.postDate = (snapshot.value! as! NSDictionary)["postDate"] as! NSNumber
        self.postText = (snapshot.value! as! NSDictionary)["postText"] as! String
        self.uid = (snapshot.value! as! NSDictionary)["uid"] as! String
  
    }
    
    init(firstLastName: String, username: String, postId: String, postText: String, postDate: NSNumber, postPicUrl: String, postType: String, uid: String){
        
        self.firstLastName = firstLastName
        self.username = username
        self.postText = postText
        self.postPicUrl = postPicUrl
        self.postType = postType
        self.uid = uid
        self.postDate = postDate
        self.postId = postId
    
    }
    
    func toAnyObject() -> [String: Any] {
        return ["username": username, "firstLastName":firstLastName,"postId":postId,"postType":postType, "postPicUrl":postPicUrl,"postDate":postDate, "postText":postText,"uid": uid]
    }
    
    
    
    
    
}
