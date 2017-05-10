//
//  SwiftExampleViewController.swift
//  XMPP
//
//  Created by Ranjit singh on 4/17/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit

class SwiftExampleViewController: UIViewController, LGChatControllerDelegate {
    
    var userName:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.launchChatController()
    }
    
    //    func stylizeChatInput() {
    //        LGChatInput.Appearance.backgroundColor = <#UIColor#>
    //        LGChatInput.Appearance.includeBlur = <#Bool#>
    //        LGChatInput.Appearance.textViewFont = <#UIFont#>
    //        LGChatInput.Appearance.textViewTextColor = <#UIColor#>
    //        LGChatInput.Appearance.tintColor = <#UIColor#>
    //        LGChatInput.Appearance.textViewBackgroundColor = <#UIColor#>
    //    }
    
    //    func stylizeMessageCell() {
    //        LGChatMessageCell.Appearance.font = <#UIFont#>
    //        LGChatMessageCell.Appearance.opponentColor = <#UIColor#>
    //        LGChatMessageCell.Appearance.userColor = <#UIColor#>
    //    }
    
    
    // MARK: Launch Chat Controller
    
    func launchChatController() {
        let chatController = LGChatController()
        chatController.opponentImage = UIImage(named: "User")
        chatController.title = userName
        //let helloWorld = LGChatMessage(content: "Hello World!", sentBy: .User)
        //chatController.messages = [helloWorld]
        chatController.delegate = self
        self.navigationController?.pushViewController(chatController, animated: true)
    }
    
    // MARK: LGChatControllerDelegate
    
    func chatController(_ chatController: LGChatController, didAddNewMessage message: LGChatMessage) {
        print("Did Add Message: \(message.content)")
    }
    
    func shouldChatController(_ chatController: LGChatController, addMessage message: LGChatMessage) -> Bool {
        /*
         Use this space to prevent sending a message, or to alter a message.  For example, you might want to hold a message until its successfully uploaded to a server.
         */
        return true
    }
    
}
