//
//  ListOffersCell.swift
//  NearbyStores
//
//  Created by Amine on 5/30/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import RealmSwift
import AssistantKit


class ListDiscussionCell: BaseCell, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource , DiscussionLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate,CustomLayoutDelegate{
    
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
    var __req_store: Int = 0
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Discussion] = [Discussion]()
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    //Cell ID for collection
    var cellId = "discussionCellId"
    
    
    //instance for scrolling
    var isFetched = false
    
    lazy var collectionView: UICollectionView = {
        
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
    
        cv.backgroundColor = Colors.bg_gray
    
        if let flowLayout = cv.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 1
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
        
        
        
        Utils.printDebug("Fetch ListDiscussions")
        
        addSubview(collectionView)
        addConstraintsWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: collectionView)
        
        collectionView.register(UINib(nibName: "DiscussionCell", bundle: nil), forCellWithReuseIdentifier: cellId)
        
        

        
        
        //get params
        SwiftEventBus.onMainThread(self, name: "on_search_discussions") { result in
            
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
        viewManager.getCustomLayout().delegate = self
        
        
        if Session.isLogged() ==  false {
            
            self.setupCustomLayoutChatLogin()
            viewManager.showAsCustomLayout()
            
            return
        }else{
            
            isFetched = true
           
            refreshControl.beginRefreshing()
            load()
            
        }
        
        
      
        onReceiveListener()
        
    }
    
    
    func setupCustomLayoutChatLogin() {
        
        viewManager.getCustomLayout().customBtn.setTitle("Chat login".localized, for: .normal)
        viewManager.getCustomLayout().customText.text = "Find people around you".localized
        
    }
    
    func setupCustomLayoutFindNeighbour() {
        
     
        viewManager.getCustomLayout().customBtn.setTitle("Find neighbour".localized, for: .normal)
        viewManager.getCustomLayout().customText.text = "No discussion found!".localized
        
    }
    
    func checker() {
    
        if Session.isLogged() == false {
            self.setupCustomLayoutChatLogin()
            self.viewManager.showAsCustomLayout()
        }else{
            self.viewManager.showMain()
        }
    }
    
    func onReceiveListener() {
        
        //get params
        SwiftEventBus.onMainThread(self, name: "on_receive_message") { result in
            
            if let object = result?.object{
                
                if Session.isLogged() {
                    
                    let message: Message = object as! Message
                    message.save()
                    
                    if let index = self.LIST.getCurrentIndex(client_id: message.senderId) {
                        
                        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                            
                            let realm = try! Realm()
                            try! realm.write {
                                self.LIST[index].nbrMessages += 1
                                self.LIST[index].messages = List<Message>()
                                self.LIST[index].messages.append(message)
                            }
                            
                            
                            
                            self.LIST = self.LIST.refreshToTop(client_id: message.senderId)
                            self.collectionView.reloadData()
                        }
                        
                        
                    }else{
                        
                        self.__req_page = 1
                        self.GLOBAL_COUNT = 0
                        self.load()
                        
                    }
                    
                }
                
                
                
            }
            
        }
        
        
        
    }
    
    @objc private func refreshData(_ sender: Any) {
        
        if Session.isLogged() {
            //Init params
            __req_page = 1
            
            // Fetch Data
            load()
            
        }else{
            self.viewManager.showAsCustomLayout()
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath)
        -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DiscussionCell
            
            cell.setupSettings()
            cell.setup(object: LIST[indexPath.item])
            
            
            return cell
    }
    
    

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return LIST.count
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

       
        if Device.isPhone{
            let finalHeight = frame.width / 4.5
            return CGSize(width: frame.width,height: finalHeight)
        }else if Device.isPad{
            
            if Device.screen > .inches_9_7{
                let finalHeight = frame.width / 8.5
                return CGSize(width: frame.width/1.5,height: finalHeight)
            }else{
                let finalHeight = frame.width / 7.5
                return CGSize(width: frame.width/1.5,height: finalHeight)
            }
           
        }else{
            let finalHeight = frame.width / 4.5
            return CGSize(width: frame.width,height: finalHeight)
        }
    }

    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        //item = 10, count = 10 , COUNT = 23
        
        Utils.printDebug(" Paginate \( (indexPath.item + 1) ) - \(LIST.count) - \(GLOBAL_COUNT)")
        
        if indexPath.item + 1 == LIST.count && LIST.count < GLOBAL_COUNT && !isLoading {
            Utils.printDebug(" Paginate! \(__req_page) ")
            self.load()
        }
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let sender = self.LIST[indexPath.row].senderUser{
            let client_id = sender.id
            let discussion_id = self.LIST[indexPath.row].id
            
            
            let discussion = self.LIST[indexPath.row]
            
            if discussion.nbrMessages > 0 {
                
                self.markMessagesAsLoaded(discussionId: discussion.id)
                
               
                DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                    
                    let realm = try! Realm()
                    try! realm.write {
                        self.LIST[indexPath.row].nbrMessages = 0
                    }
                    self.collectionView.reloadItems(at: [indexPath])
                }
                
               
            }
            
            if let controller = self.viewController {
                let sb = UIStoryboard(name: "Messenger", bundle: nil)
                if sb.instantiateInitialViewController() != nil {
                    
                    let ms: MessengerViewController = sb.instantiateViewController(withIdentifier: "messengerVC") as! MessengerViewController
                    ms.client_id = client_id
                    ms.discussionId = discussion_id
                    
                    controller.present(ms, animated: true)
                }
            }
        }
       
       

    }
    
  
   
    private var isLoading = false
    //API
    
    var discussionLoader: DiscussionLoader = DiscussionLoader()
    
    func load () {
        
        if let session = Session.getInstance(), let user = session.user{
            myUserSession = user
        }
        
        if __req_page == 1 {
            self.refreshControl.beginRefreshing()
        }else{
            self.viewManager.showAsLoading()
        }
        
        
        self.discussionLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "30"
        ]
        
        if let user = myUserSession {
            parameters["user_id"] = String(user.id)
        }
        
        parameters["page"] = String(__req_page)
        
    
        Utils.printDebug("\(parameters)")
        
        self.isLoading = true
        self.discussionLoader.load(url: Constances.Api.API_LOAD_DISCUSSION,parameters: parameters)
        
        
    }
    
    
    func success(parser: DiscussionParser,response: String) {
        
       
        self.viewManager.showMain()
        self.refreshControl.endRefreshing()
        
        
        self.isLoading = false
        
        if parser.success == 1 {
            
            
            let discussions = parser.parse()
            
            
            self.GLOBAL_COUNT = parser.count
            
            if discussions.count > 0 {
                
                Utils.printDebug("Data loaded \(discussions)")
                
                
                if self.__req_page == 1 {
                    self.LIST = discussions
                }else{
                    self.LIST += discussions
                }
                
               // self.LIST.saveAll()
                self.collectionView.reloadData()
                
                if self.LIST.count < self.GLOBAL_COUNT {
                    self.__req_page += 1
                }
                
                
                for discussion in discussions{
                    
                    if let user = discussion.senderUser{
                       user.save()
                    }
                    
                    if discussion.messages.count > 0{
                        discussion.messages[0].save()
                    }
                    
                }
                
            }else{
                
                if self.LIST.count == 0 {
                    
                    emptyAndReload()
                    //show emty layout
                    self.setupCustomLayoutFindNeighbour()
                    viewManager.showAsCustomLayout()
                    
                }else if self.__req_page == 1 {
                    
                    emptyAndReload()
                    
                    viewManager.showAsEmpty()
                    
                    Utils.printDebug("===> Is Empty!")
                }
                
                
            }
            
        }else {
            
            if let errors = parser.errors {
                
                Utils.printDebug("===> Request Error with Messages! ListDiscussions")
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
        
        if self.LIST.count == 0{
            self.viewManager.showAsError()
        }
        
        Utils.printDebug("===> Request Error! ListDiscussions")
        Utils.printDebug("\(response)")
        
    }
    
    
    func onReloadAction(action: ErrorLayout) {
        
        Utils.printDebug("onReloadAction ErrorLayout")
        
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
    
    func onReloadAction(action: CustomLayout) {
        
        Utils.printDebug("Nice! open login interface")
        
        if Session.isLogged() {
            
            if let main = MainViewController.mInstance{
                main.startPeopleList()
            }
            
        }else{
            if let vc = MainViewController.mInstance {
                vc.startLoginVC()
            }
        }
        
        
        
       
        
    }
    
    
    
    func refreshToTop(object: Discussion) {
        
        
        
    }
    
    
    
    func markMessagesAsLoaded(discussionId: Int) {
    
        var parameters = ["test":""]
        
        if let user = myUserSession {
            parameters["user_id"] = String(user.id)
            parameters["discussionId"] = String(discussionId)
        }
        
        Utils.printDebug("inboxLoaded===> \(parameters)")
        
        self.isLoading = true
        self.discussionLoader.markMessagesAsLoaded(url: Constances.Api.API_INBOX_MARK_AS_LOADED, parameters: parameters, compilation: { parser in
        
            if let p = parser {
            
                if p.success == 1 {
                    
                }
                
            }
        
            
        })
      
    }
    
    
    
    
    
    
}
