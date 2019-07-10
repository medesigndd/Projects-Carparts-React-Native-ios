//
//  OfferDetailViewController.swift
//  NearbyStores
//
//  Created by Amine on 7/10/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Atributika
import GoogleMaps
import ImageSlideshow
import AssistantKit
import GoogleMobileAds

class EventDetailViewController: MyUIViewController, EmptyLayoutDelegate,ErrorLayoutDelegate, EventLoaderDelegate, UIScrollViewDelegate, GMSMapViewDelegate, GADBannerViewDelegate  {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.adContainer.isHidden = false
        
        if AppConfig.DEBUG {
            print("adViewDidReceiveAd")
        }
    }
    
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        
        if AppConfig.DEBUG {
            print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        }
        
    }
    
    //Declare User For Current Session
    var myUserSession: User? = nil
    let slideShow = ImageSlideshow()
    
    //adview
    @IBOutlet weak var adSubContainer: UIView!
    @IBOutlet weak var adConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var adContainer: UIView!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
 
    
     @IBOutlet weak var mapsContainer: UIView!
    
    @IBOutlet weak var event_dates: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var stackview: UIStackView!
    
    @IBOutlet weak var stackViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeftConstraint: NSLayoutConstraint!
    
    func setupSize()  {
        if Device.isPad{
            let width = self.view.frame.width/1.5
            let finalSize = self.view.frame.width-width
            self.stackViewLeftConstraint.constant = finalSize/2
        }
    }
    
    
    
    
    @IBOutlet weak var imageContainer: UIView!
    
    
    @IBOutlet weak var imageView: UIImageView!
    //
    @IBOutlet weak var constraintDescriptionContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionContainer: UIView! //view store
    @IBOutlet weak var descriptionSubContainer: UIView! //subview store
    
    @IBOutlet weak var desctionTextView: AttributedLabel!
    
    @IBOutlet weak var detailLabel: UILabel!
    
    
    
    @IBOutlet weak var distance: EdgeLabel!
    @IBOutlet weak var featured: EdgeLabel!
    @IBOutlet weak var storeAddressSubContainer: UIView!
    @IBOutlet weak var storeAddress: UILabel!
    @IBOutlet weak var constraintStoreAddressHeight: NSLayoutConstraint!
    
    @IBOutlet weak var storeAddressContainer: UIView!
    
    @IBOutlet weak var storeAddressBtn: UIButton!
    
    @IBAction func onStoreNameClicked(_ sender: Any) {
        
        if let id = event_id, let event = Event.findById(id: id){
            let sb = UIStoryboard(name: "StoreDetail", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: StoreDetailViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailViewController
                ms.storeId = event.store_id
                
                self.present(ms, animated: true)
            }
        }
    }
    
    
    @IBOutlet weak var phone: UILabel!
    
    @IBOutlet weak var phoneContainer: UIView!
    
    @IBOutlet weak var phoneSubContainer: UIView!
    
    @IBAction func phoneCallAction(_ sender: Any) {
        
        if let id = event_id, let event = Event.findById(id: id) {
            
            if let url = URL(string: "tel://\(event.tel)"), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }else{
                let message: [String:String] = ["alert":"This app is not allowed to query for scheme tel".localized]
                self.showAlertError(title: "Alert!".localized, content: message, msgBnt: "OK".localized)
            }
            
        }
        
    }
    
    @IBOutlet weak var websiteContainer: UIView!
    
    @IBOutlet weak var websiteSubContainer: UIView!
    
    @IBOutlet weak var website: UILabel!
    
    @IBAction func websiteOpenAction(_ sender: Any) {
        
        if let id = event_id, let event = Event.findById(id: id) {
            
            if let url = URL(string: event.webSite), UIApplication.shared.canOpenURL(url) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
        }
        
    }
    
    
    @IBOutlet weak var participate: UIButton!
    
    @IBOutlet weak var unparticipate: UIButton!
    
    @IBAction func participateAction(_ sender: Any) {
        
        if let id = self.event_id, let event = Event.findById(id: id){
            
            SavedEvents.save(id: event.id)
            UpComingEvent.save(event_id: event.id, event_name: event.name, begin_at: event.dateBegin)
            
        }
    
        UIView.animate(withDuration: 0.15) {
            self.unparticipate.isHidden = false
            self.participate.isHidden = true
            self.view.layoutIfNeeded()
        }
        
    }
    
    @IBAction func unparticipateAction(_ sender: Any) {
        
        if let event = self.event_id{
            SavedEvents.remove(id: event)
            UpComingEvent.remove(event_id: event)
        }
        
        UIView.animate(withDuration: 0.15) {
            self.unparticipate.isHidden = true
            self.participate.isHidden = false
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    
    private var lastContentOffset: CGFloat = 0
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
            
            featured.alpha = CGFloat(alpha)
            distance.alpha = CGFloat(alpha)
            
            
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
            let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
            
            featured.alpha = CGFloat(alpha)
            distance.alpha = CGFloat(alpha)
            
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func setupViews() {
        
        
        scrollView.delegate = self
        
        self.view.backgroundColor = Colors.highlightedGray
        
        self.stackview.distribution = .fillProportionally
        
        scrollView.parallaxHeader.view = self.imageContainer
        scrollView.parallaxHeader.height = self.imageView.frame.height;
        scrollView.parallaxHeader.mode = .fill;
        scrollView.parallaxHeader.minimumHeight = 0;
        
        
        //distance tag
        distance.leftTextInset = 15
        distance.rightTextInset = 15
        distance.bottomTextInset = 10
        distance.topTextInset = 10
        distance.backgroundColor = Colors.primaryColor
        
     
        featured.leftTextInset = 10
        featured.rightTextInset = 10
        featured.bottomTextInset = 5
        featured.topTextInset = 5
        featured.backgroundColor = Colors.featuredTagColor
        featured.isHidden = true
        
        
        
        self.descriptionSubContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.descriptionSubContainer.layer.masksToBounds = true
        
        
        self.storeAddressSubContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.storeAddressSubContainer.layer.masksToBounds = true
        
        
        self.participate.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.participate.layer.masksToBounds = true
        
        self.unparticipate.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.unparticipate.layer.masksToBounds = true

        
        self.phoneSubContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.phoneSubContainer.layer.masksToBounds = true
        

        self.websiteSubContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.websiteSubContainer.layer.masksToBounds = true
        
        self.slideShow.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(
            item: self.slideShow,
            attribute: NSLayoutAttribute.right,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.imageView,
            attribute: NSLayoutAttribute.right,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self.slideShow,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.imageView,
            attribute: NSLayoutAttribute.top,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self.slideShow,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.imageView,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self.slideShow,
            attribute: NSLayoutAttribute.left,
            relatedBy: NSLayoutRelation.equal,
            toItem: self.imageView,
            attribute: NSLayoutAttribute.left,
            multiplier: 1, constant: 0)
        )
        
        
        self.imageView.addSubview(slideShow)
        self.imageView.addConstraints(constraints)
        //self.imageView.layoutIfNeeded()
        //self.slideShow.isHidden = true
        
        self.slideShow.pageIndicator = nil
        self.slideShow.contentScaleMode = .scaleAspectFill
        
        let gestureRecognizerImageView = UITapGestureRecognizer(target: self, action: #selector(didTapOnImage))
        self.imageContainer.addGestureRecognizer(gestureRecognizerImageView)
        
        let gestureRecognizerGeoMap = UITapGestureRecognizer(target: self, action: #selector(didTapOnGeoMaps))
        self.mapsContainer.addGestureRecognizer(gestureRecognizerGeoMap)
        
        
        //localization
        self.featured.text = "Featured".localized
        self.detailLabel.text = "Event Detail".localized
   
        
    }
    
    @objc func didTapOnImage() {
        self.slideShow.presentFullScreenController(from: self)
    }
    
    
    @objc func didTapOnGeoMaps() {
        
        if let id = event_id, let event = Event.findById(id: id){
            
            let sb = UIStoryboard(name: "GeoStore", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: GeoStoreViewController = sb.instantiateViewController(withIdentifier: "geostoreVC") as! GeoStoreViewController
                ms.latitude = event.lat
                ms.longitude = event.lng
                ms.name = event.name
                
                self.present(ms, animated: true)
            }
            
        }
        
    }
    
    var mapView: GMSMapView? = nil
    
    
    func setupGoogleMaps(lat:Double,lng:Double) {
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14.0)
        
        let width = self.mapsContainer.frame.width
        
        self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: width, height: self.mapsContainer.frame.height), camera: camera)
        
       
        
        mapView?.delegate = self
        mapView?.settings.setAllGesturesEnabled(false)
        
        if let mapView = self.mapView  {
            
            
            self.mapsContainer.addSubview(mapView)
            
            
            Utils.printDebug("mapView \(mapView.frame)")
            Utils.printDebug("mapsContainer \(mapsContainer.frame)")
            
            mapView.backgroundColor = UIColor.yellow
            
            mapView.animate(toZoom: 14)
            // Creates a marker in the center of the map.
            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude:  lat, longitude: lng)
            marker.map = mapView
            
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 15)
            self.mapView?.camera = camera
            self.mapView?.animate(to: camera)
            
            
            
            self.mapView?.isHidden = true
            
            DispatchQueue.main.asyncAfter(deadline: .now()+1) {
                
                let frame = self.mapsContainer.bounds
                self.mapView?.frame = frame
                self.mapView?.bounds = self.mapsContainer.bounds
                self.view.layoutIfNeeded()
                
                
                self.mapView?.isHidden = false
                
                Utils.printDebug("bounds: \(self.mapsContainer.bounds)")

            }
            
            
            
        }
        
    }
    
    //Admob Configure & Setup
    var bannerView: GADBannerView!
    func adSetup(_ bannerView: GADBannerView) {
        
        self.bannerView.translatesAutoresizingMaskIntoConstraints = false
        self.adSubContainer.addSubview(bannerView)
        self.adSubContainer.addConstraints(
            [
                NSLayoutConstraint(item: self.bannerView,
                                   attribute: .centerX,
                                   relatedBy: .equal,
                                   toItem: self.adSubContainer,
                                   attribute: .centerX,
                                   multiplier: 1,
                                   constant: 0),
                NSLayoutConstraint(item: self.bannerView,
                                   attribute: .centerY,
                                   relatedBy: .equal,
                                   toItem: self.adSubContainer,
                                   attribute: .centerY,
                                   multiplier: 1,
                                   constant: 0),
                ])
        
        self.bannerView.adUnitID = AppConfig.Ads.AD_BANNER_ID
        self.bannerView.rootViewController = self
        self.bannerView.load(GADRequest())
        
        self.adConstraintHeight.constant = bannerView.frame.height+20
        
        
        self.bannerView.delegate = self
        self.adContainer.isHidden = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.setupSize()
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        if let id = self.event_id{
            if SavedEvents.exist(id: id) {
                self.unparticipate.isHidden = false
                self.participate.isHidden = true
            }
        }
        
        
        self.view.backgroundColor = Colors.bg_gray
        
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        
        
        setupNavBarTitles(title: "Offer detail".localized)
        setupNavBarButtons()
        setupViews()
        
        
        if let id = event_id, let _ = Event.findById(id: id){
            self.setupEventDetail()
        }else{
            load()
        }
        
        
        // set up admob ads
        if(AppConfig.Ads.ADS_ENABLED && AppConfig.Ads.BANNER_IN_EVENT_DETAIL_ENABLED){
            bannerView = GADBannerView(adSize: kGADAdSizeBanner)
            adSetup(bannerView)
        }else{
            self.adContainer.isHidden = true
        }
        
        if AppConfig.Ads.ADS_ENABLED && AppConfig.Ads.ADS_INTERSTITIEL_ENABLED{
            interstitial = GADInterstitial(adUnitID: AppConfig.Ads.AD_INTERSTITIEL_ID)
            let request = GADRequest()
            interstitial.load(request)
        }
        
    }
    
    private static var ad_seen = 0
    var interstitial: GADInterstitial!
    
    func showInterstitial()  {
        if interstitial.isReady &&   EventDetailViewController.ad_seen==0 {
            interstitial.present(fromRootViewController: self)
            EventDetailViewController.ad_seen += 1
        }
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//       EventDetailViewController.isAppear = false
//    }
    
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        EventDetailViewController.isAppear = true
        
    }
    
    
    static var isAppear = false
    
    
    let topBarTitle: EdgeLabel = {
        
        let titleLabel = EdgeLabel()
        
        titleLabel.text = ""
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        
        return titleLabel
        
    }()
    
    func setupNavBarTitles(title: String) {
        
        
        let rect = CGRect(x: 0, y: 0, width: view.frame.width - 32, height: view.frame.height)
        topBarTitle.frame = rect
        topBarTitle.textColor = UIColor.white
        topBarTitle.font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17)
        topBarTitle.leftTextInset = 5
        
        
        topBarTitle.text = title
        
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    func setupEventDetail()  {
        
        
        if let id = event_id, let event = Event.findById(id: id){
            
            Utils.printDebug("\(event)")
            
            if event.featured == 1 {
                self.featured.isHidden = false
            }else{
                self.featured.isHidden = true
            }
            
            
            
            let distance = event.distance.calculeDistance()
            self.distance.text = distance.getCurrent(type: Distance.Types.Kilometers)
            
            
            //setup maps
            self.setupGoogleMaps(lat: event.lat, lng: event.lng)
            
            
            //setup images
            if event.listImages.count > 0 {
                
                var imagesInputs:[InputSource] = []
                
                for index in 0...event.listImages.count-1{
                    let url = event.listImages[index].url500_500
                    imagesInputs.append(KingfisherSource(urlString: url)!)
                }
                
                self.slideShow.setImageInputs(imagesInputs)
                
                
                if let first = event.listImages.first {
                    
                    let url = URL(string: first.url500_500)
                    self.imageView.kf.indicatorType = .activity
                    self.imageView.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                    
                }else{
                    if let img = UIImage(named: "default_store_image") {
                        self.imageView.image = img
                    }
                }
            }else{
                
                if let img = UIImage(named: "default_store_image") {
                    self.imageView.image = img
                }
                
            }
            
            
            //setup description
            if event.desc != ""  {
                
               
                if  event.desc != "" {
                    
                    let htmlText = event.desc.toHtml()
                    
                    self.descriptionContainer.isHidden = false
                    desctionTextView.numberOfLines = 0
                    desctionTextView.attributedText = htmlText
                    desctionTextView.sizeToFit()
                    
                    
                    DispatchQueue.main.asyncAfter(wallDeadline: .now()+2) {
                        
                        let size = CGSize(width: self.desctionTextView.frame.width, height: self.desctionTextView.frame.height)
                        let nsize = self.desctionTextView.sizeThatFits(size)
                        
                        self.desctionTextView.attributedText = htmlText
                        self.desctionTextView.heightAnchor.constraint(equalToConstant: nsize.height).isActive = true
                        
                        //self.constraintDescriptionContainerHeight.constant = nsize.height+15+15+15+23+200
                        self.descriptionSubContainer.layoutIfNeeded()
                        self.view.layoutIfNeeded()
                        
                    }
                    
                }
                
            }else{
                self.descriptionContainer.isHidden = true
            }
            
            
            
            //store address
            
            if event.store_name != "" {
                
                let size = self.calculateEstimatedFrame(content: event.store_name, fontSize: 14 )
                
                let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 24, height: 24), textColor: Colors.primaryColor)
                
                self.storeAddress.text = event.store_name
                
                if Utils.isRTL(){
                    self.storeAddress.setRightIcon(image: icon)
                }else{
                    self.storeAddress.setLeftIcon(image: icon)
                }
                
                self.storeAddress.textColor = Colors.primaryColor
                
                self.constraintStoreAddressHeight.constant = size.height+60
                
                
            }else{
                
                let size = self.calculateEstimatedFrame(content: event.address, fontSize: 15)
                
                let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 24, height: 24), textColor: Colors.primaryColor)
                
                self.storeAddress.text = event.address
                
                if Utils.isRTL(){
                    self.storeAddress.setRightIcon(image: icon)
                }else{
                    self.storeAddress.setLeftIcon(image: icon)
                }
                
                self.storeAddress.textColor = UIColor.gray
                
                self.constraintStoreAddressHeight.constant = size.height+60
                
                self.storeAddressBtn.isHidden = true
            
            }
            
            //setup website
            if event.webSite != "" {
                
                let icon = UIImage.init(icon: .googleMaterialDesign(.web), size: CGSize(width: 24, height: 24), textColor: Colors.primaryColor)
                self.website.text = event.webSite
                
                if Utils.isRTL(){
                     self.website.setRightIcon(image: icon)
                }else{
                     self.website.setLeftIcon(image: icon)
                }
               
                self.website.textColor = Colors.primaryColor
            }else{
                //hide
                self.websiteContainer.isHidden = true
            }
            
            //setup phone number
            if event.tel != "" {
                let icon = UIImage.init(icon: .googleMaterialDesign(.phone), size: CGSize(width: 24, height: 24), textColor: Colors.primaryColor)
                self.phone.text = event.tel
               
                if Utils.isRTL(){
                     self.phone.setRightIcon(image: icon)
                }else{
                     self.phone.setLeftIcon(image: icon)
                }
                
                self.phone.textColor = Colors.primaryColor
            }else{
                //hide
                 self.phoneContainer.isHidden = true
            }
        
           
            //store title
            self.setupNavBarTitles(title: event.name)
            
            
            //setup dates
            let begin_at = DateUtils.UTCToLocal(date: event.dateBegin, fromFormat: DateFomats.defaultFormatTimeUTC, toFormat:  DateFomats.defaultFormatUTC)
            let end_at = DateUtils.UTCToLocal(date: event.dateEnd, fromFormat:  DateFomats.defaultFormatTimeUTC, toFormat:  DateFomats.defaultFormatUTC)
            
         //   self.eventDates.text = "\(begin_at) - \(end_at)"
            
            let icon = UIImage.init(icon: .googleMaterialDesign(.dateRange), size: CGSize(width: 24, height: 24), textColor: Colors.primaryColor)
            
            
            self.event_dates.text = "\(begin_at) - \(end_at)"
            self.event_dates.setLeftIcon(image: icon)
            
            
        }
        
    }
    
    
    var event_id: Int? = nil
    
    
    //load store
    var eventLoader: EventLoader = EventLoader()
    
    func load () {
        
        
        self.eventLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "1"
        ]
        
        if let guest = Guest.getInstance() {
            
            parameters["latitude"] = String(guest.lat)
            parameters["longitude"] = String(guest.lng)
            
            
            if let event_id = self.event_id{
                parameters["event_id"] = String(event_id)
            }
            
        }
        
        Utils.printDebug("\(parameters)")
        
        self.eventLoader.load(url: Constances.Api.API_USER_GET_EVENTS,parameters: parameters)
        
    }
    
    func success(parser: EventParser,response: String) {
        
        self.viewManager.showMain()
        
        if parser.success == 1 {
            
            let events = parser.parse()
            
            if events.count > 0 {
                
                events[0].save()
                self.setupEventDetail()
                
            }else{
                viewManager.showAsEmpty()
            }
            
        }else {
            
            if parser.errors != nil {
                viewManager.showAsError()
            }
            
        }
        
    }
    
    
    
    func error(error: Error?,response: String) {
        
        self.viewManager.showAsError()
        
        Utils.printDebug("===> Request Error! ListStores")
        Utils.printDebug("\(response)")
        
    }
    
    func calculateEstimatedFrame(content: String,fontSize: Float,defWidth: CGFloat) -> CGSize {
        
        let size = CGSize(width: defWidth, height: 1500)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: content).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
        
        
        let width = estimatedFrame.width
        let height = estimatedFrame.height
        
        return CGSize(width: width, height: height)
    }
    
    func calculateEstimatedFrame(content: String,fontSize: Float) -> CGSize {
        
        let size = CGSize(width: 250, height: 1500)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: content).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
        
        
        let width = estimatedFrame.width
        let height = estimatedFrame.height
        
        return CGSize(width: width, height: height)
    }
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
    func setupViewloader()  {
        
        //setup view loader, Error, Empty layouts
        viewManager.setup(parent: view)
        viewManager.getEmptyLayout().delegate = self
        viewManager.getErrorLayout().delegate = self
        
        if Session.isLogged() ==  false {
            
            return
        }else{
            
        }
    }
    
    func onReloadAction(action: EmptyLayout) {
        
    }
    
    func onReloadAction(action: ErrorLayout) {
        
    }
    
    
    
    
}
