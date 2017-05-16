//
//  XMPPManager.swift
//  Vchat
//
//  Created by ranjit singh on 5/2/17.
//  Copyright © 2017 ranjit singh. All rights reserved.
//

import UIKit
import Foundation
import XMPPFramework

//making object singlton will be used throut the project
var xmppManager:XMPPManager!

class XMPPManager: NSObject,XMPPStreamDelegate {
    
    var xMPPConnectCallback:XMPPConnectCallback?
    var xMPPMessageCallback:XMPPMessageCallback?
    
    var xmppMessageCallbackList = [XMPPMessageCallback]()
    

    
    //We first declare a variable stream of type XMPPStream in global scope
    var xmppStream:XMPPStream!
    let xmppRosterStorage = XMPPRosterCoreDataStorage()
    var xmppRoster: XMPPRoster!
    
    var msgReceived:String = ""
    var password:String = ""
    var username:String = ""
    
    
    init (uid:String, pass:String) {
        super.init()
        self.username = uid
        self.password = pass
        
    }
    
    deinit {
      
    }
    
    func destroy() {
        xmppManager = nil;
    }
    
    func connect(_ xMPPConnectCallback:XMPPConnectCallback) {

        self.xMPPConnectCallback = xMPPConnectCallback
        
        xmppRoster = XMPPRoster(rosterStorage: xmppRosterStorage)
        //xmppRoster.removeUser(XMPPJID.jidWithString(username))
        
        // Do any additional setup after loading the view, typically from a nib.
        xmppStream = XMPPStream()
        
        // Giving Host Name and port number of XMPP server
        xmppStream.hostName = "172.16.1.190";
        xmppStream.hostPort = 5222;
        
        //add the delegate so that we can receive event callbacks for connection successful or any failure
        xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        
        // We will set a JID so that we can uniquely identify our user
        xmppStream.myJID = XMPPJID.init(string: username)
        
        xmppRoster.activate(xmppStream)
        do { try xmppStream.connect(withTimeout: 30) }
        catch { print("error occured in connecting") }
        
    }
    
    /**
     * Initialisation of xMPPMessageCallback
     */
    func load(_ xMPPMessageCallback:XMPPMessageCallback) {
        self.xMPPMessageCallback = xMPPMessageCallback
    }
    
    /**
     * we try to authorize our user with the password
     */
    func xmppStreamDidConnect(_ sender: XMPPStream!) {
        
        print("connected")
        
        do {
            try sender.authenticate(withPassword: password)
        }
        catch {
            //handling server error
            print("catch")
            if(self.xMPPConnectCallback != nil)
            {
                self.xMPPConnectCallback?.onXMPPConnectResponse(false,message: "Server Error",username: username, pwd: password);
            }
        }
        
    }
    
    func xmppStreamWillConnect(_ sender: XMPPStream!) {
        print("will connect")
        
    }
    
    func xmppStreamConnectDidTimeout(_ sender: XMPPStream!) {
        print("timeout:")
        self.xMPPConnectCallback?.onXMPPConnectResponse(false, message: "Connection Timout", username: username, pwd: password)
    }
    
    /**
     * This function will send message
     */
    func sendMessage(_ userId:String, message:String) {
        let opponent = userId+"@test-pc"
        let senderJID = XMPPJID.init(string: opponent)
        let msg = XMPPMessage(type: "chat", to: senderJID)
        
        msg?.addBody(message)
        xmppStream.send(msg)
    }
    
    
    /**
     * This function will handle authentication done or not
     */
    func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        print("auth done")
        if(self.xMPPConnectCallback != nil)
        {
            self.xMPPConnectCallback?.onXMPPConnectResponse(true,message: "Login Successful",username: username, pwd: password)
        }
        sender.send(XMPPPresence())
    }
    
    /**
     * This function will handle if authentication fail due to invalid credintial
     */
    func xmppStream(_ sender: XMPPStream!, didNotAuthenticate error: DDXMLElement!) {
        print("dint not auth")
        if(self.xMPPConnectCallback != nil)
        {
            self.xMPPConnectCallback?.onXMPPConnectResponse(false,message: "Invalid User name or password",username: username, pwd: password);
        }
        print(error)
    }
    
    /**
     * This function will handle avalibility of user
     */
    func xmppStream(_ sender: XMPPStream!, didReceive presence: XMPPPresence!) {
        print(presence)
        let presenceType = presence.type()
        let username = sender.myJID.user
        let presenceFromUser = presence.from().user
        
        if presenceFromUser != username  {
            if presenceType == "available" {
                print("available")
            }
            else if presenceType == "subscribe" {
                self.xmppRoster.subscribePresence(toUser: presence.from())
            }
            else {
                print("presence type");
                print(presenceType!)
            }
        }
        
    }
    
    /**
     * wiil get conformation of sent msg
     */
    func xmppStream(_ sender: XMPPStream!, didSend message: XMPPMessage!) {
        print("sent")
        self.addOutgoingMessages(sender:sender!,messageText:message.body())
    }
    
    
    /**
     *
     */
    func xmppStream(_ sender: XMPPStream!, willReceive message: XMPPMessage!) -> XMPPMessage! {
       print("message received \(message.body()) from ",sender.myJID)
        return message
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive iq: XMPPIQ!) -> Bool {
        return true
    }
    
    func xmppStream(_ sender: XMPPStream!, didFailToSend iq: XMPPIQ!, error: Error!) {
        print("error")
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceiveError error: DDXMLElement!) {
        print("error")
    }
    
    func xmppStream(_ sender: XMPPStream!, didFailToSend message: XMPPMessage!, error: Error!) {
        print("fail to send message")
    }
    
    func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        print("message \(message.body()) send from \(sender)")
        let senderId = String(describing : sender)
        self.msgReceived = message.body()

        
        addIncomingMessages(sender: sender, messageText: message.body())
//        
//        xMPPMessageCallback?.onXMPPMessageResponse(senderId, message: message.body())
//        if xmppMessageCallbackList != nil {
//            for xMPPMessageCallback in xmppMessageCallbackList {
//                xMPPMessageCallback.onXMPPMessageResponse(senderId, message: message.body());
//            }
//        }
    }
    
    func registerXMPPCallback(xmppMessageCallback:XMPPMessageCallback) {
    xmppMessageCallbackList.append(xMPPMessageCallback!)

    }
    
    func unregisterXMPPCallback(xmppMessageCallback:XMPPMessageCallback) {
    xmppMessageCallbackList.remove(at: xMPPMessageCallback as! Int);

    }

    /**
     * On message received
     */
    func addIncomingMessages(sender:XMPPStream!,messageText:String) {
        
        let senderId = String(describing : sender) as AnyObject
        print("SenderID" , senderId)
        var messagesDo:MessagesDo?
        messagesDo = MessagesDo()
        messagesDo?.msgText = messageText
        messagesDo?.sentBy = .Opponent
        messagesDo?.fromUser = senderId as? String
        messagesDo?.toUser = SharedPref().get("username") as? String
         messagesDo?.read = false
        chatMessages.append(messagesDo!)
        print(chatMessages)
        xMPPMessageCallback?.onXMPPMessageResponse("Opponent", message: messageText)
        try!insertIntoMsgTable(messagesDo: messagesDo!)
    }
    
    /**
     * On message sent
     */
    func addOutgoingMessages(sender:XMPPStream!,messageText:String) {
        let senderId = String(describing : sender) as AnyObject
        print("SenderID" , senderId)
        var messagesDo:MessagesDo?
        messagesDo = MessagesDo()
        messagesDo?.msgText = messageText
        messagesDo?.sentBy = .User
        messagesDo?.fromUser = senderId as? String
        messagesDo?.toUser = SharedPref().get("username") as? String
        messagesDo?.read = true

        chatMessages.append(messagesDo!)
        print(chatMessages)
        xMPPMessageCallback?.onXMPPMessageResponse("User", message: messageText)
        try! insertIntoMsgTable(messagesDo: messagesDo!)

    }
}

