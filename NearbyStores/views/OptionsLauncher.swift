//
//  OptionsLauncher.swift
//  NearbyStores
//
//  Created by Amine on 6/29/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons
import AssistantKit


protocol OptionsDelegate {
    func onOptionItemPressed(option: Option)
}

class Option: NSObject {
    let name: String
    let image: UIImage
    let id: Int
    var object: Any? = nil
    
    init(id: Int,name: String, image: UIImage) {
        self.name = name
        self.image = image
        self.id = id
        self.object = nil
    }
    
    init(id: Int,name: String, image: UIImage, object: Any) {
        self.name = name
        self.image = image
        self.id = id
        self.object = object
    }
}

class OptionsLauncher: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var delegate: OptionsDelegate? = nil
    
    let blackView = UIView()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.clear
        return cv
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 50
    
    var options: [Option] = {
        return []
    }()
    
    
    func clear() {
        
        options = []
        index = 0
        
    }
    
    func load() {
        
        collectionView.reloadData()
        
    }
    
    func showOptions() {
        //show menu
        
        if let window = UIApplication.shared.keyWindow {
            
            blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
            
            blackView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
            
            window.addSubview(blackView)
            
            window.addSubview(collectionView)
            
            let height: CGFloat = CGFloat(options.count) * cellHeight
            let y = window.frame.height - height
            
            collectionView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.collectionView.frame = CGRect(x: 0, y: y, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }, completion: nil)
        }
    }
    
    @objc func handleDismiss(option: Option) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                
                self.collectionView.frame = CGRect(x: 0, y: window.frame.height, width: self.collectionView.frame.width, height: self.collectionView.frame.height)
                
            }
            
        }) { (completed: Bool) in
            if let delegate = self.delegate {
                delegate.onOptionItemPressed(option: option)
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return options.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath as IndexPath) as! OptionCell
        
        let option = options[indexPath.item]
        cell.option = option
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        if Device.isPhone{
            return CGSize(width: collectionView.frame.width,height: cellHeight)
        }else if Device.isPad{
            return CGSize(width: collectionView.frame.width/1.5,height: cellHeight)
        }else{
            return CGSize(width: collectionView.frame.width,height: cellHeight)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let option = self.options[indexPath.item]
        handleDismiss(option: option)
    }
    
    override init() {
        super.init()
        
        self.index = 0
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(OptionCell.self, forCellWithReuseIdentifier: cellId)
        
        
        
        //load()
        
        
        
        
        
    }
    
    
    
    var index = 0
    func addBottomMenuItem(option: Option)  {
        self.options.insert(option, at: index)
        index += 1
    }
    
    func createIcon(_ icon: FontType) -> UIImage {
        return UIImage.init(icon: icon, size: CGSize(width: 25, height: 25), textColor: UIColor.darkGray)
    }
    
    
    
}

class OptionCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.darkGray : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            iconImageView.tintColor = isHighlighted ? UIColor.white: UIColor.darkGray
        }
    }
    
    var option: Option? {
        didSet {
            nameLabel.text = option?.name
            
          
            if let image = option?.image {
                iconImageView.image = image
                iconImageView.tintColor = UIColor.darkGray
            }
        }
    }
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Option"
        label.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 15)
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "options")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        
        backgroundColor = UIColor.white
        
        
        addSubview(nameLabel)
        addSubview(iconImageView)
        
        
        addConstraintsWithFormat(format: "H:|-8-[v0(30)]-8-[v1]|", views: iconImageView, nameLabel)
        
        addConstraintsWithFormat(format: "V:|[v0]|", views: nameLabel)
        
        addConstraintsWithFormat(format: "V:[v0(30)]", views: iconImageView)
        
        addConstraint(NSLayoutConstraint(item: iconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
}
