//
//  MessengerViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/14/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import AssistantKit



class CategoriesViewController: MyUIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
CategoryLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate{
    
    //request
    var __req_page: Int = 1
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Category] = [Category]()
    
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    
    let cellId = "catCellId"
    
    
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
        
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        
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
        
        
        self.view.backgroundColor = Colors.bg_gray
        self.collectionView.backgroundColor = Colors.bg_gray
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        self.view.backgroundColor = Colors.bg_gray
        
        
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        
        collectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
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
        
        PeopleListViewController.isAppear = true
        
    }
    
    
    static var isAppear = false
    
    override func viewWillDisappear(_ animated: Bool) {
        
        PeopleListViewController.isAppear = false
        
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
        
        
        topBarTitle.text = "Categories".localized
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    @objc func onBackHandler() {
        self.dismiss(animated: true)
        SwiftEventBus.post("on_main_refresh", sender: true)
    }
    
    
    @objc private func refreshData(_ sender: Any) {
        
        self.__req_page = 1
        load()
        
    }
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        
        let object = LIST[indexPath.row]
        
        
        let cell: CategoryCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CategoryCell
        
        cell.setupSettings()
        cell.setup(object: object)
        //cell.setOptionLauncher(optionsLauncher: self.optionsLauncher)
        
        return cell
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if Device.isPhone{
            let finalHeight = view.frame.width / 4
            return CGSize(width: view.frame.width,height: finalHeight)
        }else if Device.isPad{
            let finalHeight = view.frame.width / 7
            return CGSize(width: view.frame.width/1.5,height: finalHeight)
        }else{
            let finalHeight = view.frame.width / 4
            return CGSize(width: view.frame.width,height: finalHeight)
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LIST.count
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
        let sb = UIStoryboard(name: "StoresList", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: StoresLsitViewController = sb.instantiateViewController(withIdentifier: "storeslistVC") as! StoresLsitViewController
            
            ms.request = ListStoresCell.Request.nearby
            ms.category_id = self.LIST[indexPath.row].numCat
            
            self.present(ms, animated: true)
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(5)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
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
        return UIEdgeInsetsMake(5, 0, 5, 0)
    }
    
    
    private var isLoading = false
    //API
    
    var loader: CategoryLoader = CategoryLoader()
    
    func load () {
        
        self.viewManager.showAsLoading(parent: collectionView)
        
        self.loader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "20"
        ]
        
        parameters["page"] = String(describing: self.__req_page)
        
        Utils.printDebug("\(parameters)")
        
        self.isLoading = true
        self.loader.load(url: Constances.Api.API_USER_GET_CATEGORY,parameters: parameters)
        
        
    }
    
    
    
    func success(parser: CategoryParser,response: String) {
        
        
        self.refreshControl.endRefreshing()
        
        self.viewManager.showMain()
        //self.refreshControl.endRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            self.isLoading = false
        }
        
        
        if parser.success == 1 {
            
            let categories = parser.parse()
        
            Utils.printDebug("===> \(categories)")

            if categories.count > 0 {
                
                Utils.printDebug("Loaded \(categories.count)")
                
                if let user = myUserSession {
                    // users.validateAll(sessId: user.id)
                }
                
                
                if self.__req_page == 1  {
                    
                    self.LIST = categories
                    self.GLOBAL_COUNT = parser.count
                    
                }else{
                    
                    self.LIST += categories
                    self.GLOBAL_COUNT = parser.count
                    
                }
                
                categories.saveAll()
                
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






