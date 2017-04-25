//
//  SearchResultTableCell.swift
//  Beyound
//
//  Created by Elder Santos on 25/04/17.
//  Copyright © 2017 beyound. All rights reserved.
//

import UIKit

class SearchResultTableCell: UITableViewCell {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelWords: UILabel!
    @IBOutlet weak var labelRangeRatio: UILabel!
    @IBOutlet weak var labelFollow: UILabel!
    @IBOutlet weak var labelUser: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageProfile.layer.cornerRadius = 54
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
