//
//  UsersContactTableCell.swift
//  Beyound
//
//  Created by Elder Santos on 18/06/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class UsersContactTableCell: UITableViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelCategory: UILabel!

    @IBOutlet weak var labelAddress: UILabel!
    @IBOutlet weak var labelStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
