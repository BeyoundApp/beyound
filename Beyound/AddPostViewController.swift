//
//  ViewController.swift
//  FirebaseAppDemo
//
//  Created by Frezy Stone Mboumba on 9/16/16.
//  Copyright © 2016 MaranathApp. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class AddPostViewController: UIViewController,UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var hasMedia: UISwitch!
    @IBOutlet weak var textView: UITextView!
    var currentUser: User!
    
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorageReference! {
        return FIRStorage.storage().reference()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightBarButton = UIBarButtonItem(image: UIImage(named:"save"), style: UIBarButtonItemStyle.plain, target: self, action: #selector(AddPostViewController.savePost))
        self.navigationItem.rightBarButtonItem = rightBarButton
        automaticallyAdjustsScrollViewInsets = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddPostViewController.choosePicture))
        tapGesture.numberOfTapsRequired = 1
        self.postImageView.addGestureRecognizer(tapGesture)
        self.postImageView.isUserInteractionEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        loadUserInfo()
    }
    func loadUserInfo(){
        
        let userRef = dataBaseRef.child("users/\(FIRAuth.auth()!.currentUser!.uid)")
        userRef.observe(.value, with: { (snapshot) in
            
            self.currentUser = User(snapshot: snapshot)
                    }) { (error) in
            print(error.localizedDescription)
        }
  
    }
    func choosePicture(){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        
        let alertController = UIAlertController(title: "Add a Profile Picture", message: "Choose From", preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
            
        }
        let photosLibraryAction = UIAlertAction(title: "Photos Library", style: .default) { (action) in
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let savedPhotosAction = UIAlertAction(title: "Saved Photos Album", style: .default) { (action) in
            pickerController.sourceType = .savedPhotosAlbum
            self.present(pickerController, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(photosLibraryAction)
        alertController.addAction(savedPhotosAction)
        alertController.addAction(cancelAction)
        
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage]  as? UIImage{
            self.postImageView.image = image
        }else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            self.postImageView.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func savePost(){
    
        var text: String!
        
        if let postText = textView.text {
            text = postText
        }
        
        if hasMedia.isOn {
            let data = UIImageJPEGRepresentation(self.postImageView.image!, 0.7)!
            let imagePath = "profileImage\(NSUUID().uuidString)/postPic.jpg"
            
            let imageRef = storageRef.child(imagePath)
            
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpeg"
            
            imageRef.put(data, metadata: metaData, completion: { (newMetaData, error) in
                if error == nil {
                    let newPost = Post(firstLastName: self.currentUser.firstLastName!, username: self.currentUser.username!, postId: NSUUID().uuidString, postText: text, postDate: (NSDate().timeIntervalSince1970 as NSNumber), postPicUrl: String(describing: newMetaData!.downloadURL()!), postType: "IMAGE", uid: self.currentUser.uid)
                    let postRef = self.dataBaseRef.child("posts").childByAutoId()
                    postRef.setValue(newPost.toAnyObject(), withCompletionBlock: { (error, ref) in
                        if error == nil {
                            self.navigationController!.popToRootViewController(animated: true)
                        }else {
                            print(error!.localizedDescription)

                        }
                    })
                }else {
                    print(error!.localizedDescription)
                }
            })
            
            
            
            
        }else {
            
            let newPost = Post(firstLastName: self.currentUser.firstLastName!, username: self.currentUser.username!, postId: NSUUID().uuidString, postText: text, postDate: (NSDate().timeIntervalSince1970 as NSNumber), postPicUrl: "", postType: "TEXT", uid: self.currentUser.uid)
            let postRef = self.dataBaseRef.child("posts").childByAutoId()
            postRef.setValue(newPost.toAnyObject(), withCompletionBlock: { (error, ref) in
                if error == nil {
                    self.navigationController!.popToRootViewController(animated: true)
                }else {
                    print(error!.localizedDescription)
                    
                }
            })
 
            
            
            
        }
        
        
    }
    
    @IBAction func switchAction(_ sender: AnyObject) {
        if hasMedia.isOn {
            self.postImageView.isHidden = false
        }else {
            self.postImageView.isHidden = true

        }
    }
}

