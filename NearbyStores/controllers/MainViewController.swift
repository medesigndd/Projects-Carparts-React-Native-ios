//
//  ViewController.swift
//  NearbyStores
//
//  Created by Amine on 5/19/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftIcons
import SwiftEventBus
import UserNotifications
import AssistantKit
import GoogleMobileAds


class MyUICollectionViewController: UICollectionViewController {
    override func viewDidLoad() {
        InComingDataParser.openViewEventBus(controller: self)
    }
}

class MyUIViewController: UIViewController {
    override func viewDidLoad() {
        InComingDataParser.openViewEventBus(controller: self)
    }
}

class MainViewController: MyUICollectionViewController, UICollectionViewDelegateFlowLayout, MenuBarDelegate, SearchDialogViewControllerDelegate, CategoryLoaderDelegate {
    
  
    
    private func setTitleForIndex(index: Int) {
        if let titleLabel = navigationItem.titleView as? UILabel {
            
            if index == 0 {
                titleLabel.text = "Home".localized
            }else{
                titleLabel.text = "\(AppConfig.Tabs.Pages[index].localized.capitalizingFirstLetter())"
            }
            
        }
    }
    
    let topBarTitle: EdgeLabel = {
        
        let titleLabel = EdgeLabel()
        
        titleLabel.text = "Home".localized
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        
        return titleLabel
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        self.loadCategories()
        
        // check and push they
        self.checkUpComingEvents()
        
        MainViewController.mInstance = self
        
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        
        navigationController?.navigationBar.tintColor = UIColor.white
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = UIColor.white
        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        topBarTitle.rightTextInset = 5
    
        navigationItem.titleView = topBarTitle
        
    
        collectionView?.backgroundColor = Colors.white

        
        UIApplication.shared.statusBarView?.backgroundColor = Colors.darkColor
        
        setupMenuBar()
        
        setupCollectionView()
        
        setupNavBarButtons()
        
        busEventsListiner()
        
        updateInboxBadge(count: Messenger.nbrMessagesNotSeen)

        //init and show interstitial ad after 10 seconds
        if AppConfig.Ads.ADS_ENABLED && AppConfig.Ads.ADS_INTERSTITIEL_ENABLED{
            
            interstitial = GADInterstitial(adUnitID: AppConfig.Ads.AD_INTERSTITIEL_ID)
            let request = GADRequest()
            interstitial.load(request)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+10) {
                self.showInterstitial()
            }
        
        }
        
    }
    
    var interstitial: GADInterstitial!
    
    func showInterstitial()  {
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        }
    }
    
    func busEventsListiner() {
        
        SwiftEventBus.onMainThread(self, name: "open_view_list_event") { result in
            
            if let req = result?.object{
                
                let request: Int = req as! Int
                self.startEventsListVC(request: request)
                
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name: "on_main_refresh") { result in
            
            if let _ = result?.object{
                
                self.collectionView?.reloadData()
                self.settingsLauncher.load()
              
            }
            
        }
        
        SwiftEventBus.onMainThread(self, name: "on_badge_refresh") { result in
            
            if let _ = result?.object{
                
                self.updateInboxBadge(count: Messenger.nbrMessagesNotSeen)
                
            }
            
        }
        
        
        SwiftEventBus.onMainThread(self, name: "on_main_redirect") { result in
            
            if let index = result?.object{
                
                let indexPath = IndexPath(item: index as! Int, section: 0)
                
                self.setTitleForIndex(index: index as! Int)
                self.collectionView?.scrollToItem(at: indexPath, at: .left, animated: true)
                self.menuBar.collectionView.scrollToItem(at: indexPath, at: .left, animated: true)
                self.menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)

            }
            
        }
        
        SwiftEventBus.onMainThread(self, name: "on_receive_message") { result in
            
            if let object = result?.object{
                
                
                if Session.isLogged() {
                    
                    let message: Message = object as! Message
                    message.save()
                    
                    guard MessengerViewController.isAppear == false else {
                        Messenger.nbrMessagesNotSeen = 0
                        self.updateInboxBadge(count: Messenger.nbrMessagesNotSeen)
                        return
                    }
                    
                    Messenger.nbrMessagesNotSeen += 1
                    
                    self.updateInboxBadge(count: Messenger.nbrMessagesNotSeen)
                    
                    if Messenger.nbrMessagesNotSeen == 1 {
                        
                        NotificationManager.push(
                            title: "New Message".localized,
                            subtitle: message.message,
                            identifier: InComingDataParser.tag_new_message
                        )
                        
                    }else if Messenger.nbrMessagesNotSeen > 1 &&  Messenger.nbrMessagesNotSeen < 3 {
                        
                        NotificationManager.push(
                            title: AppConfig.APP_NAME,
                            subtitle: "You have %@ messages".localized.format(arguments: Messenger.nbrMessagesNotSeen),
                            identifier: InComingDataParser.tag_new_message
                        )
                        
                    }
                    
                }
                
            
                
            }
            
        }
        
    }
    

    
    static var isAppear = false
    override func viewWillDisappear(_ animated: Bool) {
        MainViewController.isAppear = false
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
         MainViewController.isAppear = true
    }
    
    
    var searchBarButtonItem: UIBarButtonItem? = nil
    var moreBarButtonItem: UIBarButtonItem? = nil
    
    func setupNavBarButtons() {
        
        //setp search icon btn
        let searchImage = UIImage.init(icon: .linearIcons(.magnifier), size: CGSize(width: 25, height: 25), textColor: Colors.darkColor)
        
        searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleSearch))
        
       
        
        //setup more icon btn
        let moreImage = UIImage.init(icon: .googleMaterialDesign(.moreVert), size: CGSize(width: 25, height: 25), textColor: Colors.darkColor)
        
        moreBarButtonItem = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(handleMore))
        
    
        navigationItem.rightBarButtonItems = []
        
        if let btn = moreBarButtonItem{
            navigationItem.rightBarButtonItems?.append(btn)
        }
        
        if let btn = searchBarButtonItem{
            navigationItem.rightBarButtonItems?.append(btn)
        }
        
        
        
    }
    
    
    
    func setupInboxBadge() {
        
    }
    
    
    func updateInboxBadge(count: Int) {
        
        let size = AppConfig.Tabs.Pages.count-1
        for index in 0...size{
            if AppConfig.Tabs.Pages[index] == AppConfig.Tabs.Tags.TAG_INBOX{
                let indexPath = IndexPath(item: index, section: 0)
                
                let current = IndexPath(item: self.currentPage, section: 0)
                menuBar.refreshBadge(at: indexPath, count: count,current: current)
            
            }
        }
    }
    

    
    @objc func handleSearch() {
        
        
        
        let sb = UIStoryboard(name: "SearchDialog", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            let searchDialog: SearchDialogViewController = vc as! SearchDialogViewController
            
            let tab = AppConfig.Tabs.Pages[currentPage]
            
            searchDialog.searchType = tab
            searchDialog.delegate = self
           
            if let array = savedFilter[tab] {
                searchDialog.savedFilterInstance = array
            }
           
          
            self.present(searchDialog, animated: true, completion: nil)
        }
        
    }
    
    
    var savedFilter:[String: [String: String]] = [:]
    
    //override
    func onSearch(search: String, radius: Int, args: String...) {
        Utils.printDebug("\(search)")
        
        let array: [String: String] = [
            "search": search,
            "radius": String(radius)
        ]
        
        let tab = AppConfig.Tabs.Pages[currentPage]
        
        self.savedFilter[tab] = array
        
        SwiftEventBus.post("on_search_"+tab, sender: array)
        
    }
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.mainController = self
        return launcher
    }()
    
    @objc func handleMore() {
        settingsLauncher.showSettings()
    }
    
    func showControllerForSetting(setting: Setting) {
        
        if setting.id == MenuIDList.CATEGORIES{
            
            startCategoriesList()
            
        }else if setting.id == MenuIDList.LOGOUT{
            
            if Session.logout() {
                self.collectionView?.reloadData()
                self.settingsLauncher.load()
            }
            
        }else if setting.id == MenuIDList.CHAT_LOGIN{
            if Session.isLogged() == false {
                if let vc = MainViewController.mInstance {
                    vc.startLoginVC()
                }
            }
        }else if setting.id == MenuIDList.PEOPLE_AROUND_ME {
            
            let sb = UIStoryboard(name: "PeopleList", bundle: nil)
            
            if sb.instantiateInitialViewController() != nil {
                
                let vc: PeopleListViewController = sb.instantiateViewController(withIdentifier: "peopleVC") as! PeopleListViewController
                navigationController?.present(vc, animated: true)
            }
            
        }else if setting.id == MenuIDList.GEO_STORES {
            
            let sb = UIStoryboard(name: "GeoStore", bundle: nil)
            if let vc = sb.instantiateInitialViewController() {
                navigationController?.present(vc, animated: true)
            }
            
        }else if setting.id == MenuIDList.FAVOURITES {
            
            startStoresList(request: ListStoresCell.Request.saved)
            
        }else if setting.id == MenuIDList.MY_EVENTS {
            
            startEventsListVC(request: ListEventCell.Request.saved)
            
        }else if setting.id == MenuIDList.EDIT_PROFILE {
            
            if Session.isLogged(){
                startEditProfileVC()
            }
            
        }else if setting.id == MenuIDList.ABOUT {
            
             startAboutVC()
            
        }else if setting.id == MenuIDList.SETTING {
            
            self.startSettingVC()
            
        }else if setting.id == MenuIDList.MANAGE_STORES{
            
            if let url = URL(string: AppConfig.Api.base_url+"/webdashboard"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
        }
        
    }
    
    lazy var menuBar: MenuBar = {
        let mb = MenuBar()
        return mb
    }()
    
    private func setupMenuBar(){
        
        
        
//       navigationController?.hidesBarsOnSwipe = true
        
        if AppConfig.Tabs.Pages.count > 1 {
            
            let bgViw = UIView()
            bgViw.backgroundColor = Colors.black
            
            
            view.addSubview(bgViw)
            
            view.addConstraintsWithFormat(format: "H:|[v0]|", views: bgViw)
            view.addConstraintsWithFormat(format: "V:[v0(50)]", views: bgViw)
            
            menuBar.delegate = self
            
            view.addSubview(menuBar)
            
          
            view.addConstraintsWithFormat(format: "H:|[v0]|",views: menuBar)
            view.addConstraintsWithFormat(format: "V:[v0(50)]", views: menuBar)
    
            menuBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor).isActive = true
            
        }else{
            menuBar.isHidden = true
        }
       
    }
    
    
    func setupCollectionView() {
        
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = 0
        }
        
    
        
        for tag in AppConfig.Tabs.Pages{
            if tag == AppConfig.Tabs.Tags.TAG_STORES{
                collectionView?.register(ListStoresCell.self, forCellWithReuseIdentifier: tag)
            }else if tag == AppConfig.Tabs.Tags.TAG_OFFERS{
                collectionView?.register(ListOfferCell.self, forCellWithReuseIdentifier: tag)
            }else if tag == AppConfig.Tabs.Tags.TAG_EVENTS{
                collectionView?.register(ListEventCell.self, forCellWithReuseIdentifier: tag)
            }else if tag == AppConfig.Tabs.Tags.TAG_INBOX{
                collectionView?.register(ListDiscussionCell.self, forCellWithReuseIdentifier: tag)
            }
        }
        
        
       
        
        let screen = Device.screen
        
        switch screen {
            case .inches_3_5:  print("3.5 inches")
            case .inches_4_0:  print("4.0 inches")
            case .inches_4_7:  print("4.7 inches")
            case .inches_5_5:  print("5.5 inches")
            case .inches_7_9:  print("7.9 inches")
            case .inches_9_7:  print("9.7 inches")
            case .inches_12_9: print("12.9 inches")
            default:           print("Other display \(screen)")
       }
        
       
        
        let version = Device.version
        
        if AppConfig.Tabs.Pages.count > 1 {
            
            collectionView?.contentInset = UIEdgeInsetsMake(50, 0, 0, 0)
            collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50, 0, 0, 0)
            
            if version == .phoneX{
                collectionView?.contentInset = UIEdgeInsetsMake(50+36, 0, 0, 0)
                collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(50+36, 0, 0, 0)
            }
            
        }else{
            
            collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            
            if version == .phoneX{
                collectionView?.contentInset = UIEdgeInsetsMake(0+36, 0, 0, 0)
                collectionView?.scrollIndicatorInsets = UIEdgeInsetsMake(0+36, 0, 0, 0)
            }
        }
        
        
        collectionView?.isPagingEnabled = true
        
    }
    
  
    
    func scrollToMenuIndex(index menuIndex: Int) {
        
        let indexPath = IndexPath(item: menuIndex, section: 0)
        
        if Utils.isRTL(){
             collectionView?.scrollToItem(at: indexPath, at: .right, animated: true)
        }else{
            collectionView?.scrollToItem(at: indexPath, at: .left, animated: true)
        }
        
    
        setTitleForIndex(index: menuIndex)

    }
    
    
    
    //SCROLLVIEW CUSTOMIZATION
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        menuBar.horizontalBarLeftRightAnchorConstraint?.constant = scrollView.contentOffset.x / CGFloat(AppConfig.Tabs.Pages.count)
        
       
        
        
 
    }
    
    override func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let ocount = AppConfig.Tabs.Pages.count-1
        
        guard ocount >= 0 else { return }
    
        
        var index = targetContentOffset.move().x / view.frame.width
        
        if Utils.isRTL(){
            index = CGFloat( (index-CGFloat(ocount)) * CGFloat(-1) )
        }
        
        let indexPath = IndexPath(item: Int(index), section: 0)
        
       
        Utils.printDebug("scrollToMenuIndex: \(index)")
        
        menuBar.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
        
        setTitleForIndex(index: indexPath.item)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(AppConfig.Tabs.Pages.count)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let tab = AppConfig.Tabs.Pages[indexPath.item]
        
        if tab == AppConfig.Tabs.Tags.TAG_STORES {
            
            let cellId = AppConfig.Tabs.Tags.TAG_STORES
            let cell: ListStoresCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListStoresCell
            
            cell.viewController = self
            
             return cell
       
        }else if tab == AppConfig.Tabs.Tags.TAG_OFFERS {
            
            let cellId = AppConfig.Tabs.Tags.TAG_OFFERS
            let cell: ListOfferCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListOfferCell
            
            cell.viewController = self
            
             return cell
        
        }else if tab == AppConfig.Tabs.Tags.TAG_EVENTS {
            
            let cellId = AppConfig.Tabs.Tags.TAG_EVENTS
            let cell: ListEventCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListEventCell
            
            cell.viewController = self
            
            return cell
            
        }else if tab == AppConfig.Tabs.Tags.TAG_INBOX{
            
            let cellId = AppConfig.Tabs.Tags.TAG_INBOX
            let cell: ListDiscussionCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListDiscussionCell
            
            cell.viewController = self
          
            return cell
            
        }else{
            
            let cellId = AppConfig.Tabs.Tags.TAG_STORES
            let cell: ListStoresCell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ListStoresCell
            
            cell.viewController = self
            
            return cell
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if AppConfig.Tabs.Pages.count > 1 {
            return CGSize(width: view.frame.width ,height: view.frame.height - 50)
        }else{
            return CGSize(width: view.frame.width ,height: view.frame.height)
        }
        
    }
    
    private var currentPage = 0
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let currentTab = AppConfig.Tabs.Pages[indexPath.item]
        currentPage = indexPath.item
        
        if let btn = self.searchBarButtonItem {
            btn.isEnabled = true
        }
       
        
        if currentTab == AppConfig.Tabs.Tags.TAG_STORES {
            
            let myCell: ListStoresCell = cell as! ListStoresCell
            
            if myCell.isFetched  == false {
                myCell.fetch(request: ListStoresCell.Request.nearby)
            }
            
             Utils.printDebug("Cell display => \(indexPath.item) \(currentTab)")
            
        }else if currentTab == AppConfig.Tabs.Tags.TAG_OFFERS {
            
            let myCell: ListOfferCell = cell as! ListOfferCell
            
            if myCell.isFetched  == false {
               myCell.fetch(request: ListOfferCell.Request.nearby)
            }
            
             Utils.printDebug("Cell display => \(indexPath.item) \(currentTab)")
            
        }else if currentTab == AppConfig.Tabs.Tags.TAG_EVENTS {
            
            let myCell: ListEventCell = cell as! ListEventCell
            
            if myCell.isFetched  == false {
                myCell.fetch(request: ListEventCell.Request.nearby)
            }
            
             Utils.printDebug("Cell display => \(indexPath.item) \(currentTab)")
            
        }else if currentTab == AppConfig.Tabs.Tags.TAG_INBOX {
      
            if let btn = self.searchBarButtonItem {
                 btn.isEnabled = false
            }
            
            let myCell: ListDiscussionCell = cell as! ListDiscussionCell
            
            if myCell.isFetched  == false {
                myCell.fetch(request: ListDiscussionCell.Request.nearby)
            }
            
            myCell.checker()
            
            Utils.printDebug("Cell display => \(indexPath.item) \(currentTab)")
            
            
        }else{
            
        }
        
        
       
    }
    
    
    static var mInstance: MainViewController? = nil
    
    func startLoginVC() {
        
        let sb = UIStoryboard(name: "Login", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: LoginViewController = sb.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    
    func startSignUpVC() {
        
        let sb = UIStoryboard(name: "SignUp", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: SignUpViewController = sb.instantiateViewController(withIdentifier: "signupVC") as! SignUpViewController
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    func startEditProfileVC() {
        
        let sb = UIStoryboard(name: "EditProfile", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: EditProfileViewController = sb.instantiateViewController(withIdentifier: "editprofileVC") as! EditProfileViewController
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    
    func startMessenger(client_id: Int,discussion_id: Int) {
        
        let sb = UIStoryboard(name: "Messenger", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: MessengerViewController = sb.instantiateViewController(withIdentifier: "messengerVC") as! MessengerViewController
            ms.client_id = client_id
            ms.discussionId = discussion_id
            
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    func startMessenger(client_id: Int) {
        
        let sb = UIStoryboard(name: "Messenger", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: MessengerViewController = sb.instantiateViewController(withIdentifier: "messengerVC") as! MessengerViewController
            ms.client_id = client_id
           
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    func startPeopleList() {
        
        let sb = UIStoryboard(name: "PeopleList", bundle: nil)
        
        if sb.instantiateInitialViewController() != nil {
            
            let vc: PeopleListViewController = sb.instantiateViewController(withIdentifier: "peopleVC") as! PeopleListViewController
            navigationController?.present(vc, animated: true)
        }
        
    }
    
    
    func startStoreDetailVC(store_id: Int) {
        
        let sb = UIStoryboard(name: "StoreDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: StoreDetailViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailViewController
            ms.storeId = store_id
            
            navigationController?.present(ms, animated: true)
        }
        
    }

    
    
    func startStoresList(request: Int) {
        
        let sb = UIStoryboard(name: "StoresList", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: StoresLsitViewController = sb.instantiateViewController(withIdentifier: "storeslistVC") as! StoresLsitViewController

            ms.request = request
            
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    func startCategoriesList() {
        
        let sb = UIStoryboard(name: "Categories", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: CategoriesViewController = sb.instantiateViewController(withIdentifier: "categoriesVC") as! CategoriesViewController
            
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    
    func startOfferDetailVC(offerId: Int) {
        
        let sb = UIStoryboard(name: "OfferDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: OfferDetailViewController = sb.instantiateViewController(withIdentifier: "offerdetailVC") as! OfferDetailViewController
            
            ms.offer_id = offerId
            
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    
    func startEventDetailVC(eventId: Int) {
        
        let sb = UIStoryboard(name: "EventDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: EventDetailViewController = sb.instantiateViewController(withIdentifier: "eventdetailVC") as! EventDetailViewController
            
            ms.event_id = eventId
            
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    
    func startEventsListVC(request: Int) {
        
        let sb = UIStoryboard(name: "EventsList", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: EventsLsitViewController = sb.instantiateViewController(withIdentifier: "eventslistVC") as! EventsLsitViewController
            
            ms.request = request
            
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    
    func startAboutVC() {
        
        let sb = UIStoryboard(name: "About", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: AboutViewController = sb.instantiateViewController(withIdentifier: "aboutVC") as! AboutViewController
    
            navigationController?.present(ms, animated: true)
        }
        
    }
    
    
    func startSettingVC() {
        
        let sb = UIStoryboard(name: "Settings", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: SettingsViewController = sb.instantiateViewController(withIdentifier: "settingsVC") as! SettingsViewController
            
            navigationController?.pushViewController(ms, animated: true)
            //navigationController?.present(ms, animated: true)
        }
        
    }
    
    
    func checkUpComingEvents() {
    
        DispatchQueue.main.asyncAfter(deadline: .now()+4) {
            
            let upeList = UpComingEvent.getUpComingEventsNotNotified()
            
            if upeList.count>1{
                //push local notification then remove it
                
                NotificationManager.push(title: AppConfig.APP_NAME, subtitle: "Upcoming Events soon".localized, identifier: "upcomingevents")
                
                
            }else if upeList.count>0{
                
                NotificationManager.push(title: "Upcoming Event".localized, subtitle: upeList[0].event_name, identifier: "upcomingevents")
                
            }
        }
        
        
    }

  
    
    var cloader: CategoryLoader = CategoryLoader()

    func loadCategories () {
        
        self.cloader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "50"
        ]
        
        parameters["page"] = String(describing: 1)
       
        self.cloader.load(url: Constances.Api.API_USER_GET_CATEGORY,parameters: parameters)
    
    }
    
    
    func success(parser: CategoryParser,response: String) {
        
        if parser.success == 1 {
            
            let categories = parser.parse()
           
            if categories.count > 0 {
                categories.saveAll()
            }
        
        
        }
    }
    
    func error(error: Error?, response: String) {
        
    }
    
    
}





    
    
    
    
    
    
    
    
