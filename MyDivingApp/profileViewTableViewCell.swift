//
//  profileViewTableViewCell.swift
//  MyDivingApp
//
//  Created by aman on 15/5/2024.
//

import UIKit

class profileViewTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBOutlet weak var username: UILabel!
    
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var profilePhoto: UIImageView!
    
}
