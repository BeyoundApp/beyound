//
//  UsersTableViewController.swift
//  FirebaseAppDemo
//
//  Created by Frezy Stone Mboumba on 10/2/16.
//  Copyright © 2016 MaranathApp. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase
import FirebaseStorage
import FirebaseAuth

class UsersTableViewController: UITableViewController {

    var usersArray = [User]()
    
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchUsers()
    }

    func fetchUsers(){
        
        dataBaseRef.child("users").observe(.value, with: { (snapshot) in
            var results = [User]()
            
            for user in snapshot.children {
                
            let user = User(snapshot: user as! FIRDataSnapshot)
                
                if user.uid != FIRAuth.auth()!.currentUser!.uid {
                results.append(user)
                }
                
            }
            
            self.usersArray = results.sorted(by: { (u1, u2) -> Bool in
                u1.firstLastName < u2.firstLastName
            })
            self.tableView.reloadData()
            
            }) { (error) in
                print(error.localizedDescription)
        }
    
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usersArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "usersCell", for: indexPath) as! UsersTableViewCell

        // Configure the cell...
        
        cell.configureCell(user: usersArray[indexPath.row])

        return cell
    }
    
}
