//
//  OfferAndReviewsView.swift
//  NearbyStores
//
//  Created by Amine on 7/4/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class OfferAndReviewsView: UIView, OfferLoaderDelegate, ReviewLoaderDelegate, StoreOfferDelegate,StoreReviewDelegate{
    
    var viewController: StoreDetailViewController? = nil

    var store_id: Int? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var parentConstraint: NSLayoutConstraint? = nil
    
    func setPosition(parent: UIView) {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints = [NSLayoutConstraint]()
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.right,
            relatedBy: NSLayoutRelation.equal,
            toItem: parent,
            attribute: NSLayoutAttribute.right,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.top,
            relatedBy: NSLayoutRelation.equal,
            toItem: parent,
            attribute: NSLayoutAttribute.top,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.bottom,
            relatedBy: NSLayoutRelation.equal,
            toItem: parent,
            attribute: NSLayoutAttribute.bottom,
            multiplier: 1, constant: 0)
        )
        
        constraints.append(NSLayoutConstraint(
            item: self,
            attribute: NSLayoutAttribute.left,
            relatedBy: NSLayoutRelation.equal,
            toItem: parent,
            attribute: NSLayoutAttribute.left,
            multiplier: 1, constant: 0)
        )
        
        
       parent.addConstraints(constraints)
        parent.layoutIfNeeded()
        
    
        self.addSubview(offersView)
        offersView.setPosition(parent: self)
        offersView.layoutIfNeeded()
        
        
        self.addSubview(reviewsView)
        reviewsView.setPosition(parent: self)
        reviewsView.layoutIfNeeded()
       
        
        offersView.delegate = self
        reviewsView.delegate = self
       
        
    }
    
    
    
    
    let offersView = {
        return StoreOfferListView()
    }()
    
    let reviewsView = {
        return StoreReviewListView()
    }()
    
    
    func loadOffers(store_id: Int) {
        
        //get from realm
        
        
        //get from server
        let params = [
            "store_id": String(store_id),
            "limit": "10"
        ]
        
        let loader = OfferLoader()
        loader.load(url: Constances.Api.API_GET_OFFERS, parameters: params)
        loader.delegate = self
        
       
    }
    
    
    func success(parser: OfferParser, response: String) {
        
        if parser.success==1{
            let offers = parser.parse()
            if offers.count>0{
                
                
                let size = offers.count-1
                for index in 0...size{
                    offersView.addItem(object: offers[index]) { (object) in
                        
                    }
                    if index == 5 && size>=6{
                        offersView.addItemLoadMore()
                        break
                    }
                }
                
            }
        }
        
        
        //update height of container
        
        if offersView.isHidden == false{
            if let constraint = self.parentConstraint{
                let calculatedHeight = offersView.calculatedHeight
                constraint.constant = calculatedHeight+50+10
                self.layoutIfNeeded()
                offersView.isHidden = false
                reviewsView.isHidden = true
            }
        }
        
        
        
    }
    
    func loadMore(view: StoreOfferListView) {
        //start viewcontroller for Offers
        if let vc = self.viewController, let store = store_id{
            vc.startOffersLsit(store_id: store)
        }
    
    }
    
    func onPress(object: Offer) {
        //start viewcontroller for offer detail
        if let store = StoreDetailViewController.mInstance{
            store.startOfferDetailVC(offerId: object.id)
        }
    }
    
   
    
    func loadReviews(store_id: Int) {
        
        //get from server
        let params = [
            "store_id": String(store_id),
            "limit": "10"
        ]
        
        let loader = ReviewLoader()
        loader.load(url: Constances.Api.API_USER_GET_REVIEWS, parameters: params)
        loader.delegate = self
        
    
    }
    
    
    func success(parser: ReviewParser, response: String) {
        
        if parser.success==1{
            
            let reviews = parser.parse()
            if reviews.count>0{
                
                let size = reviews.count-1
                for index in 0...size{
                    reviewsView.addItem(object: reviews[index]) { (object) in
                        
                    }
                    if index == 6 && size>=7{
                        reviewsView.addItemLoadMore {
                            
                        }
                        break
                    }
                }
               
            }
        }
        
        
        if reviewsView.isHidden == false{
            if let constraint = self.parentConstraint{
                let calculatedHeight = offersView.calculatedHeight
                constraint.constant = calculatedHeight+50+10
                self.layoutIfNeeded()
                offersView.isHidden = true
                reviewsView.isHidden = false
            }
        }
        
        
    }
    
    
    func loadMore(view: StoreReviewListView) {
       
        if let vc = self.viewController, let store = store_id{
            vc.startReviewsLsit(store_id: store)
        }
    }
    
    func onPress(object: Review) {
        
    }
    

    
    func error(error: Error?, response: String) {
    
    }
    
   
    
    
}
