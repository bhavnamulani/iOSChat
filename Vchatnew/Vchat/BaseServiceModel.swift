//
//  BaseServiceModel.swift
//  XMPP
//
//  Created by ranjit singh on 4/18/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit

class BaseServiceModel: NSObject, APIHandlerCallback {
    
    var apiCallback: APIModelCallback?
    
    
    func onAPIHandlerResponse(_ requestId: Int, isSuccess: Bool, result: NSDictionary?, errorString: String) {
        switch requestId {
        default:
            break;
        }
    }
    var xMPPMessageCallback: XMPPMessageCallback?
    
}
