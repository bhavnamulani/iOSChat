//
//  LGStretchyTextView.swift
//  XMPP
//
//  Created by Ranjit singh on 4/17/17.
//  Copyright © 2017 Shubhank. All rights reserved.
//

import UIKit

// MARK: Text View
//********************************************************************************
@objc protocol LGStretchyTextViewDelegate {
    func stretchyTextViewDidChangeSize(_ chatInput: LGStretchyTextView)
    @objc optional func stretchyTextView(_ textView: LGStretchyTextView, validityDidChange isValid: Bool)
}
//********************************************************************************

class LGStretchyTextView: UITextView, UITextViewDelegate {
    
    // MARK: Delegate
    
    weak var stretchyTextViewDelegate: LGStretchyTextViewDelegate?
    
    // MARK: Public Properties
    
    var maxHeightPortrait: CGFloat = 160
    var maxHeightLandScape: CGFloat = 60
    var maxHeight: CGFloat {
        get {
            return UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) ? maxHeightPortrait : maxHeightLandScape
        }
    }
    // MARK: Private Properties
    
     var maxSize: CGSize {
        get {
            return CGSize(width: self.bounds.width, height: self.maxHeightPortrait)
        }
    }
    
     var isValid: Bool = false {
        didSet {
            if isValid != oldValue {
                stretchyTextViewDelegate?.stretchyTextView?(self, validityDidChange: isValid)
            }
        }
    }
    
     let sizingTextView = UITextView()
    
    // MARK: Property Overrides
    
    override var contentSize: CGSize {
        didSet {
            resize()
        }
    }
    
    override var font: UIFont! {
        didSet {
            sizingTextView.font = font
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            sizingTextView.textContainerInset = textContainerInset
        }
    }
    
    // MARK: Initializers
    
    override init(frame: CGRect = CGRect.zero, textContainer: NSTextContainer? = nil) {
        super.init(frame: frame, textContainer: textContainer);
        setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup
    
    func setup() {
        font = UIFont.systemFont(ofSize: 17.0)
        textContainerInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        delegate = self
    }
    
    // MARK: Sizing
    
    func resize() {
        bounds.size.height = self.targetHeight()
        stretchyTextViewDelegate?.stretchyTextViewDidChangeSize(self)
    }
    
    func targetHeight() -> CGFloat {
        
        /*
         There is an issue when calling `sizeThatFits` on self that results in really weird drawing issues with aligning line breaks ("\n").  For that reason, we have a textView whose job it is to size the textView. It's excess, but apparently necessary.  If there's been an update to the system and this is no longer necessary, or if you find a better solution. Please remove it and submit a pull request as I'd rather not have it.
         */
        
        sizingTextView.text = self.text
        let targetSize = sizingTextView.sizeThatFits(maxSize)
        let targetHeight = targetSize.height
        let maxHeight = self.maxHeight
        return targetHeight < maxHeight ? targetHeight : maxHeight
    }
    
    // MARK: Alignment
    
    func align() {
        guard let end = self.selectedTextRange?.end, let caretRect: CGRect = self.caretRect(for: end) else { return }
        
        let topOfLine = caretRect.minY
        let bottomOfLine = caretRect.maxY
        
        let contentOffsetTop = self.contentOffset.y
        let bottomOfVisibleTextArea = contentOffsetTop + self.bounds.height
        
        /*
         If the caretHeight and the inset padding is greater than the total bounds then we are on the first line and aligning will cause bouncing.
         */
        
        let caretHeightPlusInsets = caretRect.height + self.textContainerInset.top + self.textContainerInset.bottom
        if caretHeightPlusInsets < self.bounds.height {
            var overflow: CGFloat = 0.0
            if topOfLine < contentOffsetTop + self.textContainerInset.top {
                overflow = topOfLine - contentOffsetTop - self.textContainerInset.top
            } else if bottomOfLine > bottomOfVisibleTextArea - self.textContainerInset.bottom {
                overflow = (bottomOfLine - bottomOfVisibleTextArea) + self.textContainerInset.bottom
            }
            self.contentOffset.y += overflow
        }
    }
    
    // MARK: UITextViewDelegate
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        self.align()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        // TODO: Possibly filter spaces and newlines
        self.isValid = textView.text.characters.count > 0
    }
}
