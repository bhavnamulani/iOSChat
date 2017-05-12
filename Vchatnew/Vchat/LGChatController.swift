//
//  LGChatController.swift
//  XMPP
//
//  Created by Ranjit singh on 4/17/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit

// MARK: Chat Controller
//********************************************************************************
@objc protocol LGChatControllerDelegate {
    @objc optional func shouldChatController(_ chatController: LGChatController, addMessage message: LGChatMessage) -> Bool
    @objc optional func chatController(_ chatController: LGChatController, didAddNewMessage message: LGChatMessage)
}
var senderFlag = 0
var chatMessages:[MessagesDo] = []
//********************************************************************************

class LGChatController: BaseViewController, UITableViewDelegate, UITableViewDataSource, LGChatInputDelegate, LGChatControllerDelegate, XMPPMessageCallback {
    
    // MARK: Constants
    
     struct Constants {
        static let MessagesSection: Int = 0;
        static let MessageCellIdentifier: String = "LGChatController.Constants.MessageCellIdentifier"
    }
    
    // MARK: Public Properties
    
    /*!
     Use this to set the messages to be displayed
     */
    var messages: [LGChatMessage] = []
    var opponentImage: UIImage?
    weak var delegate: LGChatControllerDelegate?
    
    // MARK: Private Properties
    
     let sizingCell = LGChatMessageCell()
     let tableView: UITableView = UITableView()
     let chatInput = LGChatInput(frame: CGRect.zero)
     var bottomChatInputConstraint: NSLayoutConstraint!
    
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        //self.launchChatController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //initiate xMPPMessageCallback
        xmppManager.load(self)
        self.listenForKeyboardChanges()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.scrollToBottom()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.unregisterKeyboardObservers()
    }
    
    deinit {
        /*
         Need to remove delegate and datasource or they will try to send scrollView messages.
         */
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
    }
    
    //************************Procedures of sending massage*************************************
    // MARK: New messages
    
    func addNewMessage(_ message: LGChatMessage) {
        messages += [message]
        tableView.reloadData()
        self.scrollToBottom()
        self.delegate = self
        self.delegate?.chatController?(self, didAddNewMessage: message)
    }
    
    //this will send msg
    func chatController(_ chatController: LGChatController, didAddNewMessage message: LGChatMessage) {
        print("Did Add Message: \(message.content)")
        //xmppManager.sendMessage(self.title!, message:message.content)
    }
    
//    func shouldChatController(_ chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
//        /*
//         Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
//         */
//        message.sentByString = senderFlag == 0 ? LGChatMessage.SentByOpponentString() : LGChatMessage.SentByUserString()
//        //message.sentByString = arc4random_uniform(2) == 0 ? [LGChatMessage SentByOpponentString] : [LGChatMessage SentByUserString];
//        return true
//    }
    
    // MARK: SwiftChatInputDelegate
    
    func chatInputDidResize(_ chatInput: LGChatInput) {
        self.scrollToBottom()
    }
    
    func chatInput(_ chatInput: LGChatInput, didSendMessage message: String) {
        
        xmppManager.sendMessage(self.title!, message:message)
//        let newMessage = LGChatMessage(content: message, sentBy:.User)
//        
//        var shouldSendMessage = true
//        if let value = self.delegate?.shouldChatController?(self, addMessage: newMessage) {
//            shouldSendMessage = value
//        }
//        
//        if shouldSendMessage {
//            self.addNewMessage(newMessage)
//        }
    }
    
    override func onXMPPMessageResponse(_ senderUserName:String,message:String){
        print(senderUserName)
        print(message)
        
        var newMessage = LGChatMessage(content: message, sentBy:.User)
        
        if senderUserName == "User"{
            newMessage = LGChatMessage(content: message, sentBy:.User)
        }
        else{
            newMessage = LGChatMessage(content: message, sentBy:.Opponent)
        }
        
        var shouldSendMessage = true
        if let value = self.delegate?.shouldChatController?(self, addMessage: newMessage) {
            shouldSendMessage = value
        }
        
        if shouldSendMessage {
            self.addNewMessage(newMessage)
        }

        
    }
    //*************************************************************
    
    // MARK: UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let padding: CGFloat = 10.0
        sizingCell.bounds.size.width = self.view.bounds.width
        let height = self.sizingCell.setupWithMessage(messages[indexPath.row]).height + padding;
        return height
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            self.chatInput.textView.resignFirstResponder()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "identifier", for: indexPath) as! LGChatMessageCell
        let message = self.messages[indexPath.row]
        cell.opponentImageView.image = message.sentBy == .Opponent ? self.opponentImage : nil
        cell.setupWithMessage(message)
        return cell;
    }
    
    // MARK: Setup
    
    func setup() {
        self.setupTableView()
        self.setupChatInput()
        self.setupLayoutConstraints()
    }
    
    func setupTableView() {
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.frame = self.view.bounds
        tableView.register(LGChatMessageCell.classForCoder(), forCellReuseIdentifier: "identifier")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        self.view.addSubview(tableView)
    }
    
    func setupChatInput() {
        chatInput.delegate = self
        self.view.addSubview(chatInput)
    }
    
    func setupLayoutConstraints() {
        chatInput.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(self.chatInputConstraints())
        self.view.addConstraints(self.tableViewConstraints())
    }
    
    func chatInputConstraints() -> [NSLayoutConstraint] {
        self.bottomChatInputConstraint = NSLayoutConstraint(item: chatInput, attribute: .bottom, relatedBy: .equal, toItem: self.bottomLayoutGuide, attribute: .top, multiplier: 1.0, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: chatInput, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: chatInput, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
        return [leftConstraint, self.bottomChatInputConstraint, rightConstraint]
    }
    
    func tableViewConstraints() -> [NSLayoutConstraint] {
        let leftConstraint = NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self.view, attribute: .left, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self.view, attribute: .right, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: chatInput, attribute: .top, multiplier: 1.0, constant: 0)
        return [rightConstraint, leftConstraint, topConstraint, bottomConstraint]//, rightConstraint, bottomConstraint]
    }
    
    // MARK: Keyboard Notifications
    
    func listenForKeyboardChanges() {
        let defaultCenter = NotificationCenter.default
        defaultCenter.addObserver(self, selector: #selector(LGChatController.keyboardWillChangeFrame(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    func unregisterKeyboardObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillChangeFrame(_ note: Notification) {
        let keyboardAnimationDetail = note.userInfo!
        let duration = keyboardAnimationDetail[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        var keyboardFrame = (keyboardAnimationDetail[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        if let window = self.view.window {
            keyboardFrame = window.convert(keyboardFrame, to: self.view)
        }
        let animationCurve = keyboardAnimationDetail[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        
        self.tableView.isScrollEnabled = false
        self.tableView.decelerationRate = UIScrollViewDecelerationRateFast
        self.view.layoutIfNeeded()
        var chatInputOffset = -((self.view.bounds.height - self.bottomLayoutGuide.length) - keyboardFrame.minY)
        if chatInputOffset > 0 {
            chatInputOffset = 0
        }
        self.bottomChatInputConstraint.constant = chatInputOffset
        UIView.animate(withDuration: duration, delay: 0.0, options: UIViewAnimationOptions(rawValue: animationCurve), animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.scrollToBottom()
        }, completion: {(finished) -> () in
            self.tableView.isScrollEnabled = true
            self.tableView.decelerationRate = UIScrollViewDecelerationRateNormal
        })
    }
    
    // MARK: Rotation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (_) in
            self.tableView.reloadData()
        }) { (_) in
            UIView.animate(withDuration: 0.25, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
                self.scrollToBottom()
            }, completion: nil)
        }
        
    }
    
    // MARK: Scrolling
    
    func scrollToBottom() {
        if messages.count > 0 {
            var lastItemIdx = self.tableView.numberOfRows(inSection: Constants.MessagesSection) - 1
            if lastItemIdx < 0 {
                lastItemIdx = 0
            }
            let lastIndexPath = IndexPath(row: lastItemIdx, section: Constants.MessagesSection)
            self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
        }
    }
}
