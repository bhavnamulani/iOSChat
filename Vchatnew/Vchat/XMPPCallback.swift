//
//  XMPPCallback.swift
//  XMPP
//
//  Created by Ranjit singh on 4/20/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import Foundation

protocol XMPPConnectCallback {
    func onXMPPConnectResponse(_ isSuccess:Bool,message:String,username:String,pwd:String)
}

protocol XMPPMessageCallback {
    func onXMPPMessageResponse(_ senderUserName:String,message:String)
}
