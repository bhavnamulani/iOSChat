//
//  LGChatMessageCell.swift
//  XMPP
//
//  Created by Ranjit singh on 4/17/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit

// MARK: Message Cell
class LGChatMessageCell: UITableViewCell {
    
    // MARK: Global MessageCell Appearance Modifier
    
    struct Appearance {
        static var opponentColor = UIColor(red: 0.142954, green: 0.60323, blue: 0.862548, alpha: 0.88)
        static var userColor = UIColor(red: 0.14726, green: 0.838161, blue: 0.533935, alpha: 1)
        static var font: UIFont = UIFont.systemFont(ofSize: 17.0)
    }
    
    /*
     These methods are included for ObjC compatibility.  If using Swift, you can set the Appearance variables directly.
     */
    
//    class func setAppearanceOpponentColor(opponentColor: UIColor) {
//        Appearance.opponentColor = opponentColor
//    }
//    
//    class func setAppearanceUserColor(userColor: UIColor) {
//        Appearance.userColor = userColor
//    }
//    
//    class  func setAppearanceFont(font: UIFont) {
//        Appearance.font = font
//    }
    
    // MARK: Message Bubble TextView
    
    lazy var textView: MessageBubbleTextView = {
        let textView = MessageBubbleTextView(frame: CGRect.zero, textContainer: nil)
        self.contentView.addSubview(textView)
        return textView
    }()
    
    class MessageBubbleTextView : UITextView {
        
        override init(frame: CGRect = CGRect.zero, textContainer: NSTextContainer? = nil) {
            super.init(frame: frame, textContainer: textContainer)
            self.font = Appearance.font
            self.isScrollEnabled = false
            self.isEditable = false
            self.textContainerInset = UIEdgeInsets(top: 7, left: 7, bottom: 7, right: 7)
            self.layer.cornerRadius = 15
            self.layer.borderWidth = 2.0
        }
        
        required init(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    // MARK: ImageView
    
     lazy var opponentImageView: UIImageView = {
        let opponentImageView = UIImageView()
        opponentImageView.isHidden = true
        opponentImageView.bounds.size = CGSize(width: self.minimumHeight, height: self.minimumHeight)
        let halfWidth = opponentImageView.bounds.width / 2.0
        let halfHeight = opponentImageView.bounds.height / 2.0
        
        // Center the imageview vertically to the textView when it is singleLine
        let textViewSingleLineCenter = self.textView.textContainerInset.top + (Appearance.font.lineHeight / 2.0)
        opponentImageView.center = CGPoint(x: self.padding + halfWidth, y: textViewSingleLineCenter)
        opponentImageView.backgroundColor = UIColor.lightText
        opponentImageView.layer.rasterizationScale = UIScreen.main.scale
        opponentImageView.layer.shouldRasterize = true
        opponentImageView.layer.cornerRadius = halfHeight
        opponentImageView.layer.masksToBounds = true
        self.contentView.addSubview(opponentImageView)
        return opponentImageView
    }()
    
    // MARK: Sizing
    
     let padding: CGFloat = 5.0
    
     let minimumHeight: CGFloat = 30.0 // arbitrary minimum height
    
     var size = CGSize.zero
    
     var maxSize: CGSize {
        get {
            let maxWidth = self.bounds.width * 0.75 // Cells can take up to 3/4 of screen
            let maxHeight = CGFloat.greatestFiniteMagnitude
            return CGSize(width: maxWidth, height: maxHeight)
        }
    }
    
    // MARK: Setup Call
    
    /*!
     Use this in cellForRowAtIndexPath to setup the cell.
     */
    func setupWithMessage(_ message: LGChatMessage) -> CGSize {
        textView.text = message.content
        size = textView.sizeThatFits(maxSize)
        if size.height < minimumHeight {
            size.height = minimumHeight
        }
        textView.bounds.size = size
        self.styleTextViewForSentBy(message.sentBy)
        if let color = message.color {
            self.textView.layer.borderColor = color.cgColor
        }
        return size
    }
    
    // MARK: TextBubble Styling
    
     func styleTextViewForSentBy(_ sentBy: LGChatMessage.SentBy) {
        let halfTextViewWidth = self.textView.bounds.width / 2.0
        let targetX = halfTextViewWidth + padding
        let halfTextViewHeight = self.textView.bounds.height / 2.0
        switch sentBy {
        case .Opponent:
            self.textView.center.x = targetX
            self.textView.center.y = halfTextViewHeight
            self.textView.layer.borderColor = Appearance.opponentColor.cgColor
            
            if self.opponentImageView.image != nil {
                self.opponentImageView.isHidden = false
                self.textView.center.x += self.opponentImageView.bounds.width + padding
            }
            
        case .User:
            self.opponentImageView.isHidden = true
            self.textView.center.x = self.bounds.width - targetX
            self.textView.center.y = halfTextViewHeight
            self.textView.layer.borderColor = Appearance.userColor.cgColor
        }
    }
}
