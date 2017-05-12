//
//  APIHandler.swift
//  XMPP
//
//  Created by ranjit singh on 4/18/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

class APIHandler: NSObject {
    
    var apiHandlerCallback: APIHandlerCallback?
    var requestId: Int?
    var needHeaders:Bool = true;
    var url:String?;
    var methodType:HTTPMethod;
    var parameters:[String: AnyObject]?;
    var allowRetryOnError = false;
    var headers:[String: String]?;
    
    
    init(apiHandlerCallback:APIHandlerCallback)
    {
        self.methodType = .get
        super.init()
        self.apiHandlerCallback = apiHandlerCallback;
        
    }
    
    func getMethodType()
    {
        
    }
    
    func requstAPI(_ requestId:Int!, url:String!, methodType:HTTPMethod, headers: [String:String]?, parameters:[String:AnyObject]?)
    {
        self.requestId = requestId;
        self.url = url;
        self.methodType = methodType;
        self.parameters = parameters
        self.headers = headers
        
        Alamofire.request(url, method:self.methodType, parameters:self.parameters, encoding: JSONEncoding.default,headers: headers).responseString {
            response in
            switch response.result {
            case .success(let data):
                //let success = result.objectForKey("success")! as! Bool
                let responseCode = response.response?.statusCode;
                
                print("Response code = \(String(describing: responseCode))")
                if(responseCode! as Int != 200 && responseCode! as Int != 201)
                {
                    self.onAPIFailure(nil,error: "Failed with error code:\(responseCode! as Int)");
                    return;
                }
                print(type(of:data))
                let oppnentData = self.convertToDictionary(text: data)
                let success = true
                
                if(success)
                {
                    //if success form server
                    self.onAPISuccess(oppnentData as NSDictionary?)
                }else{
                    //if not success from server
//                    let response:NSDictionary!=result.objectForKey("data") as! NSDictionary
//                    let error_message = response.objectForKey("error_message")
//                    if(response != nil && response.count>0 && error_message != nil)
//                    {
//                        self.onAPIFailure(result,error: error_message as! String);
//                    }else{
//                        self.onAPIFailure(result,error: "Failed with no message data");
//                    }
                }
                break;
            case .failure(let error):
                self.onAPIFailure(nil ,error: "Error from Server");
                print(error)
            default: break
            }
        }
    }
    
    func onAPISuccess(_ result:NSDictionary?)
    {
        DispatchQueue.main.async(execute: {
            self.apiHandlerCallback!.onAPIHandlerResponse(self.requestId!,isSuccess:true,result:result, errorString: "")
        })
    }
    
    func onAPIFailure(_ result:NSDictionary?,error:String!)
    {
        print(">>APIHandler >>Failure")
        DispatchQueue.main.async(execute: {
            self.apiHandlerCallback!.onAPIHandlerResponse(self.requestId!,isSuccess:false,result: result, errorString: error)
        })
    }
    
    
    
    var errorAlert:UIAlertController!
    func showRetryErrorAlert(_ title:String, body:String)
    {
        if(errorAlert == nil)
        {
            errorAlert = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
            errorAlert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { (action: UIAlertAction!) in
                //                print("Handle Ok logic here")
                
                self.errorAlert.dismiss(animated: true, completion:nil)
                self.errorAlert = nil
                
                self.requstAPI(self.requestId!, url:self.url!, methodType:self.methodType,headers: self.headers, parameters: self.parameters!);
            }))
            
            DispatchQueue.main.async(execute: {
                
                // UIApplication.topViewController()!.presentViewController(self.errorAlert, animated: true, completion: nil)
                
            })
            
        }else{
            self.errorAlert.title = title;
            self.errorAlert.message = body;
            
        }
        
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
}
