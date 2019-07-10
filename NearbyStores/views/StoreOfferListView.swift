//
//  StoreOfferListView.swift
//  NearbyStores
//
//  Created by Amine on 7/4/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

protocol StoreOfferDelegate {
    func onPress(object: Offer)
    func loadMore(view: StoreOfferListView)
}

class StoreOfferListView: UIView {
    
    var delegate: StoreOfferDelegate? = nil
    var list:[Offer] = []
    
    var calculatedHeight = CGFloat(0)
    
    func addItemLoadMore() {
        
        let viewMoreBtn = UIButton(
            frame: CGRect(x: 0, y: calculatedHeight, width: self.frame.width, height: 40)
        )
        
        
        self.addSubview(viewMoreBtn)
        
        viewMoreBtn.setTitle( "Show More Offers".localized, for: .normal)
        viewMoreBtn.setTitleColor(Colors.primaryColor, for: .normal)
        viewMoreBtn.useFontRegular()
        viewMoreBtn.backgroundColor = UIColor.white
        
        let underLineAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor : Colors.primaryColor,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]
        
        if let str = viewMoreBtn.titleLabel?.text {
            let attributeString = NSMutableAttributedString(string: str,
                attributes: underLineAttributes)
            viewMoreBtn.setAttributedTitle(attributeString, for: .normal)
        }
        
       
        
        viewMoreBtn.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(
            item: viewMoreBtn,
            attribute: NSLayoutAttribute.right,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.right,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: viewMoreBtn,
            attribute: NSLayoutAttribute.left,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.left,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: viewMoreBtn,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.top,
            multiplier: 1, constant: calculatedHeight-1)
        )
        
        constraints.append(NSLayoutConstraint(
            item: viewMoreBtn,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1, constant: 0)
        )
        
        self.addConstraints(constraints)
        
        
        viewMoreBtn.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
        calculatedHeight += viewMoreBtn.frame.height

        viewMoreBtn.addTarget(self, action:#selector(handleActionMore), for: .touchUpInside)
        
    }
    
    @objc func handleActionMore()  {
        
        if let delegate = self.delegate {
            delegate.loadMore(view: self)
        }
    }
    
   
    
    func addItem(object: Offer,action: @escaping (Offer) -> ()) {
        
        let layout:StoreOfferView = UINib(nibName: "MyStoreOfferView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! StoreOfferView
        
        
        UIView.animate(withDuration: 0.15) { () -> Void in
            self.addSubview(layout)
        }
        
        layout.settings()
        layout.setup(object: object)
        
        //add constraints
        layout.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(
            item: layout,
            attribute: NSLayoutAttribute.right,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.right,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: layout,
            attribute: NSLayoutAttribute.left,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.left,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: layout,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.top,
            multiplier: 1, constant: calculatedHeight)
        )
        
        
        constraints.append(NSLayoutConstraint(
            item: layout,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1, constant: 0)
        )
        
        self.addConstraints(constraints)
    
        
        calculatedHeight += layout.container.frame.height
        
        list.append(object)
        layout.itemBtn.tag = list.count-1
        layout.itemBtn.addTarget(self, action:#selector(handleActionItemPress), for: .touchUpInside)
        
        
        let frame = layout.frame
        let lframe = CGRect(x: frame.origin.x, y: frame.origin.y, width: self.frame.width, height: layout.container.frame.height)
        
        layout.frame = lframe
        
//        Utils.printDebug(" width from layout ==> \(layout.frame.height)")
//        Utils.printDebug(" width from layout container ==> \(layout.container.frame.height)")
//        Utils.printDebug(" width from listview ==> \(self.frame.height)")
//
      
    }
    
    @objc func handleActionItemPress(sender: UIButton) {
        
        if let delegate = self.delegate{
            delegate.onPress(object: self.list[sender.tag])
        }
    }
    

    func setPosition(parent: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.right,
            relatedBy: NSLayoutRelation.equal,
            toItem: parent,
            attribute: NSLayoutAttribute.right,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: parent,
            attribute: NSLayoutAttribute.top,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.greaterThanOrEqual,
            toItem: parent,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.left,
            relatedBy: NSLayoutRelation.equal,
            toItem: parent,
            attribute: NSLayoutAttribute.left,
            multiplier: 1, constant: 0)
        )
        
        
        parent.addConstraints(constraints)
        
    }
    
    func instanceFromNib(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    
    func clear() {
        list = []
        for view in self.subviews {
            view.removeFromSuperview()
        }
        self.layoutIfNeeded()
        calculatedHeight = 0
    }
    
}




