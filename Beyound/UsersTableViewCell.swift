
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth


class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var countryLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    var dataBaseRef: FIRDatabaseReference! {
        return FIRDatabase.database().reference()
    }
    
    var storageRef: FIRStorage {
        
        return FIRStorage.storage()
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.layer.cornerRadius = 54

    }

    func configureCell(user: User){
        
        self.emailLabel.text = user.firstLastName
        self.usernameLabel.text = "@" + user.username!
        self.countryLabel.text = user.category!
        
        let imageURL = user.photoURL!
        
        self.storageRef.reference(forURL: imageURL).data(withMaxSize: 1 * 1024 * 1024, completion: { (imgData, error) in
            
            if error == nil {
                DispatchQueue.main.async {
                    if let data = imgData {
                        self.userImageView.image = UIImage(data: data)
                    }
                }
     
            }else {
                print(error!.localizedDescription)
                
            }
            
            
        })
    }
    
}
