//
//  UserServiceModel.swift
//  XMPP
//
//  Created by Ranjit singh on 4/21/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit
var userDo = [UsersDo]()

class UserServiceModel: BaseServiceModel {
    
    init(apiCallback:APIModelCallback) {
        super.init();
        self.apiCallback=apiCallback;
    }
    
    func setAPICallback(_ apiCallback:APIModelCallback)
    {
        self.apiCallback=apiCallback;
    }
    
//*******************xMPPMessageCallback*******************************
    
    init(xMPPMessageCallback:XMPPMessageCallback) {
        super.init();
        self.xMPPMessageCallback=xMPPMessageCallback;
    }
    
    func setxMPPMessageCallback(xMPPMessageCallback:XMPPMessageCallback)
    {
        self.xMPPMessageCallback = xMPPMessageCallback
    }
    
    func signup(_ name:String, username:String, password:String, email:String, json:[String : AnyObject]){
        //let params = ["data":json
        let url = URLConstants.BASE_URL + URLConstants.SIGNUP_URL;
        let apiHandler = APIHandler(apiHandlerCallback:self)
        
        let headers = ["Authorization":StringConstant.OF_SECRET_KEY,"Content-Type":"application/json"]
        print(">>UserServiceModel >>HEADERS= \(headers)")
        
        apiHandler.requstAPI(RequestConstants.REQUEST_FOR_SIGNUP, url: url, methodType: .post, headers: headers, parameters: json)
    }
    
    func getUsers(){
        //URLConstants.user = username
        let url = URLConstants.BASE_URL + URLConstants.SIGIN_URL;
        print("GET User Api = ",url)
        let apiHandler = APIHandler(apiHandlerCallback:self)
        apiHandler.needHeaders = true;
        let headers = ["Authorization":StringConstant.OF_SECRET_KEY, "Accept":"application/json"]
        apiHandler.requstAPI(RequestConstants.REQUEST_FOR_LOGIN, url: url, methodType: .get, headers: headers, parameters: nil)
    }
    
    
    override func onAPIHandlerResponse(_ requestId: Int, isSuccess: Bool, result: NSDictionary?, errorString: String) {
        switch requestId {
        case RequestConstants.REQUEST_FOR_SIGNUP:onSignupResponse(isSuccess, result: result, errorString: errorString)
        break;
            
        case RequestConstants.REQUEST_FOR_LOGIN:onSigninResponse(isSuccess, result: result, errorString: errorString)
        try! insertIntoUserTable(usersDoList: userDo)
        break;
            
        default:
            break;
        }
    }
    
    
    
    /**
     *
     */
    func onSignupResponse(_ isSuccess: Bool, result: NSDictionary?, errorString: String)
    {
        if(isSuccess)
        {
            self.apiCallback!.onAPIResponse(RequestConstants.REQUEST_FOR_SIGNUP, isSuccess: true, responseObject: "" as AnyObject, errorString: errorString)
            
            print("Signup Success !!!")
            
        }else{
            
            self.apiCallback!.onAPIResponse(RequestConstants.REQUEST_FOR_SIGNUP, isSuccess: false, responseObject: "" as AnyObject, errorString: errorString)
        }
    }
    
    /**
     *
     */
    func onSigninResponse(_ isSuccess: Bool, result: NSDictionary?, errorString: String)
    {
        if(result != nil)
        {
            if(isSuccess)
            {
                let array = result as? [String : AnyObject]
                let objs = array?["user"] as? [[String : AnyObject]]
                //let objs = result!["user"]as!NSArray
                let username = SharedPref().get("username")
             
                
                //print("User name: ",username as! [AnyObject])
                
                for opponent in objs! {0
                    //  print(opponent["username"])
                    
                    if opponent["username"] as? String != username as? String{
                        userDo.append(UsersDo(json: opponent as NSDictionary))
                    }
                    
                    
                }
                
                self.apiCallback!.onAPIResponse(RequestConstants.REQUEST_FOR_LOGIN, isSuccess: true, responseObject: "" as AnyObject, errorString: errorString)
                print("Success !!!")
                
            }else{
                
                self.apiCallback!.onAPIResponse(RequestConstants.REQUEST_FOR_LOGIN, isSuccess: false, responseObject: "" as AnyObject, errorString: errorString)
            }
        }else{
            self.apiCallback!.onAPIResponse(RequestConstants.REQUEST_FOR_LOGIN, isSuccess: false, responseObject: "" as AnyObject, errorString: errorString)
        }
    }
}
