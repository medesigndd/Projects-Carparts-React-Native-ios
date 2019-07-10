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

struct Messenger {
    static var nbrMessagesNotSeen = 0
}

class MessengerViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
        InboxLoaderDelegate, EmptyLayoutDelegate, ErrorLayoutDelegate, UITextFieldDelegate,OptionsDelegate, UserLoaderDelegate{
    
    //request
    var __req_page: Int = 1
    var __req_discussion: Int = 0
    
    
    //RESULT
    var GLOBAL_COUNT: Int = 0
    var LIST: [Message] = [Message]()
    
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()

    var discussionId: Int? = nil
    
    let senderCellId = "senderCellId"
    let receiverCellId = "receiverCellId"
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var viewContainer: UIView!
    
    @IBAction func onSendAction(_ sender: Any) {
        
        self.handleSend()
    }
    
    
    @IBOutlet weak var bottomContainerInput: UIView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    
    var discussionInstance: Discussion? = nil
    var client_id: Int? = nil
    
    func appBarTitle(title:String, subtitle:String) -> UIView {
        
        let titleLabel = UILabel(frame: CGRect(x: 0,y:  -3,width: 0,height:  0))
        
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white
        //titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        titleLabel.text = title
        titleLabel.textAlignment =  .center
        titleLabel.sizeToFit()
        titleLabel.font = titleLabel.font.withSize(16)
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0,y:  14,width: 0,height:  0))
        subtitleLabel.backgroundColor = UIColor.clear
        subtitleLabel.textColor = UIColor.white
        //subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 14)
        subtitleLabel.text = subtitle
        subtitleLabel.textAlignment =  .center
        subtitleLabel.sizeToFit()
        subtitleLabel.font = titleLabel.font.withSize(12)
        
        let titleView = UIView(frame: CGRect(x: 0,y: 0, width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width),height:  30))
        titleView.addSubview(titleLabel)
        titleView.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }

        
        return titleView
    }
    
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0)
        return view
    }()
    
    
    lazy var optionsLauncher: OptionsLauncher = {
        let launcher = OptionsLauncher()
        launcher.delegate = self
        return launcher
    }()
    
    
    @objc func handleMore() {
        
        optionsLauncher.clear()
        
        if let client = self.client_id  {
            
            if let user = User.findById(id: client) {
                
                if user.blocked {
                    
                    optionsLauncher.addBottomMenuItem(option: Option(
                        id: OptionsId.UNBLOCK,
                        name: "Unblock".localized,
                        image: optionsLauncher.createIcon(.ionicons(.androidClose)),
                        object: client
                    ))
                    
                }else{
                    
                    optionsLauncher.addBottomMenuItem(option: Option(
                        id: OptionsId.BLOCK,
                        name: "Block".localized,
                        image: optionsLauncher.createIcon(.ionicons(.androidClose)),
                        object: client
                    ))
                    
                    
                }
            }
  
            
        }
        
        optionsLauncher.load()
        optionsLauncher.showOptions()
        
    }
    
  
    func onOptionItemPressed(option: Option) {
        
        if let client = client_id {
            if option.id == OptionsId.BLOCK{
                
                self.block(user_id: client, state: true)
                
            }else if option.id == OptionsId.UNBLOCK{
                
                 self.block(user_id: client, state: false)
                
            }
        }
        
    }

   
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
        

        //more options icon
        let menuImage = UIImage.init(icon: .ionicons(.androidMoreVertical), size: CGSize(width: 30, height: 30), textColor: Colors.darkColor)
        let moreBarButtonItem = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(handleMore))
        moreBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: Colors.white)
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        navigationBarItem.rightBarButtonItems?.append(moreBarButtonItem)
        
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
        
        
        if let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout{
            //flow.estimatedItemSize = CGSize(width: view.frame.width, height: 20)
        }
        
        sendButton.setTitle("Send".localized, for: .normal)
        inputTextField.placeholder = "Enter message ...".localized
        
        if Utils.isRTL(){
             inputTextField.textAlignment = .right
        }
        
        if Session.isLogged() == false{
            self.dismiss(animated: true)
        }
        
        
        Messenger.nbrMessagesNotSeen = 0
        SwiftEventBus.post("on_badge_refresh", sender: true)
       
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        if self.client_id == nil {
            self.dismiss(animated: true)
        }
        
    
        if let client = client_id{
            self.last_message_id =  Message.getLastMessageId(client_id: client)
        }
        

        self.view.backgroundColor = Colors.bg_gray
        

     
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
    
        
        collectionView.dataSource = self
        collectionView.delegate = self
       
        
        collectionView.register(UINib(nibName: "MessageCell", bundle: nil), forCellWithReuseIdentifier: senderCellId)
        
        //get currenct date
        currentDate = DateUtils.getCurrentUTC(format: "yyyy-MM-dd HH:mm:ss")
        
        
        //load currenct discussion object from realm
        if let id = discussionId, let discussion = Discussion.getById(id: id) {
            self.discussionInstance = discussion
        }
        
        
        setupViewloader()
        
        setupNavBarTitles(name: "Messenger".localized, username: "Loading...".localized)
        //setup views
        setupNavBarButtons()
        
        
        
        if let client = self.client_id {
            
            if let user = User.findById(id: client) {
                
                setupNavBarTitles(name: user.name, username: "@"+user.username)
                
                //setup views
                setupNavBarButtons()
                setupInputComponents()
                setupRefreshControl()
                
                //load last messages
                //load()
                fetchStoredMessages()
                
                onReceiveListener()
                
            }else{
                syncUser()
            }
            
        }else{
            syncUser()
        }
     
        
       
        

        
    }
    

    
    func refreshInputField()  {
        
        if let client = client_id {
            if let user = User.findById(id: client) {
                
                if user.blocked {
                    self.sendButton.backgroundColor = Colors.gray
                    self.sendButton.isEnabled = false
                    self.inputTextField.isEnabled = false
                }else{
                    self.sendButton.backgroundColor = UIColor.clear
                    self.sendButton.isEnabled = true
                    self.inputTextField.isEnabled = true
                }
                
            }
        }
    }
    
    func fetchStoredMessages() {
        
        if let user = myUserSession, let clientId = client_id {
            
            if let messengerCache = MessengerCache.getCache(userId: user.id, clientId: clientId) {
                
                if messengerCache.id > 0{
                    self.__req_page = messengerCache.page
                    self.GLOBAL_COUNT = messengerCache.count
                    
                }
               
            }
            
            var messages = Message.findByDiscussion(userId: user.id, clientId: clientId)
            messages = messages.reversed()
            
      
            if self.GLOBAL_COUNT > 0 && self.__req_page > 1 && messages.count > 0 {
                
                      Utils.printDebug("\(messages) ")
                
                self.isLoading = true
                self.LIST = messages
                self.collectionView.reloadData()
                
                self.scrollToButtom(animate: true)
                
               
                DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                    self.isLoading = false
                }
               
                
            }else{
                self.__req_page = 1
                load()
            }
        }
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
    
          MessengerViewController.isAppear = true
        
        if let discussionId = self.discussionId, let discussion = Discussion.getById(id: discussionId) {
            
            if discussion.nbrMessages > 0 {
                self.markMessagesAsSeen(discussionId: discussionId)
            }
            
        }else if let discussionId = self.discussionId {
            
             self.markMessagesAsSeen(discussionId: discussionId)
            
        }
        
    }
    
    
    static var isAppear = false

    
    
    override func viewWillDisappear(_ animated: Bool) {
        
         //MessengerViewController.isAppear = false
        
        if let user = myUserSession, let clientId = client_id {
            
            let messengerCache = MessengerCache()
            
            messengerCache.id = clientId
            messengerCache.client_id = clientId
            messengerCache.user_id = user.id
            messengerCache.page = self.__req_page
            messengerCache.count = self.GLOBAL_COUNT
            
            messengerCache.save()
            
        
        }
        

       
    }
    
    func setupNavBarTitles(name: String, username: String) {
        
        var title  = ""
        var subtitle = ""
        
        title = name
        subtitle = username
        
        self.navigationBarItem.titleView = appBarTitle(title: title, subtitle: subtitle)
        
    }
    
    
    func onReceiveListener() {
        
        //get params
        SwiftEventBus.onMainThread(self, name: "on_receive_message") { result in
            
            if let object = result?.object{
                
                if Session.isLogged() {
                    
                    let message: Message = object as! Message
                    
                    guard let user = self.myUserSession  else {
                        self.pushNotificationIfNeeded(message: message)
                        return
                    }
                    
                    if message.receiver_id == user.id && message.senderId == self.client_id {
                        
                        self.LIST += [message]
                        self.collectionView.reloadData()
                        self.scrollToButtom(animate: true)
                       
                        message.save()
                    }else{
                        self.pushNotificationIfNeeded(message: message)
                    }
                    
                }
 
               
            }
            
        }
        
       
    }
   
    
    func pushNotificationIfNeeded(message: Message) {
        
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
    
    func keyboardDismiss() {
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       //self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.inputTextField.resignFirstResponder()
        return true
    }
    
    @objc func handleSend() {
        
        if let txt = inputTextField.text {
            
            if txt != "" {
                
                
               
                let messageId = Int(NSDate().timeIntervalSince1970)
                let message = createObject(text: txt,id: messageId)
                self.sendMessage(content: message)
                
                
                self.LIST += [message]
                self.collectionView.reloadData()
                self.inputTextField.text = ""
                self.scrollToButtom(animate: true)
                

//                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//
//                }
//
                
                
            }
            
        }
        
       // self.scrollToButtom(animate: true)
        
    }
    
    func createObject(text: String,id: Int) -> Message {
        
       
        let message = Message()
        message.date = DateUtils.getCurrent(format: DateUtils.defaultFormatUTC)
        message.message = text
        message.messageid = id
        message.senderId = (myUserSession?.id)!
        message.receiver_id = client_id!
        message.status = Message.Values.NO_SENT
        message.type = Message.Values.SENDER_VIEW
        
        return message
        
    }
    
    @objc func onBackHandler() {
        self.dismiss(animated: true)
    }
    
    
    
    @objc private func refreshData(_ sender: Any) {
       refreshControl.endRefreshing()
        
        if self.GLOBAL_COUNT == self.LIST.count{
            self.__req_page = 1
            load()
        }
        
        
    }
    
   
    private func setupInputComponents()  {
        
        inputTextField.placeholder = "Enter message...".localized

    
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        inputTextField.delegate = self
        
    }
    
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            
            print(keyboardFrame)
        
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
        
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
            
            self.scrollToButtom(animate: true)
            
        }
    }
    
    
    func scrollToButtom(animate: Bool) {
        
    
        
        if animate{
            
            UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                
                self.view.layoutIfNeeded()
                
            }, completion: { (completed) in
                
               self.collectionView.scrollToLast()
                
            })
        }else{
            
           self.collectionView.scrollToLast()
            
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        inputTextField.endEditing(true)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var size = CGSize.zero
        let message = self.LIST[indexPath.row]
        let attributedStr = NSMutableAttributedString.init(string: message.message)
        attributedStr.addAttributes([ NSAttributedStringKey.font : UIFont.systemFont(ofSize: 15) as Any],
                                    range: NSRange.init(location: 0, length: attributedStr.length))
        let rect = attributedStr.boundingRect(with: CGSize.init(width: 300, height:
            CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin,
                                              context: nil)
        
    
        size = CGSize.init(width: self.collectionView.frame.size.width, height: rect.size.height +
            CGFloat(Device.isPad ? 50 : 40))
        
        return size
//
//
//
//            if let collectionViewCell = collectionView.cellForItem(at: indexPath) as? MessageCell {
//
//            }
//
//            let messageText = LIST[indexPath.row].message
//
//            if messageText != "" {
//
//                let size = CGSize(width: 300, height: 20)
//                let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
//
//                let estimatedFrame = NSString(string: messageText).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 15)], context: nil)
//
//
//                Utils.printDebug("estimatedFrame_collectionView: \(estimatedFrame)")
//
//                var height = estimatedFrame.height
//
//                if height < 40 {
//                    height = 40
//                }
//
//                return CGSize(width: view.frame.width,height:  height + 25)
//            }
//
//            return CGSize(width: view.frame.width,height: 55)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        
        let object = LIST[indexPath.row]
        
    
        let cell: MessageCell  = collectionView.dequeueReusableCell(withReuseIdentifier: senderCellId, for: indexPath) as! MessageCell
        
      
        cell.setup(frame: view.frame, object: object)
      
        return cell
        
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
    
    var inboxLoader: InboxLoader = InboxLoader()
    
    private var last_message_id = -1
    
    func load () {
        
        self.viewManager.showAsLoading(parent: collectionView)
        
        self.inboxLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "30"
        ]
        
        
        if let user = myUserSession {
            parameters["user_id"] = String(user.id)
            parameters["sender_id"] = String(user.id)
            parameters["receiver_id"] = String(client_id!)
            parameters["status"] = "0"
            parameters["date"] = currentDate
           // parameters["last_id"] = String(last_message_id)
            parameters["page"] = String(__req_page)
        }
        
        
        
        Utils.printDebug("\(parameters)")
        
        self.isLoading = true
        self.inboxLoader.load(url: Constances.Api.API_LOAD_MESSAGES,parameters: parameters)
        
        
    }
    
    
    func sendMessage(content: Message) {
        
        
        self.inboxLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "30"
        ]
        
        
        if let user = myUserSession {
            parameters["user_id"] = String(user.id)
            parameters["sender_id"] = String(user.id)
            parameters["receiver_id"] = String(client_id!)
            parameters["content"] = content.message
            parameters["messageId"] = String(content.messageid)
        }
        
        
        
        Utils.printDebug("\(parameters)")
        
        self.isLoading = true
        self.inboxLoader.sendMessage(url: Constances.Api.API_SEND_MESSAGE,parameters: parameters)
        
        
    }
    
    
    func success(parser: MessageParser,response: String) {
        
        Utils.printDebug("===> Load success")
        
        self.viewManager.showAsEmpty()
        self.viewManager.showMain()
        
        //self.refreshControl.endRefreshing()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
             self.isLoading = false
        }
       
        
        if parser.success == 1 {
            
            var messages = parser.parse()
            
          
            Utils.printDebug("===> \(messages)")
            
           
            if messages.count > 0 {
                
                Utils.printDebug("Loaded \(messages.count)")
                
                if let user = myUserSession {
                     messages.validateAll(sessId: user.id)
                }
               
                messages = messages.reversed()
                
                if self.__req_page == 1 && parser.messageId == nil {
                    self.LIST = messages
                    self.GLOBAL_COUNT = parser.count
                }else{
                    
                    if let messageId = parser.messageId{
                        self.LIST = self.LIST.refresh(messageId: messageId, status: Message.Values.SENT)
                    }else{
                        
                        if self.__req_page > 1 {
                             self.LIST = messages+self.LIST
                        }else{
                             self.LIST += messages
                        }
                        
                        self.GLOBAL_COUNT = parser.count
                    }
                    
                }
                
                
        
                self.collectionView.reloadData()
                self.collectionView.reloadData()
                messages.saveAll()
                
                if self.__req_page == 1 {
                    self.scrollToButtom(animate: true)
                }
               
                if self.LIST.count < self.GLOBAL_COUNT || self.GLOBAL_COUNT < 30 {
                    self.__req_page += 1
                }
                
                
            }else{
                
                if self.LIST.count == 0  && self.__req_page == 1 {
                    collectionView.reloadData()
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
    
    
    func markMessagesAsSeen(discussionId: Int) {
        
        var parameters = ["test":""]
        
        if let user = myUserSession {
            parameters["user_id"] = String(user.id)
            parameters["discussionId"] = String(discussionId)
        }
        
        Utils.printDebug("markMessagesAsSeen===> \(parameters)")
        
        self.isLoading = true
        self.inboxLoader.markMessagesAsSeen(url: Constances.Api.API_INBOX_MARK_AS_SEEN, parameters: parameters, compilation: { parser in
        
        if let p = parser {
        
            if p.success == 1 {
                
            }

        }
        
        
        })
        
    }
    
    
    func block(user_id: Int, state: Bool) {
        
        if let user = myUserSession {
            
            MyProgress.showProgressWithSuccess(withStatus: "Success!".localized)
            
            let param = [
                "user_id": String(describing: user.id),
                "blocked_id":String(describing: user_id),
                "state": String(describing: state),
                ]
            
            Utils.printDebug("\(param)")
            
            let loader = SimpleLoader()
            loader.run(url: Constances.Api.API_BLOCK_USER, parameters: param) { (parser) in
                
                MyProgress.dismiss()
                
                if parser?.success == 1 {
                    
                    if let user = User.findById(id: user_id){
                        user.setBlockState(state)
                    }
                    
                    self.refreshInputField()
                    
                }
            }
            
        }
        
    }
    
    
    
    
    
    //load store
    var userLoader: UserLoader = UserLoader()
    
    func syncUser () {
        
        MyProgress.show(parent: self.view)
        self.userLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "1"
        ]
        
        if let user_id = self.client_id{
             parameters["uid"] = String(user_id)
        }
        
        Utils.printDebug("parameters: \(parameters)")
        
        self.userLoader.load(url: Constances.Api.API_GET_USERS,parameters: parameters)
        
    }
    
    func success(parser: UserParser,response: String) {
        
        self.viewManager.showMain()
        MyProgress.dismiss()
        
        Utils.printDebug("response: \(response)")
        
        if parser.success == 1 {
            
            let users = parser.parse()
            
            if users.count > 0 {
                
                users[0].save()
                
                self.client_id = users[0].id
                self.setupNavBarTitles(name: users[0].name, username: "@"+users[0].username)

            }else{
                viewManager.showAsEmpty()
            }
            
        }else {
            
            if parser.errors != nil {
                viewManager.showAsError()
            }
            
        }
        
    }

    

}






class CustomMessageinputTextField: UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                                     UIEdgeInsetsMake(0, 15, 0, 15))
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds,
                                     UIEdgeInsetsMake(0, 15, 0, 15))
    }
}
