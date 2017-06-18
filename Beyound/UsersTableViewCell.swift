
import UIKit



class UsersTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var buttonEmail: UIButton!

    @IBOutlet weak var buttonPhone: UIButton!
    
    
    @IBAction func sendEmail(_ sender: Any) {
    }
    
    @IBAction func callPhone(_ sender: Any) {
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.layer.cornerRadius = 54

    }

    
}
