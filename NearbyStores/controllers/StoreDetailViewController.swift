//
//  StoreDetailViewController.swift
//  NearbyStores
//
//  Created by Amine on 7/2/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import MXParallaxHeader
import GoogleMaps
import Kingfisher
import Atributika
import ImageSlideshow
import AssistantKit
import GoogleMobileAds

class StoreDetailViewController: MyUIViewController, ErrorLayoutDelegate, EmptyLayoutDelegate,GMSMapViewDelegate, RateDialogViewControllerDelegate, StoreLoaderDelegate,UIScrollViewDelegate,GADBannerViewDelegate {

    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        self.adContainer.isHidden = false
        if AppConfig.DEBUG {
            print("adViewDidReceiveAd")
        }
    }
    
    private var store: Store? = nil
    let slideShow = ImageSlideshow()
    
    
    //adview
    @IBOutlet weak var adSubContainer: UIView!
    @IBOutlet weak var adConstraintHeight: NSLayoutConstraint!
    @IBOutlet weak var adContainer: UIView!
    
    
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet weak var stackViewRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackViewLeftConstraint: NSLayoutConstraint!
    
    func setupSize()  {
        if Device.isPad{
            let width = self.view.frame.width/1.5
            let finalSize = self.view.frame.width-width
            self.stackViewLeftConstraint.constant = finalSize/2
        }
    }
    
    @IBOutlet weak var detailLabel: UILabel!
    
    
    @IBOutlet weak var categorySubContainer: UIView!
    @IBOutlet weak var category: UILabel!
    @IBOutlet weak var imageCategory: UIImageView!
    
    @IBAction func onCategoryAction(_ sender: Any) {
        
        if let id = self.storeId, let store = Store.findById(id: id){
            
            let sb = UIStoryboard(name: "StoresList", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: StoresLsitViewController = sb.instantiateViewController(withIdentifier: "storeslistVC") as! StoresLsitViewController
                
                ms.request = ListStoresCell.Request.nearby
                ms.category_id = store.category_id
                
                self.present(ms, animated: true)
                
            }
        }
        
    }
    
    
    
    
    @IBOutlet weak var mapsContainer: UIView!
    
    @IBOutlet weak var mapsSubContainer: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var last_offer: EdgeLabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    //
    @IBOutlet weak var constraintStoreDetailContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var storeDetailContainer: UIView! //view store
    @IBOutlet weak var storeDetailSubContainer: UIView! //subview store
//    @IBOutlet weak var storeDesctionTextview: UITextView!
//
    
    
    @IBOutlet weak var descriptionStoreLabel: AttributedLabel!
    
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var distance: EdgeLabel!
    
    @IBOutlet weak var featured: EdgeLabel!
    @IBOutlet weak var storeAddressSubContainer: UIView!
    @IBOutlet weak var storeAddress: UILabel!
    
    @IBOutlet weak var constraintStoreAddressHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var offerAndReviewsContainer: UIView!
    
    @IBOutlet weak var offerAndReviewesSubContainer: UIView!
    
    @IBOutlet weak var offers_reviews_frame: UIView!
    
    @IBOutlet weak var reviewsBtn: CustomButton!
    @IBOutlet weak var offersBtn: CustomButton!
    
    @IBOutlet weak var btnsContainer: UIView!
    
   
    @IBOutlet weak var chatBtn: UIButton!
    
    @IBOutlet weak var callBtn: UIButton!
    
    @IBOutlet weak var shareBtn: UIButton!
    
    
    @IBOutlet weak var saveBtn: UIButton!
    
    
    @IBOutlet weak var unsaveBtn: UIButton!
    
    @IBAction func chatAction(_ sender: Any) {
        
        if let store = self.store {
            
            if Session.isLogged(){
                startMessenger(client_id: store.user_id)
            }else{
                let sb = UIStoryboard(name: "Login", bundle: nil)
                if let vc = sb.instantiateInitialViewController() {
                    self.present(vc, animated: true)
                }
            }
            
        }
    }
    
    
    
    @IBAction func callAction(_ sender: Any) {
        
        if let store = self.store {
          
            if let url = URL(string: "tel://\(store.phone)"), UIApplication.shared.canOpenURL(url) {
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
    
   
    
    @IBAction func shareAction(_ sender: Any) {
        
        if let id = storeId, let store = Store.findById(id: id) {
            
            let lat = store.latitude
            let lng = store.longitude
            let link = "https://maps.google.com/?ll=\(lat),\(lng)"
            
            let text = "Shared from %@ \n\n%@ - %@ \n\nGet it in your Google Maps \n %@".localized.format(arguments: AppConfig.APP_NAME,store.name,store.address,link)
        
            
            let textShare = [ text ]
            let activityViewController = UIActivityViewController(activityItems: textShare , applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            self.present(activityViewController, animated: true, completion: nil)
            
        }
        
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        if let user = Session.getInstance()?.user, let store = self.storeId{
            
            let parameters = [
                "user_id": String(user.id),
                "store_id": String(store),
            ]
            
            let api = SimpleLoader()
            Utils.printDebug("\(Constances.Api.API_SAVE_STORE)")
            api.run(url: Constances.Api.API_SAVE_STORE, parameters: parameters) { (parser) in
                
                if parser?.success==1{
                    
                    SavedStores.save(id: store)
                    
                    if let ss = SavedStores.getInstance(){
                        Utils.printDebug("\(ss)")
                    }
                    
                    UIView.animate(withDuration: 0.15) {
                        self.unsaveBtn.isHidden = false
                        self.saveBtn.isHidden = true
                        self.btnsContainer.layoutIfNeeded()
                    }
                    
                    
                    
                }else{
                    UIView.animate(withDuration: 0.15) {
                        self.unsaveBtn.isHidden = true
                        self.saveBtn.isHidden = false
                        self.btnsContainer.layoutIfNeeded()
                    }
                }
            }
            
        }else{
            
            if let store = self.storeId{
                SavedStores.save(id: store)
                
                if let ss = SavedStores.getInstance(){
                    Utils.printDebug("\(ss)")
                }
            }
            
        }
        
        UIView.animate(withDuration: 0.15) {
            self.unsaveBtn.isHidden = false
            self.saveBtn.isHidden = true
            self.btnsContainer.layoutIfNeeded()
        }
        
    }
    
 
    @IBAction func unsaveAction(_ sender: Any) {
        
        if let user = Session.getInstance()?.user, let store = self.storeId{
            
            let parameters = [
                "user_id": String(user.id),
                "store_id": String(store),
            ]
            
            let api = SimpleLoader()
            Utils.printDebug("\(Constances.Api.API_REMOVE_STORE)")
            api.run(url: Constances.Api.API_REMOVE_STORE, parameters: parameters) { (parser) in
                
                if parser?.success==1{
                    
                    SavedStores.remove(id: store)
                    
                    if let ss = SavedStores.getInstance(){
                        Utils.printDebug("\(ss)")
                    }
                    
                    UIView.animate(withDuration: 0.15) {
                        self.unsaveBtn.isHidden = true
                        self.saveBtn.isHidden = false
                        self.btnsContainer.layoutIfNeeded()
                    }
                   
                    
                }else{
                    UIView.animate(withDuration: 0.15) {
                        self.unsaveBtn.isHidden = false
                        self.saveBtn.isHidden = true
                        self.btnsContainer.layoutIfNeeded()
                    }
                }
            }
            
        }else{
            
            if let store = self.storeId{
                SavedStores.remove(id: store)
                
                if let ss = SavedStores.getInstance(){
                    Utils.printDebug("\(ss)")
                }
            }
            
        }
        
        UIView.animate(withDuration: 0.15) {
            self.unsaveBtn.isHidden = true
            self.saveBtn.isHidden = false
            self.btnsContainer.layoutIfNeeded()
        }
        
        
    }
    
    
    @IBOutlet weak var constraintStoreOfferReviewContainerHeight: NSLayoutConstraint!
    
    @IBAction func offersBtnOnClick(_ sender: Any) {
        self.offersBtn(active: true)
        
        let calculatedHeight = self.offersAndReviews.offersView.calculatedHeight
        self.constraintStoreOfferReviewContainerHeight.constant = calculatedHeight+50+10
    
        self.offersAndReviews.layoutIfNeeded()
        self.scrollView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.15) { () -> Void in
            
            self.offersAndReviews.offersView.isHidden = false
            self.offersAndReviews.reviewsView.isHidden = true
            
            self.scrollView.contentOffset = CGPoint(x: 0,y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
            
        }
        
        
        let cr = self.offersAndReviews.offersView.list.count
        if cr == 0{
            if let id = self.storeId{
                self.offersAndReviews.loadOffers(store_id: id)
            }
        }
        
    }
    
    @IBAction func reviewsBtnOnClick(_ sender: Any) {
        
        self.reviewsActive()
    }
    
    func reviewsActive() {
        
        self.reviewsBtn(active: true)
        
        let calculatedHeight = self.offersAndReviews.reviewsView.calculatedHeight
        self.constraintStoreOfferReviewContainerHeight.constant = calculatedHeight+50+10
        
        self.offersAndReviews.layoutIfNeeded()
        self.scrollView.layoutIfNeeded()
        
        
        UIView.animate(withDuration: 0.15) { () -> Void in
            
            self.offersAndReviews.offersView.isHidden = true
            self.offersAndReviews.reviewsView.isHidden = false
            
            self.scrollView.contentOffset = CGPoint(x: 0,y: self.scrollView.contentSize.height - self.scrollView.bounds.size.height)
            
        }
        
        //refresh
        let cr = self.offersAndReviews.reviewsView.list.count
        if cr == 0{
            if let id = self.storeId{
                self.offersAndReviews.loadReviews(store_id: id)
            }
        }
    }
    
    
    var storeId: Int? = nil
    
    private var lastContentOffset: CGFloat = 0

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > scrollView.contentOffset.y) {
            // move up
            let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
          
            featured.alpha = CGFloat(alpha)
            last_offer.alpha = CGFloat(alpha)
           
            
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
             let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
           
            featured.alpha = CGFloat(alpha)
            last_offer.alpha = CGFloat(alpha)
           
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
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
            
            rateDialog.store_id = storeId
            rateDialog.delegate = self
        
            self.present(rateDialog, animated: true, completion: nil)
        }
        
    }
    
    func onRate(rating: Double, review: String) {
        //add review
        
        let message: [String: String] = ["alert": "Thank for your review!".localized]
        self.showAlertError(title: "Alert",content: message,msgBnt: "OK")
        
        if offersAndReviews.reviewsView.isHidden == false {
            offersAndReviews.reviewsView.clear()
            offersAndReviews.loadReviews(store_id: storeId!)
            self.reviewsActive()
        }
    }
    
   
    
    var mapView: GMSMapView? = nil
    
    
    func setupGoogleMaps(lat:Double,lng:Double) {
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 14.0)
        
        let width = self.mapsSubContainer.frame.width
        self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: width, height: self.mapsSubContainer.frame.height), camera: camera)
        
    

        mapView?.delegate = self
        mapView?.settings.setAllGesturesEnabled(false)
        
        if let mapView = self.mapView  {
            
            
            self.mapsSubContainer.addSubview(mapView)
            
            
            Utils.printDebug("mapView \(mapView.frame)")
            Utils.printDebug("mapsContainer \(mapsSubContainer.frame)")
            
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
        
         StoreDetailViewController.mInstance = self
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        
        
        self.setupNavBarTitles(title: "Store detail".localized)
        self.setupNavBarButtons()
        self.setupViewloader()
        self.setupViews()
        
        

        if let id = storeId, let _ = Store.findById(id: id){
            self.setupStoreDetail()
        }else{
            load()
        }
        
        
        // set up admob ads
        if(AppConfig.Ads.ADS_ENABLED && AppConfig.Ads.BANNER_IN_STORE_DETAIL_ENABLED){
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
        if interstitial.isReady &&   StoreDetailViewController.ad_seen==0 {
            interstitial.present(fromRootViewController: self)
            StoreDetailViewController.ad_seen += 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       
    }
    
    func setupViews() {
        
        self.scrollView.delegate = self
        
        self.view.backgroundColor = Colors.highlightedGray
        
        self.stackView.distribution = .fillProportionally
        
        scrollView.parallaxHeader.view = self.imageContainer
        scrollView.parallaxHeader.height = self.imageView.frame.height;
        scrollView.parallaxHeader.mode = .fill;
        scrollView.parallaxHeader.minimumHeight = 0;
        
    
        //distance tag
        distance.leftTextInset = 10
        distance.rightTextInset = 10
        distance.bottomTextInset = 5
        distance.topTextInset = 5
        distance.backgroundColor = Colors.primaryColor
        
        
        featured.leftTextInset = 10
        featured.rightTextInset = 10
        featured.bottomTextInset = 5
        featured.topTextInset = 5
        featured.backgroundColor = Colors.featuredTagColor
        featured.isHidden = true
        
        
        //offers tag
        last_offer.leftTextInset = 15
        last_offer.rightTextInset = 15
        last_offer.topTextInset = 10
        last_offer.bottomTextInset = 10
        last_offer.backgroundColor = Colors.primaryColor
        
        
        self.storeDetailSubContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.storeDetailSubContainer.layer.masksToBounds = true
        
        
        
        self.storeAddressSubContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.storeAddressSubContainer.layer.masksToBounds = true
        
        
        self.offerAndReviewsContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.offerAndReviewsContainer.layer.masksToBounds = true
        
        
        let frameSize = self.offerAndReviewsContainer.frame
        
        let buttonFrame = CGRect(x: 0, y: 0, width: CGFloat(frameSize.width/2), height: self.offersBtn.frame.height)
        
        
        self.offersBtn.frame = buttonFrame
        self.offersBtn.backgroundColor = Colors.primaryColor
        self.offersBtn.titleLabel?.textColor = Colors.white
      
        
        self.reviewsBtn.frame = buttonFrame
        self.offersBtn.frame = buttonFrame
       
        
        self.offersBtn(active: true)
        
        
        self.btnsContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.btnsContainer.layer.masksToBounds = true
    
        self.categorySubContainer.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.categorySubContainer.layer.masksToBounds = true
        
        
        self.chatBtn.setIcon(icon: .ionicons(.chatbubbles), iconSize: 20, color: .white, forState: .normal)
        self.callBtn.setIcon(icon: .ionicons(.androidCall), iconSize: 20, color: .white, forState: .normal)
        self.shareBtn.setIcon(icon: .openIconic(.share), iconSize: 20, color: .white, forState: .normal)
        self.saveBtn.setIcon(icon: .ionicons(.heart), iconSize: 20, color: .white, forState: .normal)
        self.unsaveBtn.setIcon(icon: .openIconic(.heart), iconSize: 20, color: Colors.primaryColor, forState: .normal)
        
        
        self.chatBtn.backgroundColor = Colors.primaryColor
        self.callBtn.backgroundColor = Colors.primaryColor
        self.shareBtn.backgroundColor = Colors.primaryColor
        self.saveBtn.backgroundColor = Colors.primaryColor
        self.unsaveBtn.backgroundColor = UIColor.white
        
        
        
        self.chatBtn.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.chatBtn.layer.masksToBounds = true
        
        self.callBtn.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.callBtn.layer.masksToBounds = true
        
        self.shareBtn.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.shareBtn.layer.masksToBounds = true
        
        self.saveBtn.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.saveBtn.layer.masksToBounds = true
        
        self.unsaveBtn.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.unsaveBtn.layer.masksToBounds = true
        
        
        
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
        self.detailLabel.text = "Store Detail".localized
        
        self.offersBtn.setTitle("Offers".localized, for: .normal)
        self.reviewsBtn.setTitle("Reviews".localized, for: .normal)
        
        
    }
    
    @objc func didTapOnImage() {
        self.slideShow.presentFullScreenController(from: self)
    }
    
    @objc func didTapOnGeoMaps() {
        
        if let id = storeId, let store = Store.findById(id: id){
            
            let sb = UIStoryboard(name: "GeoStore", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: GeoStoreViewController = sb.instantiateViewController(withIdentifier: "geostoreVC") as! GeoStoreViewController
                ms.latitude = store.latitude
                ms.longitude = store.longitude
                ms.name = store.name
                
                self.present(ms, animated: true)
            }
            
        }
        
    }
    
   
    
    func reviewsBtn(active: Bool) {
        
        UIView.animate(withDuration: 0.15) { () -> Void in
            
        
            self.reviewsBtn.backgroundColor = UIColor.white
            self.reviewsBtn.setTitleColor(Colors.primaryColor, for: .normal)
            
            self.offersBtn.backgroundColor = Colors.primaryColor
            self.offersBtn.setTitleColor(Colors.white, for: .normal)
            
            
        }
       
    }
    
    func offersBtn(active: Bool) {
        
        UIView.animate(withDuration: 0.15) { () -> Void in
            
            self.reviewsBtn.backgroundColor = Colors.primaryColor
            self.reviewsBtn.setTitleColor(Colors.white, for: .normal)
            
            self.offersBtn.backgroundColor = UIColor.white
            self.offersBtn.setTitleColor(Colors.primaryColor, for: .normal)
          
            
        }
       
    }
    
    let offersAndReviews =  OfferAndReviewsView()
    
    func setupStoreDetail()  {
        
        if let id = storeId, let store = Store.findById(id: id){
            
            
            if let session = Session.getInstance(), let user = session.user{
                if user.id == store.user_id{
                    self.chatBtn.isHidden = true
                }
            }
            
            self.store = store

            if SavedStores.exist(id: id) == true{
                self.saveBtn.isHidden = true
                self.unsaveBtn.isHidden = false
            }else{
                self.saveBtn.isHidden = false
                self.unsaveBtn.isHidden = true
            }
            
            
            if store.featured == 1 {
                self.featured.isHidden = false
            }else{
                self.featured.isHidden = true
            }
            
            
            
            if store.lastOffer != "" {
                last_offer.isHidden = false
                self.last_offer.text = store.lastOffer
            }else{
                last_offer.isHidden = true
            }
   
            let distance = store.distance.calculeDistance()
            self.distance.text = distance.getCurrent(type: Distance.Types.Kilometers)
            
            
            if  let cobj = Category.findById(id: store.category_id){
                self.category.text = cobj.nameCat
                
                if let image = cobj.images {
                    
                    let url = URL(string: image.url500_500)
                    
                    self.imageCategory.contentMode = .scaleAspectFill
                    self.imageCategory.kf.indicatorType = .activity
                    self.imageCategory.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                    
                }else{
                    if let img = UIImage(named: "default_store_image") {
                        self.imageCategory.image = img
                    }
                }
                
            }else{
                self.category.isHidden = true
            }
            
            
            
            //setup maps
            self.setupGoogleMaps(lat: store.latitude, lng: store.longitude)
            
            //setup imageview
            if store.listImages.count > 0 {
                
                var imagesInputs:[InputSource] = []
                
                for index in 0...store.listImages.count-1{
                    let url = store.listImages[index].url500_500
                    imagesInputs.append(KingfisherSource(urlString: url)!)
                }
                
                self.slideShow.setImageInputs(imagesInputs)
                
                
                if let first = store.listImages.first {
                    
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
            
            //setup store description and resize height of textview
         
            
            if store.detail != ""{
                
                let htmlText = store.detail.toHtml()
                
                self.storeDetailContainer.isHidden = false
                descriptionStoreLabel.numberOfLines = 90000
                descriptionStoreLabel.attributedText = htmlText
                descriptionStoreLabel.sizeToFit()
                
                DispatchQueue.main.asyncAfter(wallDeadline: .now()+2) {
                    
                    let size = CGSize(width: self.descriptionStoreLabel.frame.width, height: self.descriptionStoreLabel.frame.height)
                    let nsize = self.descriptionStoreLabel.sizeThatFits(size)
                    
                    self.descriptionStoreLabel.attributedText = htmlText
                    self.descriptionStoreLabel.heightAnchor.constraint(equalToConstant: nsize.height).isActive = true
                  //  self.constraintStoreDetailContainerHeight.constant = nsize.height+15+15+9+23+10
                    self.storeDetailSubContainer.layoutIfNeeded()
                    self.view.layoutIfNeeded()
                
                }
             
                
                descriptionStoreLabel.onClick = { label, detection in

                    switch detection.type {
                    case .link(let url):
                        UIApplication.shared.openURL(url)
                    default:
                        break
                    }
                }

            }
            
            
            
            
            //store address
           let size = self.calculateEstimatedFrame(content: store.address, fontSize: 15)
        
            let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 24, height: 24), textColor: Colors.primaryColor)
            
    
            self.storeAddress.text = store.address
            
            if Utils.isRTL(){
                self.storeAddress.setRightIcon(image: icon)
            }else{
                self.storeAddress.setLeftIcon(image: icon)
            }
            
            self.storeAddress.textColor = UIColor.gray
            
            self.constraintStoreAddressHeight.constant = size.height+50
        
            //store title
            self.setupNavBarTitles(title: store.name)
            
            
            
            //setup offers and reviews container
            offersAndReviews.viewController = self
            self.offerAndReviewesSubContainer.addSubview(offersAndReviews)
            
            offersAndReviews.store_id = store.id
            
            offersAndReviews.setPosition(parent: self.offerAndReviewesSubContainer)
            offersAndReviews.parentConstraint = self.constraintStoreOfferReviewContainerHeight
           
        
            offersAndReviews.loadOffers(store_id: store.id)
            offersAndReviews.loadReviews(store_id: store.id)
    
            
            offersAndReviews.reviewsView.isHidden = true
            offersAndReviews.offersView.isHidden = false
           
            
            if store.nbrOffers == 0 && Int(store.nbr_votes) == 0 {
                
                //offerAndReviewsContainer.isHidden = true
                offers_reviews_frame.isHidden = true
                self.constraintStoreOfferReviewContainerHeight.constant = 0
                
            }
  
        }else{
            //sync with server
            load()
        }
        
    }

    
    func onReloadAction(action: EmptyLayout) {
        
    }
    
    func onReloadAction(action: ErrorLayout) {
    
    }
    
    
    //load store
    var storeLoader: StoreLoader = StoreLoader()
    
    func load () {
        
        viewManager.showAsLoading()
    
        self.storeLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "1"
        ]
        
        if let guest = Guest.getInstance() {
            
            parameters["latitude"] = String(guest.lat)
            parameters["longitude"] = String(guest.lng)
            
          
            if let store_id = self.storeId{
                parameters["store_id"] = String(store_id)
            }
           
        }
        
        Utils.printDebug("\(parameters)")
        
        self.storeLoader.load(url: Constances.Api.API_USER_GET_STORES,parameters: parameters)
  
    }
    
    func success(parser: StoreParser,response: String) {
        
        self.viewManager.showMain()
       
        if parser.success == 1 {

            let stores = parser.parse()
           
            if stores.count > 0 {
                
                stores[0].save()
                self.setupStoreDetail()
                
            }else{
                viewManager.showAsEmpty()
            }
            
        }else {
            
            if let errors = parser.errors {
                viewManager.showAsError()
            }
            
        }
        
    }
    
   
    
    func error(error: Error?,response: String) {
        
        self.viewManager.showAsError()
        
        Utils.printDebug("===> Request Error! ListStores")
        Utils.printDebug("\(response)")
        
    }
    
    func calculateEstimatedFrame(content: String,fontSize: Float) -> CGSize {
        
        let size = CGSize(width: 250, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let estimatedFrame = NSString(string: content).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: CGFloat(fontSize))], context: nil)
        
    
        let width = estimatedFrame.width
        let height = estimatedFrame.height
       
        return CGSize(width: width, height: height)
    }
    
    static var mInstance: StoreDetailViewController? = nil
    
    func startReviewsLsit(store_id: Int)  {
        
        let sb = UIStoryboard(name: "ReviewsList", bundle: nil)
        
        if sb.instantiateInitialViewController() != nil {
            
            
            let ms: ReviewsListViewController = sb.instantiateViewController(withIdentifier: "reviewsListVC") as! ReviewsListViewController
            ms.store_id = store_id
            
            self.present(ms, animated: true)
        }
    }
    
    func startOffersLsit(store_id: Int)  {
        
        let sb = UIStoryboard(name: "OffersList", bundle: nil)
        
        if sb.instantiateInitialViewController() != nil {
            
            let ms: OffersLsitViewController = sb.instantiateViewController(withIdentifier: "offersListVC") as! OffersLsitViewController
            ms.store_id = store_id
            
            self.present(ms, animated: true)
        }
    }
    
    
    func startMessenger(client_id: Int) {
        
        let sb = UIStoryboard(name: "Messenger", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: MessengerViewController = sb.instantiateViewController(withIdentifier: "messengerVC") as! MessengerViewController
            ms.client_id = client_id
            present(ms, animated: true)
        }
        
    }
    
    
    func startOfferDetailVC(offerId: Int) {
        
        let sb = UIStoryboard(name: "OfferDetail", bundle: nil)
        if sb.instantiateInitialViewController() != nil {
            
            let ms: OfferDetailViewController = sb.instantiateViewController(withIdentifier: "offerdetailVC") as! OfferDetailViewController
            
            ms.offer_id = offerId
            
            self.present(ms, animated: true)
        }
        
    }
    
    

   

}
