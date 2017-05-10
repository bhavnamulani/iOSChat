//
//  UsersDao.swift
//  XMPP
//
//  Created by Ranjit singh on 4/26/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import Foundation
import UIKit
class Opponents {
    
    var name: String?
    var username: String?
    var email: String?
    
    init(json: NSDictionary) {
        self.name = json["username"] as? String
        //self.username = json["username"] as? String
        //self.email = json["email"] as? String
    }
}