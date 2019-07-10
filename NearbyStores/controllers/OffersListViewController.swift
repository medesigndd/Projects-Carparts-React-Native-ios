//
//  MessengerViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus

class OffersLsitViewController: MyUIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    var store_id: Int? = nil
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
    let cellId = "offersCellId"
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var viewContainer: UIView!
    
    
    func setupNavBarButtons() {
        
        //arrow back icon
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
        
    
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        self.view.backgroundColor = Colors.bg_gray
        
        
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView?.register(ListOfferCell.self, forCellWithReuseIdentifier: AppConfig.Tabs.Tags.TAG_OFFERS)
        collectionView.isScrollEnabled = false
        
        setupNavBarTitles()
        //setup views
        setupNavBarButtons()
       
       
    }
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        OffersLsitViewController.isAppear = true
        
    }
    
    
    static var isAppear = false
    
    override func viewWillDisappear(_ animated: Bool) {
        
        OffersLsitViewController.isAppear = false
        
    }
    
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
        
        
        if let store_id = self.store_id, let store = Store.findById(id: store_id){
            topBarTitle.text = store.name+" "+("offers").localized
        }else{
            topBarTitle.text = "Offers".localized
        }
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cellId = AppConfig.Tabs.Tags.TAG_OFFERS
        let cell: ListOfferCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListOfferCell
        
        cell.viewController = self
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width ,height: view.frame.height - 50)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let myCell: ListOfferCell = cell as! ListOfferCell
        
        if myCell.isFetched  == false {
            
            if let store = self.store_id {
                myCell.__req_store = store
            }
            
             myCell.fetch(request: ListOfferCell.Request.nearby)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
   

    
}





