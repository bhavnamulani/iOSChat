//
//  APIHandlerCallback.swift
//  XMPP
//
//  Created by ranjit singh on 4/18/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import Foundation
import UIKit

protocol APIHandlerCallback {
    func onAPIHandlerResponse(_ requestId:Int,isSuccess:Bool,result:NSDictionary?, errorString: String)
    
    }
