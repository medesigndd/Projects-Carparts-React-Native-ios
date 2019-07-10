//
//  ListStoresCell.swift
//  NearbyStores
//
//  Created by Amine on 5/30/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import AssistantKit

class ListStoresCell: BaseCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource , StoreLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate{
    
    var viewController: UIViewController? = nil

    enum Request {
        static let nearby = 0
        static let saved = -1
    }
   
    //request
    var __req_category: Int = 0
    var __req_redius: Int  = AppConfig.distanceMaxValue
    var __req_list: Int = Request.nearby
    var __req_search: String = ""
    var __req_page: Int = 1
   
 
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Store] = [Store]()
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    //Cell ID for collection
    var cellId = "storeCellId"
  
    
    //instance for scrolling
    var isFetched = false
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
     
        cv.backgroundColor = Colors.bg_gray
        
        if let flowLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 3
        }
        
        cv.dataSource = self
        cv.delegate = self
        return cv
        
    }()
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
    override func setupViews() {
        super.setupViews()
        

        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
    }
    
    private let refreshControl = UIRefreshControl()
    
    
    func fetch(request: Int) {
        
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        isFetched = true
        
        Utils.printDebug("Fetch ListStores")
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        collectionView.register(UINib(nibName: "StoreCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
  
        
        
        refreshControl.beginRefreshing()
        
        load()
        
        
        
        //get params
        SwiftEventBus.onMainThread(self, name: "on_search_stores") { result in
           
            if let object = result?.object{
                
                let array: [String: String] = object as! [String : String]
                
                self.__req_redius = Int(array["radius"]!)!
                self.__req_search = array["search"]!
                self.__req_page = 1
                
                
                self.viewManager.showAsLoading()
                self.load()
                

            }
            
        }
        
        
        //setup view loader, Error, Empty layouts
        viewManager.setup(parent: self)
        viewManager.getEmptyLayout().delegate = self
        viewManager.getErrorLayout().delegate = self
        
       
    }
    
    
    
    @objc private func refreshData(_ sender: Any) {
        //Init params
        __req_page = 1
        
        // Fetch Data
        load()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StoreCell
            
        cell.setupSettings()
        cell.setup(object: LIST[indexPath.item])
            
       
        return cell
    }
    
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let store = self.LIST[indexPath.row]
        store.save()
        
        if let controller = self.viewController {
            let sb = UIStoryboard(name: "StoreDetail", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: StoreDetailViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailViewController
                ms.storeId = store.id
            
                controller.present(ms, animated: true)
            }
        }
        
       
       
        
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LIST.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
       
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
       
        if Device.isPhone{
             let finalHeight = frame.width / 1.3
            return CGSize(width: frame.width,height: finalHeight)
        }else if Device.isPad{
             let finalHeight = frame.width / 2
            return CGSize(width: frame.width/1.5,height: finalHeight)
        }else{
             let finalHeight = frame.width / 1.3
            return CGSize(width: frame.width,height: finalHeight)
        }
        
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 4, left: 0, bottom: 0, right: 0)
//    }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //item = 10, count = 10 , COUNT = 23
        
         Utils.printDebug(" Paginate \( (indexPath.item + 1) ) - \(LIST.count) - \(GLOBAL_COUNT)")
        
        if indexPath.item + 1 == LIST.count && LIST.count < GLOBAL_COUNT && !isLoading {
            Utils.printDebug(" Paginate! \(__req_page) ")
            self.load()
        }
        
    }
    private var isLoading = false
    
    
    
    //API
    
    var storeLoader: StoreLoader = StoreLoader()
    
    func load () {
        
        if __req_page == 1 {
            self.refreshControl.beginRefreshing()
        }else{
            self.viewManager.showAsLoading()
        }
       

        self.storeLoader.delegate = self

        //Get current Location
    
        var parameters = [
            "limit"          : "10"
        ]
        
        if let guest = Guest.getInstance() {
            
            parameters["latitude"] = String(guest.lat)
            parameters["longitude"] = String(guest.lng)
            
            if __req_redius > 0 && __req_redius < 100 {
                parameters["radius"] = String( (__req_redius*1000) ) //radius by merters
            }
            
//            if let user = myUserSession {
//               parameters["user_id"] = String(user.id)
//            }

            parameters["category_id"] = String(__req_category)
            parameters["page"] = String(__req_page)
            parameters["search"] = String(__req_search)
            
            
            if __req_list == Request.saved {
                if let savedStores = SavedStores.getInstance() {
                    let ids = savedStores.getListAsString()
                    
                    if ids != ""{
                         parameters["store_ids"] = ids
                    }else{
                        parameters["store_ids"] = String("0")
                    }
                   
                    parameters["order_by"] = String(Request.nearby)
                }else{
                     parameters["store_ids"] = String("0")
                }
                
            }else{
                parameters["order_by"] = String(__req_list)
            }
            
        }
        
        Utils.printDebug("\(parameters)")
        
        self.isLoading = true
        self.storeLoader.load(url: Constances.Api.API_USER_GET_STORES,parameters: parameters)
        
        
    }
    
    
    func success(parser: StoreParser,response: String) {
        
        
        self.viewManager.showMain()
        self.refreshControl.endRefreshing()
      

        self.isLoading = false
        
        if parser.success == 1 {
            
         
            let stores = parser.parse()
           
            
            self.GLOBAL_COUNT = parser.count
            
            if stores.count > 0 {
                
                Utils.printDebug("We loaded \(stores.count)")
                
                
                if self.__req_page == 1 {
                    self.LIST = stores
                }else{
                    self.LIST += stores
                }
                
                 self.collectionView.reloadData()
                
                if self.LIST.count < self.GLOBAL_COUNT {
                    self.__req_page += 1
                }
                
               
            }else{
                
                if self.LIST.count == 0 {
                    
                    emptyAndReload()
                    //show emty layout
                    viewManager.showAsEmpty()
                    
                }else if self.__req_page == 1 {
                    
                    emptyAndReload()
                    
                    viewManager.showAsEmpty()
                    
                      Utils.printDebug("===> Is Empty!")
                }
               
                
            }
            
        }else {
            
            if let errors = parser.errors {
                
                Utils.printDebug("===> Request Error with Messages! ListStores")
                Utils.printDebug("\(errors)")
                
                 viewManager.showAsError()
              
            }
            
        }
        
    }
    
    func emptyAndReload()  {
        
        self.LIST = []
        self.GLOBAL_COUNT = 0
        self.collectionView.reloadData()
        
    }
    
    func error(error: Error?,response: String) {
        
        self.isLoading = false
        self.refreshControl.endRefreshing()
        self.viewManager.showAsError()
        
        Utils.printDebug("===> Request Error! ListStores")
        Utils.printDebug("\(response)")
    
    }
    
  
    func onReloadAction(action: ErrorLayout) {
        
        self.viewManager.showAsLoading()
        
        __req_search = ""
        __req_page = 1

        load()
        
    }
    
    func onReloadAction(action: EmptyLayout) {
        
        self.viewManager.showAsLoading()
        
        __req_search = ""
        __req_page = 1

        load()
        
    }
    
    
    
    
    
    

    

    
}
