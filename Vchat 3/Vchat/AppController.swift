//
//  AppController.swift
//  Vchat
//
//  Created by ranjit singh on 5/2/17.
//  Copyright © 2017 ranjit singh. All rights reserved.
//

import UIKit
import Foundation

class AppController: NSObject {
    
    
    var modelFacade:ModelFacade
    var window: UIWindow?
    
    
    static let sharedInstance = AppController()
    fileprivate override init() {
        
        self.modelFacade = ModelFacade()
        
    } //This prevents others from using the default '()' initializer for this class.
    

    


}
