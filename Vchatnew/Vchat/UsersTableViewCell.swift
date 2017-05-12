//
//  UsersTableViewCell.swift
//  XMPP
//
//  Created by Ranjit singh on 4/14/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit

class UsersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usersImageVIew: UIImageView!
    @IBOutlet weak var usersNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
        usersImageVIew.layer.cornerRadius = self.frame.height / 2.5
        usersImageVIew.layer.masksToBounds = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
