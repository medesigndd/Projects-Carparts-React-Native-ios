//
//  AboutViewController.swift
//  NearbyStores
//
//  Created by Amine on 7/17/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Atributika
import AssistantKit

class AboutViewController: MyUIViewController {
    

    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stackview: UIStackView!
    
    @IBOutlet weak var stackViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeftConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var aboutLabel: UILabel!
    
    
    func setupSize()  {
        if Device.isPad{
            let width = self.view.frame.width/1.5
            let finalSize = self.view.frame.width-width
            self.stackViewLeftConstraint.constant = finalSize/2
        }
    }
    
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var aboutTextLabel: AttributedLabel!
    @IBOutlet weak var aboutDetailConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var aboutContainer: UIView!
    @IBOutlet weak var image: UIImageView!
    
    
    @IBOutlet weak var emailContainer: UIView!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var emailBtn: UIButton!
    
    
    @IBOutlet weak var telContainer: UIView!
    @IBOutlet weak var tel: UILabel!
    @IBOutlet weak var telBtn: UIButton!
    
    
    @IBAction func emailAction(_ sender: Any) {
        if AppConfig.About.EMAIL != ""{
            if let url = URL(string: "mailto:\(AppConfig.About.EMAIL)") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    @IBAction func telAction(_ sender: Any) {
        if AppConfig.About.TEL != ""{
            if let url = URL(string: "tel://\(AppConfig.About.TEL)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
    }
    
    @IBOutlet weak var version: UILabel!
    
    let topBarTitle: EdgeLabel = {
        
        let titleLabel = EdgeLabel()
        
        titleLabel.text = ""
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        
        return titleLabel
        
    }()
    
    func setupNavBarTitles() {
        
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = UIColor.white
        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        
        
        
        topBarTitle.text = "About us".localized
        
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    
    func setupNavBarButtons() {
        
        //arrow back icon
        var arrowImage: UIImage? = nil
        if Utils.isRTL(){
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowForward), size: CGSize(width: 30, height: 30), textColor: Colors.darkColor)
        }else{
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowBack), size: CGSize(width: 30, height: 30), textColor: Colors.darkColor)
        }
        
        
        let customBarButtonItem = UIBarButtonItem(image: arrowImage!, style: .plain, target: self, action: #selector(onBackHandler))
        customBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: Colors.white)
        
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        
    }
    
    @objc func onBackHandler()  {
        self.dismiss(animated: true)
    }
    
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSize()
        
        
        aboutLabel.text = "About us".localized
        
        
        self.setupNavBarTitles()
        self.setupNavBarButtons()
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        
        
        self.setupViews()
        self.setupImage()
        
        
        
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        
        self.version.text = "\("Version".localized): "+version
        
    }
    
    
    func setupImage() {
        
        if let img = UIImage(named: "splash_screen") {
            self.image.image = img
        }
    }
    
    
    func setupViews() {
        
        
        self.view.backgroundColor = Colors.highlightedGray
        
        //self.stackview.distribution = .fillProportionally
        
        scrollView.parallaxHeader.view = self.imageContainer
        scrollView.parallaxHeader.height = self.imageView.frame.height;
        scrollView.parallaxHeader.mode = .fill;
        scrollView.parallaxHeader.minimumHeight = 0;
        
        
        let htmlText = AppConfig.About.ABOUT_US.toHtml()
        
        aboutTextLabel.numberOfLines = 90000
        aboutTextLabel.attributedText = htmlText
        aboutTextLabel.sizeToFit()
        
        
        DispatchQueue.main.asyncAfter(wallDeadline: .now()+2) {
            
            let size = CGSize(width: self.aboutTextLabel.frame.width, height: self.aboutTextLabel.frame.height)
            let nsize = self.aboutTextLabel.sizeThatFits(size)
            
            self.aboutTextLabel.attributedText = htmlText
            self.aboutTextLabel.heightAnchor.constraint(equalToConstant: nsize.height).isActive = true
           // self.aboutDetailConstraintHeight.constant = nsize.height+15+15+9+23+10
            
            self.aboutContainer.layoutIfNeeded()
            self.view.layoutIfNeeded()
            
            
        }
        
        
        aboutTextLabel.onClick = { label, detection in
            
            switch detection.type {
            case .link(let url):
                UIApplication.shared.openURL(url)
            default:
                break
            }
        }
        
        
        if AppConfig.About.EMAIL != ""{
            self.emailContainer.isHidden = false
            self.email.text = AppConfig.About.EMAIL
        }else{
            self.emailContainer.isHidden = true
        }
        
        if AppConfig.About.TEL != ""{
            self.telContainer.isHidden = false
            self.tel.text = AppConfig.About.TEL
        }else{
            self.telContainer.isHidden = true
        }
        
        
    }
    
}
