//
//  ModelFacade.swift
//  XMPP
//
//  Created by ranjit singh on 4/18/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit

class ModelFacade: NSObject {
    
    
    var localModel:LocalModel
    
    var remoteModel:RemoteModel
    
    // intialize all your member variables here.
    override init()
    {
        self.localModel = LocalModel()
        self.remoteModel = RemoteModel()
    }
    
}
