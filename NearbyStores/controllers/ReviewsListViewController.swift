//
//  MessengerViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus

class ReviewsListViewController: MyUIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, RateDialogViewControllerDelegate,
ReviewLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate{
    
    var store_id: Int? = nil
    //request
    var __req_page: Int = 1
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Review] = [Review]()
    
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
    let cellId = "reviewCellId"
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var viewContainer: UIView!
    
    
    
    
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
        
        
        let rateImage = UIImage.init(icon: .googleMaterialDesign(.thumbUp), size: CGSize(width: 25, height: 25), textColor: Colors.darkColor)
        let rateCustomBarButtonItem = UIBarButtonItem(image: rateImage, style: .plain, target: self, action: #selector(onRatehHandle))
        rateCustomBarButtonItem.setIcon(icon: .googleMaterialDesign(.thumbUp), iconSize: 25, color: Colors.white)
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        navigationBarItem.rightBarButtonItems?.append(rateCustomBarButtonItem)
        
    }
    
    @objc func onBackHandler()  {
        self.dismiss(animated: true)
    }
    
    
    @objc func onRatehHandle() {
        let sb = UIStoryboard(name: "RateDialog", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            let rateDialog: RateDialogViewController = vc as! RateDialogViewController
            
            rateDialog.store_id = store_id
            rateDialog.delegate = self
            
            self.present(rateDialog, animated: true, completion: nil)
        }
    }
    
    func onRate(rating: Double, review: String) {
        //add review
        
        let message: [String: String] = ["alert": "Thank for your review!".localized]
        self.showAlertError(title: "Alert",content: message,msgBnt: "OK")
        self.__req_page = 1
        load()
    }
    
    func setupViewloader()  {
        
        //setup view loader, Error, Empty layouts
        viewManager.setup(parent: viewContainer)
        viewManager.getEmptyLayout().delegate = self
        viewManager.getErrorLayout().delegate = self
        
        if Session.isLogged() ==  false {
            
            return
        }else{
            
        }
    }
    
    var currentDate = ""
    
    private let refreshControl = UIRefreshControl()
    
    func setupRefreshControl() {
        
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refreshControl
        } else {
            collectionView.addSubview(refreshControl)
        }
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        
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
        
        
        collectionView.register(UINib(nibName: "StoreReviewCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
        //get currenct date
        currentDate = DateUtils.getCurrentUTC(format: "yyyy-MM-dd HH:mm:ss")
        
        
        
        setupNavBarTitles()
        //setup views
        setupNavBarButtons()
        setupViewloader()
        setupRefreshControl()
        
        
        load()
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        ReviewsListViewController.isAppear = true
        
    }
    
    
    static var isAppear = false
    
    override func viewWillDisappear(_ animated: Bool) {
        
        ReviewsListViewController.isAppear = false
        
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
            topBarTitle.text = store.name
        }else{
            topBarTitle.text = "Reviews".localized
        }
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
   
    
    
    @objc private func refreshData(_ sender: Any) {
        
        self.__req_page = 1
        load()
        
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let object = LIST[indexPath.row]
        
        let cell: StoreReviewCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! StoreReviewCell
        
        cell.settings()
        cell.setup(object: object)
        
        return cell
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //        let height = (frame.width - 16 - 16) * 9 / 16
        let finalHeight = view.frame.width / 5
        
        return CGSize(width: view.frame.width,height: finalHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LIST.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
       
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //item = 10, count = 10 , COUNT = 23
        
        Utils.printDebug(" Paginate \( indexPath.item ) - \(LIST.count) - \(GLOBAL_COUNT)")
        
        if indexPath.item == 0 && LIST.count < GLOBAL_COUNT && !isLoading && __req_page > 1 {
            Utils.printDebug(" Paginate! Load \(__req_page) page ")
            self.load()
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 0, 0, 0)
    }
    
    
    private var isLoading = false
    //API
    
    var loader: ReviewLoader = ReviewLoader()
    
    
    func load () {
        
        self.viewManager.showAsLoading(parent: collectionView)
        
        self.loader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "20"
        ]
        
        
        if let user = myUserSession{
            parameters["user_id"] = String(describing: user.id)
        }
        
        if let store_id = self.store_id{
            parameters["store_id"] = String(describing: store_id)
        }
        
        parameters["page"] = String(describing: self.__req_page)
        
        
        self.isLoading = true
        self.loader.load(url: Constances.Api.API_USER_GET_REVIEWS,parameters: parameters)
        
        
    }
    
    
    
    func success(parser: ReviewParser,response: String) {
        
        
        self.refreshControl.endRefreshing()
        
        self.viewManager.showMain()
        //self.refreshControl.endRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.isLoading = false
        }
        
        
        if parser.success == 1 {
            
            let reviews = parser.parse()
            
            
            Utils.printDebug("===> \(reviews)")
            
            
            if reviews.count > 0 {
                
                Utils.printDebug("Loaded \(reviews.count)")
                
                if let user = myUserSession {
                    // users.validateAll(sessId: user.id)
                }
                
                
                if self.__req_page == 1  {
                    
                    self.LIST = reviews
                    self.GLOBAL_COUNT = parser.count
                    
                }else{
                    
                    self.LIST += reviews
                    self.GLOBAL_COUNT = parser.count
                    
                }
                
             
                self.collectionView.reloadData()
                
                
                if self.LIST.count < self.GLOBAL_COUNT || self.GLOBAL_COUNT < 20 {
                    self.__req_page += 1
                }
                
                
            }else{
                
                if self.LIST.count == 0  && self.__req_page == 1 {
                    
                    emptyAndReload()
                    //show emty layout
                    viewManager.showAsEmpty()
                    
                }
                
            }
            
        }else {
            
            if let errors = parser.errors {
                
                if self.LIST.count == 0 {
                    Utils.printDebug("===> Request Error with Messages! ListDiscussions")
                    Utils.printDebug("\(errors)")
                    
                    viewManager.showAsError()
                }
                
                
            }
            
        }
        
    }
    
    
    
    
    func emptyAndReload()  {
        
        self.LIST = []
        self.GLOBAL_COUNT = 0
        self.collectionView.reloadData()
        
    }
    
    func error(error: Error?,response: String) {
        
        self.refreshControl.endRefreshing()
        
        
        if self.LIST.count == 0 {
            
            self.isLoading = false
            self.viewManager.showAsError()
            
            Utils.printDebug("===> Request Error! ListDiscussions")
            Utils.printDebug("\(response)")
            
        }
        
    }
    
    
    func onReloadAction(action: ErrorLayout) {
        
        Utils.printDebug("onReloadAction ErrorLayout")
        
        self.viewManager.showAsLoading(parent: collectionView)
        
        __req_page = 1
        
        load()
        
    }
    
    func onReloadAction(action: EmptyLayout) {
        
        
        self.viewManager.showAsLoading(parent: collectionView)
        
        __req_page = 1
        
        load()
        
    }
    
  
    
    
}





