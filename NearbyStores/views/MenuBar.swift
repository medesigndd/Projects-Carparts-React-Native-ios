//
//  MenuBar.swift
//  NearbyStores
//
//  Created by Amine on 5/29/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons
import BadgeSwift


protocol MenuBarDelegate:class  {
    //func successUtf8(data: String)
    func scrollToMenuIndex(index: Int)
}

class MenuBar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    var delegate: MenuBarDelegate? = nil
    
    func setDelegate(context: MenuBarDelegate) {
        delegate = context
    }
    
    var badgeCount = 0
    func refreshBadge(at: IndexPath, count: Int,current: Int) {
        
        
        badgeCount = count
        collectionView.reloadItems(at: [at])
        
        //collectionView.selectItem(at: current, animated: true, scrollPosition: .left)
       
    }
    
    func refreshBadge(at: IndexPath, count: Int,current: IndexPath) {
        
        
        badgeCount = count
        collectionView.reloadItems(at: [at])
        
        collectionView.selectItem(at: current, animated: true, scrollPosition: .left)
        
    }
    
    
   
   
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = Colors.primaryColor
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    let cellId = "cellId"
   
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        let selectedIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: selectedIndexPath, animated: false, scrollPosition: .right)
        
        setupHorizontalBar()
    }
    
    
    var horizontalBarLeftRightAnchorConstraint: NSLayoutConstraint?
   
    
    func setupHorizontalBar() {
        
        let horizontalBarView = UIView()
        horizontalBarView.backgroundColor = Colors.white
        addSubview(horizontalBarView)
        

        horizontalBarView.translatesAutoresizingMaskIntoConstraints = false
       
      
        let nbrtabs = CGFloat(AppConfig.Tabs.Pages.count)
       
        horizontalBarLeftRightAnchorConstraint = horizontalBarView.leftAnchor.constraint(equalTo: self.leftAnchor)
        horizontalBarLeftRightAnchorConstraint?.isActive = true
        
        horizontalBarView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1/nbrtabs).isActive = true
        horizontalBarView.heightAnchor.constraint(equalToConstant: 3).isActive = true
        horizontalBarView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let x = CGFloat(indexPath.item) * frame.width / CGFloat(AppConfig.Tabs.Pages.count)
        horizontalBarLeftRightAnchorConstraint?.constant = x
        
       
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.layoutIfNeeded()
        }, completion: nil)
        
    
        if let deleg = delegate {
            deleg.scrollToMenuIndex(index: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(AppConfig.Tabs.Pages.count)
    }
    
  
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        
        let index = AppConfig.Tabs.Pages[indexPath.item]
        let tabicon = AppConfig.Tabs.TabIcons[index]
        
        let icon = UIImage.init(icon: tabicon!, size: CGSize(width: 35, height: 35), textColor: Colors.darkIconColor)
        
        cell.imageView.image = icon.withRenderingMode(.alwaysTemplate)
        
        if AppConfig.Tabs.Pages[indexPath.item]
            == AppConfig.Tabs.Tags.TAG_INBOX{
            
            cell.refreshBadge(count: self.badgeCount)
            
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let count = CGFloat(AppConfig.Tabs.Pages.count)
        return CGSize(width: frame.width / count, height: frame.height)
    }

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}




class MenuCell: BaseCell {
    
    var notification = 0
    var badge: BadgeSwift? = nil
    
    
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        //iv.image = UIImage(named: "home")?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = Colors.darkColor
        return iv
    }()
    
    override var isHighlighted: Bool {
        didSet {
            imageView.tintColor = isHighlighted ? UIColor.white : Colors.darkIconColor
        }
    }
    
    override var isSelected: Bool {
        didSet {
            imageView.tintColor = isSelected ? UIColor.white : Colors.darkIconColor
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addConstraintsWithFormat(format: "H:[v0(35)]", views: imageView)
        addConstraintsWithFormat(format: "V:[v0(35)]", views: imageView)
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        if  self.badge == nil {
            self.badge = setupBadge()
            self.badge?.isHidden = true
        }
        
        
    }
    
    
    func refreshBadge(count: Int) {
        self.notification = count
        if let badge = self.badge {
            if notification == 0 {
                badge.isHidden = true
            }else{
                badge.text = "\(notification)"
                badge.isHidden = false
                
            }
        }
    }
    
    
    func setupBadge() -> BadgeSwift {
        
        let badge = BadgeSwift()
        self.addSubview(badge)
        
        // Text
        badge.text = "0"
        
        
        // Insets
        badge.insets = CGSize(width: 4, height: 4)
        
        // Font
        badge.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        badge.font = badge.font.withSize(10)
        
        // Text color
        badge.textColor = Colors.primaryColor
        
        // Badge color
        badge.badgeColor = UIColor.white
        
        // No shadow
        badge.shadowOpacityBadge = 0
        
        badge.borderWidth = 2
        badge.borderColor = Colors.primaryColor
        
        positionBadge(badge)
        
        return badge
    }
    
    private func positionBadge(_ badge: UIView) {
        badge.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(
            item: badge,
            attribute: NSLayoutAttribute.right,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.right,
            multiplier: 1, constant: -20)
        )
        
        constraints.append(NSLayoutConstraint(
            item: badge,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: self,
            attribute: NSLayoutAttribute.top,
            multiplier: 1, constant: 0)
        )
        
        self.addConstraints(constraints)
    }
    
}

