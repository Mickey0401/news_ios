//
//  MessageTextView.swift
//  Havr
//
//  Created by Lindi on 4/1/17.
//  Copyright © 2017 TENTON. All rights reserved.
//

import UIKit

protocol MessageTextViewDelegate : class {
    func messageTextView(sender: MessageTextView, changed height: CGFloat)
}
class MessageTextView: UITextView {

    weak var delegateMessage: MessageTextViewDelegate?
    
    // Maximum length of text. 0 means no limit.
    @IBInspectable open var maxLength: Int = 0
    
    // Trim white space and newline characters when end editing. Default is true
    @IBInspectable open var trimWhiteSpaceWhenEndEditing: Bool = true
    
    // Maximm height of the textview
    @IBInspectable open var maxHeight: CGFloat = CGFloat(0)
    
    // Placeholder properties
    // Need to set both placeHolder and placeHolderColor in order to show placeHolder in the textview
    @IBInspectable open var placeHolder: NSString? {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable open var placeHolderColor: UIColor = UIColor(white: 0.8, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable open var placeHolderLeftMargin: CGFloat = 5 {
        didSet { setNeedsDisplay() }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override open var text: String! {
        didSet {
            setNeedsDisplay()
        }
    }
    
    // Listen to UITextView notification to handle trimming, placeholder and maximum length
    fileprivate func commonInit() {
        self.contentMode = .redraw
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: NSNotification.Name.UITextViewTextDidChange, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: NSNotification.Name.UITextViewTextDidEndEditing, object: self)
    }
    
    // Calculate height of textview
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        let currentHeight = self.frame.height
        
        let size = sizeThatFits(CGSize(width:bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        var height = size.height
        if maxHeight > 0 {
            height = min(size.height, maxHeight)
        }
        
        if height != currentHeight {
            scrollRangeToVisible(NSMakeRange(0, 0))
            delegateMessage?.messageTextView(sender: self, changed: height)
        }
    }
    
    // Show placeholder
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if text.isEmpty {
            guard let placeHolder = placeHolder else { return }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            
            let rect = CGRect(x: textContainerInset.left + placeHolderLeftMargin,
                              y: textContainerInset.top,
                              width:   frame.size.width - textContainerInset.left - textContainerInset.right,
                              height: frame.size.height)
            
            var attributes: [String: Any] = [
                NSForegroundColorAttributeName: placeHolderColor,
                NSParagraphStyleAttributeName: paragraphStyle
            ]
            if let font = font {
                attributes[NSFontAttributeName] = font
            }
            
            placeHolder.draw(in: rect, withAttributes: attributes)
        }
    }
    
    // Trim white space and new line characters when end editing.
    func textDidEndEditing(notification: Notification) {
        if let notificationObject = notification.object as? MessageTextView {
            if notificationObject === self {
                if trimWhiteSpaceWhenEndEditing {
                    text = text?.trimmingCharacters(in: .whitespacesAndNewlines)
                    setNeedsDisplay()
                }
            }
        }
    }
    
    // Limit the length of text
    func textDidChange(notification: Notification) {
        if let notificationObject = notification.object as? MessageTextView {
            if notificationObject === self {
                if maxLength > 0 && text.count > maxLength {
                    
                    let endIndex = text.index(text.startIndex, offsetBy: maxLength)
                    text = text.substring(to: endIndex)
                    undoManager?.removeAllActions()
                }
                setNeedsDisplay()
            }
        }
    }
    
    // Remove notification observer when deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
