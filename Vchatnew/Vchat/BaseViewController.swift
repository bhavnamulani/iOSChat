//
//  BaseViewController.swift
//  XMPP
//
//  Created by ranjit singh on 4/18/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, APIModelCallback {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func onAPIResponse(_ requestId:Int,isSuccess:Bool,responseObject:AnyObject?,errorString:String?){
     
    }
    
    func onXMPPMessageResponse(_ senderUserName:String,message:String){
        
    }
}
