//
//  GeoStoreViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/30/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import GoogleMaps
import Cosmos

class GeoStoreViewController: MyUIViewController,GMSMapViewDelegate, EmptyLayoutDelegate,ErrorLayoutDelegate,StoreLoaderDelegate {
   
    var latitude: Double? = nil
    var longitude: Double? = nil
    var name: String? = nil
    
    var _req_limit = 30
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    @IBOutlet weak var viewContainer: UIView!
    
    
    //store geo map header
    @IBOutlet weak var storeContainer: UIView!
    @IBOutlet weak var storeClose: UIButton!
    @IBOutlet weak var storeRating: UIView!
    @IBOutlet weak var storeName: UILabel!
    //end
    @IBAction func zoomPlus(_ sender: Any) {
        
        if let mapView = self.mapView  {
            
            mapView.animate(toZoom: mapView.camera.zoom+1)
            
        }
        
    }
    
    @IBAction func zoomLess(_ sender: Any) {
        
        if let mapView = self.mapView  {
            
            mapView.animate(toZoom: mapView.camera.zoom-1)
 
        }
    }
    
    @IBAction func onClose(_ sender: Any) {
        self.storeHeader(hidden: true)
    }
    
    
    var viewManager: LoaderViewManager =  LoaderViewManager()
    
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
        
        if let name = self.name, let _ = self.latitude {
             topBarTitle.text = name
        }else{
             topBarTitle.text = "Geo Store".localized
        }
       
        navigationBarItem.titleView = topBarTitle
        
    }
    
    
    func setupNavBarButtons() {
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        
        //arrow back icon
        var arrowImage: UIImage? = nil
        if Utils.isRTL(){
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowForward), size: CGSize(width: 30, height: 30), textColor: Colors.darkColor)
        }else{
            arrowImage = UIImage.init(icon: .ionicons(.iosArrowBack), size: CGSize(width: 30, height: 30), textColor: Colors.darkColor)
        }
        
        
        let customBarButtonItem = UIBarButtonItem(image: arrowImage!, style: .plain, target: self, action: #selector(onBackHandler))
        customBarButtonItem.setIcon(icon: .ionicons(.iosArrowBack), iconSize: 25, color: Colors.white)
        
        
        if self.latitude == nil && self.longitude == nil{
            
            let refreshImage = UIImage.init(icon: .ionicons(.androidRefresh), size: CGSize(width: 30, height: 30), textColor: Colors.darkColor)
            let refreshCustomBarButtonItem = UIBarButtonItem(image: refreshImage, style: .plain, target: self, action: #selector(onRefreshHandle))
            refreshCustomBarButtonItem.setIcon(icon: .ionicons(.iosRefresh), iconSize: 25, color: Colors.white)
            
            navigationBarItem.rightBarButtonItems?.append(refreshCustomBarButtonItem)
            
        }
        
        

        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
  
    }
    
    @objc func onBackHandler()  {
        self.dismiss(animated: true)
    }
    
    @objc func onRefreshHandle() {
        load()
    }
    
    func setupGeoHeader()  {
        self.storeContainer.isHidden = true
        self.storeRating.addSubview(ratingView)
        self.storeClose.setIcon(icon: .ionicons(.androidClose), iconSize: 24, color: Colors.gray, forState: .normal)
    }
    
    var mapView: GMSMapView? = nil
    
    var lastObject: Store? = nil
    @objc func onTapStoreHeader()  {
        if let object = lastObject{
           
            //show detail of store
            let sb = UIStoryboard(name: "StoreDetail", bundle: nil)
            if sb.instantiateInitialViewController() != nil {
                
                let ms: StoreDetailViewController = sb.instantiateViewController(withIdentifier: "storedetailVC") as! StoreDetailViewController
                ms.storeId = object.id
                
                self.present(ms, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        
        
        self.setupNavBarTitles()
        self.setupNavBarButtons()
        self.setupViewloader()
        self.setupGeoHeader()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTapStoreHeader))
        self.storeContainer.addGestureRecognizer(tap)
        
      
        if let lat = self.latitude, let lng = self.longitude{
            
            
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: 6.0)
            self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), camera: camera)
            
            mapView?.delegate = self
            
            if let mapView = self.mapView  {
                
                mapView.animate(toZoom: 17)
                viewContainer.addSubview(mapView)
                
                // Creates a marker in the center of the map.
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude:  lat, longitude: lng)
                marker.map = mapView
                
            }
            
        }else{
            
            if let guest = Guest.getInstance() {
                
                let camera = GMSCameraPosition.camera(withLatitude: guest.lat, longitude: guest.lng, zoom: 6.0)
                self.mapView = GMSMapView.map(withFrame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height), camera: camera)
                
                mapView?.delegate = self
                
                if let mapView = self.mapView  {
                    
                    mapView.animate(toZoom: 16)
                    viewContainer.addSubview(mapView)
                    
                    // Creates a marker in the center of the map.
                    let marker = GMSMarker()
                    marker.position = CLLocationCoordinate2D(latitude:  guest.lat, longitude: guest.lng)
                    marker.map = mapView
                    
                    
                }
                
                
                
                self.load()
                
            }else{
                
            }
            
        }
        
        
        
    }
    
    
    
    
    func storeHeader(hidden: Bool) {
        
        if hidden {
            let animation = UIAnimation(view: self.storeContainer)
            animation.zoomOut()
        }else{
            let animation = UIAnimation(view: self.storeContainer)
            animation.zoomIn()
        }
       
    }
    
    func onReloadAction(action: ErrorLayout) {
        
    }
    
    func onReloadAction(action: EmptyLayout) {
        
    }

    
    let ratingView: CosmosView = {
        
        
        
        let cosmosView = CosmosView()
        
        cosmosView.rating = 0
        
        // Change the text
        cosmosView.text = " 0 (0)"
        cosmosView.settings.textColor = Colors.black
        cosmosView.settings.updateOnTouch = false
        
        if let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 12) {
            cosmosView.settings.textFont = font
        }
        
        
        // Called when user finishes changing the rating by lifting the finger from the view.
        // This may be a good place to save the rating in the database or send to the server.
        cosmosView.didFinishTouchingCosmos = { rating in }
        
        // A closure that is called when user changes the rating by touching the view.
        // This can be used to update UI as the rating is being changed by moving a finger.
        cosmosView.didTouchCosmos = { rating in }
        
        
        return cosmosView
    }()
    
    
    
    ///API
    
    //API
    
    var storeLoader: StoreLoader = StoreLoader()
    var LIST: [Store] = [Store]()
    
    
    var lat = 0.0
    var lng = 0.0
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        lat = position.target.latitude
        lng = position.target.longitude
    }
    
    
    
    func load () {
        
        MyProgress.show()
        
        
        self.storeLoader.delegate = self
        
        //Get current Location
        
        var parameters = [
            "limit"          : "\(self._req_limit)"
        ]
        
        if let guest = Guest.getInstance() {
            
            if self.LIST.count>0{
                parameters["latitude"] = String(lat)
                parameters["longitude"] = String(lng)
                
            }else{
                parameters["latitude"] = String(guest.lat)
                parameters["longitude"] = String(guest.lng)
                
            }
            
            parameters["order_by"] = String(0)
            
//            if let session = Session.getInstance(), let user = session.user {
//               // parameters["user_id"] = String(user.id)
//            }
            
            
        }
        
        Utils.printDebug("\(parameters)")
        
    
        self.storeLoader.load(url: Constances.Api.API_USER_GET_STORES,parameters: parameters)
        
        
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        
        
        let view: CustomViewStoreMarker = marker.iconView as! CustomViewStoreMarker
        if let object = view.object {
            
            object.save()
            
            self.lastObject = object
            storeName.text = object.name
            
           
            self.ratingView.text = "\(object.votes) (\(object.nbr_votes)) "
            self.ratingView.rating = object.votes
            
            self.storeHeader(hidden: false)
            
            let camera = GMSCameraPosition.camera(withLatitude: object.latitude, longitude: object.longitude, zoom: 16)
           // self.mapView?.camera = camera
            self.mapView?.animate(to: camera)
        }
       
        return true
    }
    
    
    func success(parser: StoreParser,response: String) {
        
        
       MyProgress.dismiss()
      
        if parser.success == 1 {
            
            
            let stores = parser.parse()
            
          
            if stores.count > 0 {
                
                Utils.printDebug("We loaded \(stores.count)")
            
                 self.LIST = stores
                
                if stores.count > 0 {
                    mapView?.clear()
                    
                    if let guest = Guest.getInstance(), let mapView = self.mapView {
                        // Creates a marker in the center of the map.
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude:  guest.lat, longitude: guest.lng)
                        marker.map = mapView
                    }
                }
                
                if let mapView = self.mapView {
                
                    for store in self.LIST{
                        
                        let marker = GMSMarker()
                        marker.position = CLLocationCoordinate2D(latitude:  store.latitude, longitude: store.longitude)
                        marker.map = mapView
                        
                       
                        let icon = CustomViewStoreMarker()
                        icon.object = store
                        icon.setup(marker: marker)

                        marker.iconView = icon
                        
                    }
                    
                }
                
                
                
            }else{
                
                if self.LIST.count == 0 {
                    
                    viewManager.showAsEmpty()
                    
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
    
    func error(error: Error?, response: String) {
        MyProgress.dismiss()
        viewManager.showAsError()
    }
    
 
}
