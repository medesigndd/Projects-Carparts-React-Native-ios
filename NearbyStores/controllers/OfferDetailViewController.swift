//
//  OfferDetailViewController.swift
//  NearbyStores
//
//  Created by Amine on 7/10/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Atributika
import ImageSlideshow
import AssistantKit
import GoogleMobileAds

class OfferDetailViewController: MyUIViewController, EmptyLayoutDelegate,ErrorLayoutDelegate, OfferLoaderDelegate, UIScrollViewDelegate,GADBannerViewDelegate  {
   
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
    
    @IBOutlet weak var imageView: UIImageView!
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
    //
    @IBOutlet weak var constraintDescriptionContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var descriptionContainer: UIView! //view store
    @IBOutlet weak var descriptionSubContainer: UIView! //subview store
    @IBOutlet weak var descriptionLabel: AttributedLabel!
    
    @IBOutlet weak var offerDetailLabel: UILabel!
    
    
    
    @IBOutlet weak var distance: EdgeLabel!
    @IBOutlet weak var offer: EdgeLabel!
    
    @IBOutlet weak var featured: EdgeLabel!
    @IBOutlet weak var storeAddressSubContainer: UIView!
    @IBOutlet weak var storeAddress: UILabel!
    
    @IBOutlet weak var constraintStoreAddressHeight: NSLayoutConstraint!
    
  
    @IBAction func onStoreNameClicked(_ sender: Any) {
        
        if let id = offer_id, let offer = Offer.findById(id: id){
            let sb = UIStoryboard(name: "StoreDetail", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: StoreDetailViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailViewController
                ms.storeId = offer.store_id
                
                self.present(ms, animated: true)
            }
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
            offer.alpha = CGFloat(alpha)
            distance.alpha = CGFloat(alpha)
           
            
        }
        else if (self.lastContentOffset < scrollView.contentOffset.y) {
            // move down
            let y = scrollView.contentOffset.y+180
            let c = y*0.01
            let alpha = 1-c
            
            featured.alpha = CGFloat(alpha)
            offer.alpha = CGFloat(alpha)
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
        
        //offers tag
        offer.leftTextInset = 15
        offer.rightTextInset = 15
        offer.topTextInset = 10
        offer.bottomTextInset = 10
        offer.backgroundColor = Colors.darkColor
        
        
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
        
    
        //localization
        self.featured.text = "Featured".localized
        self.offerDetailLabel.text = "Offer Detail".localized
        
    }
    
    @objc func didTapOnImage() {
        self.slideShow.presentFullScreenController(from: self)
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
        
        setupSize()
        
        if let session = Session.getInstance(), let user = session.user {
            myUserSession = user
        }
        
        self.view.backgroundColor = Colors.bg_gray
        
    
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        
       
       
        setupNavBarTitles(title: "Offer detail")
        setupNavBarButtons()
        setupViews()
        
        
        if let id = offer_id, let _ = Offer.findById(id: id){
            self.setupOfferDetail()
        }else{
            load()
        }
        
        
        // set up admob ads
        if(AppConfig.Ads.ADS_ENABLED && AppConfig.Ads.BANNER_IN_OFFER_DETAIL_ENABLED){
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
        if interstitial.isReady &&   OfferDetailViewController.ad_seen==0 {
            interstitial.present(fromRootViewController: self)
            OfferDetailViewController.ad_seen += 1
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        OfferDetailViewController.isAppear = false
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
    
    
    override func viewWillAppear(_ animated: Bool) {
        
       OfferDetailViewController.isAppear = true
        
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
    
    
    func setupOfferDetail()  {
        
        if let id = offer_id, let offer = Offer.findById(id: id){
            
            Utils.printDebug("\(offer)")
            
            if offer.featured == 1 {
                self.featured.isHidden = false
            }else{
                self.featured.isHidden = true
            }
            
            
            
            let distance = offer.distance.calculeDistance()
            self.distance.text = distance.getCurrent(type: Distance.Types.Kilometers)
            
            

            //setup imageview
            if let images = offer.images {
                
                //let url = URL(string: images.url500_500)
                //self.imageView.kf.indicatorType = .activity
                //self.imageView.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                
                let imagesInputs:[InputSource] = [KingfisherSource(urlString: images.url500_500)!]
                self.slideShow.setImageInputs(imagesInputs)
                
                
            }else{
                
                if let img = UIImage(named: "default_store_image") {
                    self.imageView.image = img
                }
                
            }
            
            
            //setup description
            if let content = offer.content {
                
                
                if content.percent > 0 || content.percent<0 {
                    
                    self.offer.text = "\(content.percent)%"
                    
                }else if content.price != 0 {
                    if let currency = content.currency {
                        if let pprice = currency.parseCurrencyFormat(price: content.price){
                            self.offer.text = pprice
                        }
                    }
                }
                
                Utils.printDebug("\(content.desc)")
                
                if  content.desc != "" {
                    
                    let htmlText = content.desc.toHtml()
                    
                    self.descriptionContainer.isHidden = false
                    descriptionLabel.numberOfLines = 0
                    descriptionLabel.attributedText = htmlText
                    descriptionLabel.sizeToFit()
                    
                    
                    DispatchQueue.main.asyncAfter(wallDeadline: .now()+2) {
                        
                        let size = CGSize(width: self.descriptionLabel.frame.width, height: self.descriptionLabel.frame.height)
                        let nsize = self.descriptionLabel.sizeThatFits(size)
                        
                        self.descriptionLabel.attributedText = htmlText
                        self.descriptionLabel.heightAnchor.constraint(equalToConstant: nsize.height).isActive = true
                        
                       //self.constraintDescriptionContainerHeight.constant = nsize.height+15+15+9+23+10
                        self.descriptionSubContainer.layoutIfNeeded()
                        self.view.layoutIfNeeded()
                        
                    }
                    
                    
                    descriptionLabel.onClick = { label, detection in
                        
                        switch detection.type {
                        case .link(let url):
                            UIApplication.shared.openURL(url)
                        default:
                            break
                        }
                    }
                    
                }
                
            }else{
                self.descriptionContainer.isHidden = true
            }
            
            
            
            //store address
            let size = self.calculateEstimatedFrame(content: offer.store_name, fontSize: 15)
            
            let icon = UIImage.init(icon: .googleMaterialDesign(.place), size: CGSize(width: 24, height: 24), textColor: Colors.primaryColor)
            
            
            self.storeAddress.text = offer.store_name
            
            if Utils.isRTL(){
                self.storeAddress.setRightIcon(image: icon)
            }else{
                self.storeAddress.setLeftIcon(image: icon)
            }
            
            self.storeAddress.textColor = UIColor.gray
           
            self.constraintStoreAddressHeight.constant = size.height+60
            
            //store title
            self.setupNavBarTitles(title: offer.name)
            
            
        }
        
    }
    
    
    var offer_id: Int? = nil
    
    
    //load store
    var offerLoader: OfferLoader = OfferLoader()
    
    func load () {
        
        
        self.offerLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "1"
        ]
        
        if let guest = Guest.getInstance() {
            
            parameters["latitude"] = String(guest.lat)
            parameters["longitude"] = String(guest.lng)
            
            
            if let offer_id = self.offer_id{
                parameters["offer_id"] = String(offer_id)
            }
            
        }
        
        Utils.printDebug("\(parameters)")
        
        self.offerLoader.load(url: Constances.Api.API_GET_OFFERS,parameters: parameters)
        
    }
    
    func success(parser: OfferParser,response: String) {
        
        self.viewManager.showMain()
        
        if parser.success == 1 {
            
            let offers = parser.parse()
            
            if offers.count > 0 {
                
                offers[0].save()
                self.setupOfferDetail()
                
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
    
    func calculateEstimatedFrame(content: String,fontSize: Float) -> CGSize {
        
        let size = CGSize(width: 250, height: 1000)
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
