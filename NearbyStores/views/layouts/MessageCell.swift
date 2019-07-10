//
//  MessageSenderCell.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class MessageCell: UICollectionViewCell {

    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        setNeedsLayout()
//        layoutIfNeeded()
//        let size = contentView.systemLayoutSizeFitting(layoutAttributes.size)
//        var frame = layoutAttributes.frame
//        frame.size.height = ceil(size.height)
//        layoutAttributes.frame = frame
//        return layoutAttributes
//    }
    
    
    @IBOutlet weak var containerMessage: UIView!
    @IBOutlet weak var messageView: EdgeLabel!

    @IBOutlet weak var messageConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var messageConstraintWidth: NSLayoutConstraint!
    
    @IBOutlet weak var messageConstraintTop: NSLayoutConstraint!
    @IBOutlet weak var messageConstraintLeft: NSLayoutConstraint!
    
    @IBOutlet weak var messageConstraintRight: NSLayoutConstraint!
    
    
    @IBOutlet weak var containerConstraintWith: NSLayoutConstraint!
    
    
    
    @IBOutlet weak var dateConstraintLeft: NSLayoutConstraint!
    
     @IBOutlet weak var dateView: UILabel!
    
    
    func setup(frame: CGRect, object: Message )  {
        
        self.containerConstraintWith.constant = UIScreen.main.bounds.size.width
    
        self.messageView.font = UIFont.systemFont(ofSize: 15)
        self.messageView.layer.masksToBounds = false
        
        //self.messageView.sizeToFit()
    
        
        self.messageView.backgroundColor = Colors.highlightedGray
        self.messageView.layer.masksToBounds = false
        self.messageView.layer.cornerRadius = 4
        self.messageView.clipsToBounds = true
       // self.messageView.backgroundColor = UIColor.clear
        
        
        self.setup(object: object)
        self.setupLayout(frame: frame,object: object)
      
    }
    
    
    
    func setup(object: Message)  {
        
        messageView.text = object.message
        dateView.text = DateUtils.getPreparedDateDT(dateUTC: object.date)
        
        if object.type == Message.Values.SENDER_VIEW {
        
            //colors
            self.messageView.backgroundColor = Colors.primaryColor
            self.messageView.textColor = Colors.white
            self.dateView.textAlignment = .right
            
        }else{
            
            self.messageView.backgroundColor = Colors.highlightedGray
            self.messageView.textColor = Colors.black
            self.dateView.textAlignment = .left
            
        }
        
        
        if object.status == Message.Values.NO_SENT {
            messageView.backgroundColor = messageView.backgroundColor?.withAlphaComponent(0.8)
        }else{
            messageView.backgroundColor = messageView.backgroundColor?.withAlphaComponent(1.0)
        }
        
        
        if object.type == Message.Values.SENDER_VIEW {
            
            messageConstraintLeft.priority = UILayoutPriority(rawValue: 250)
            messageConstraintLeft.constant = 8
            
            messageConstraintRight.priority = UILayoutPriority(rawValue: 750)
            messageConstraintRight.constant = 8
            
        }else{
            
            messageConstraintLeft.priority = UILayoutPriority(rawValue: 750)
            messageConstraintLeft.constant = 8
            
            messageConstraintRight.priority = UILayoutPriority(rawValue: 250)
            messageConstraintRight.constant = 8
            
        }
        
        
        
        self.messageView.leftTextInset = 15
        self.messageView.rightTextInset = 15
        self.messageView.topTextInset = 8
        self.messageView.bottomTextInset = 8
        
        
    }
    
    func setupLayout(frame: CGRect, object: Message ) {
        
        
        //messageConstraintHeight.constant = 50
        messageConstraintTop.constant = 1.0
        
        
       
        if object.message != "" {
          
            
            let size = CGSize(width: 300, height: 20)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            
            let estimatedFrame = NSString(string:  object.message).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], context: nil)
            
            
            Utils.printDebug("estimatedFrame_cell: \(estimatedFrame)")

          
            
        }
        
       
        
        
    }

}
