//
//  SharedPref.swift
//  XMPP
//
//  Created by ranjit singh on 4/18/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import Foundation
class SharedPref
{
    //to save user specific info
    //static let KEY_AUTH_TOKEN = "KEY_AUTH_TOKEN";
    
    func put(_ key:String, value:AnyObject!)
    {
        let userDefaults = UserDefaults.standard
        print(key, value)
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    
    func get(_ key:String) ->AnyObject!{
        print(key)
        return UserDefaults.standard.object(forKey: key) as AnyObject;
        
    }
    
    // method to clear all the values from shared pref. called on logout
    func clearSharedPref()
    {
        let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
    }
    
    
}
