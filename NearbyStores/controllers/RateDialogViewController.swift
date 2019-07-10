//
//  SearchDialogViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/3/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Cosmos


protocol RateDialogViewControllerDelegate:class  {
    //func successUtf8(data: String)
    func onRate(rating: Double, review: String)
    
}

class RateDialogViewController: UIViewController, UITextFieldDelegate {
    

    var store_id: Int? = nil
    var delegate: RateDialogViewControllerDelegate?
    
    @IBOutlet weak var closeBtnView: UIButton!
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var pseudo_field: TextField!
    @IBOutlet weak var review_field: TextField!
    
    
    @IBOutlet weak var rateNowBtn: CustomButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    @IBAction func rateAction(_ sender: Any) {
        
      
        
        guard let text = review_field.text else {
            let message: [String: String] = ["err": "Write review".localized]
            self.showErros(messages: message)
            return
        }
        
        guard ratingView.rating > 0  else {
            let message: [String: String] = ["err": "Select rating".localized]
            self.showErros(messages: message)
            return
        }
        
        if ratingView.rating > 0 && text != "" {
            
            sendToServer(review: text, rating: ratingView.rating)
            
        }else{
            let message: [String: String] = ["err": "Write review".localized]
            self.showErros(messages: message)
        }
        
       
        
    }
    
   

    @IBAction func closeAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    override func viewDidLoad() {
    
        
        self.header.text = "Add Review".localized
        self.rateNowBtn.setTitle("Rate Now".localized, for: .normal)
        self.pseudo_field.placeholder = "Pseudo".localized
        self.review_field.placeholder = "Write Review...".localized
        
      
        self.rateNowBtn.layer.cornerRadius = 0
        
        view.backgroundColor?.withAlphaComponent(0.1)
        
        self.popupView.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.popupView.layer.masksToBounds = true
        self.popupView.layer.borderWidth = 5/UIScreen.main.nativeScale
        self.popupView.layer.borderColor = Colors.white.cgColor
        
        
        
        let closeIcon = UIImage.init(icon: .googleMaterialDesign(.close), size: CGSize(width: 25, height: 25), textColor: Colors.black)
        
        closeBtnView.setImage(closeIcon, for: .normal)
    
        
        setupFields()
        setupRatingView()
        
        
        
        if Session.isLogged(){
            if let user = Session.getInstance()?.user {
                pseudo_field.text = user.username
                pseudo_field.isEnabled = false
                pseudo_field.backgroundColor = Colors.highlightedGray.withAlphaComponent(0.3)
            }
        }
        

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)

    
        pseudo_field.delegate = self
        review_field.delegate = self
        
        
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
        
        if isKeyboardShowing{
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintContentHeight.constant = -100
                self.view.layoutIfNeeded()
            })
            
        }else{
            // so increase contentView's height by keyboard height
            UIView.animate(withDuration: 0.3, animations: {
                self.constraintContentHeight.constant = 0
                self.view.layoutIfNeeded()
            })
            
        }
        
        
        
    }
    
    
    func setupFields() {
        
        self.pseudo_field.setLeftPaddingPoints(5)
        self.pseudo_field.setRightPaddingPoints(5)
        
        self.pseudo_field.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.pseudo_field.layer.masksToBounds = true
        self.pseudo_field.layer.borderWidth = 1/UIScreen.main.nativeScale
        self.pseudo_field.layer.borderColor = Colors.gray.withAlphaComponent(0.6).cgColor

        self.review_field.setLeftPaddingPoints(5)
        self.review_field.setRightPaddingPoints(5)
        
        self.review_field.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.review_field.layer.masksToBounds = true
        self.review_field.layer.borderWidth = 1/UIScreen.main.nativeScale
        self.review_field.layer.borderColor = Colors.gray.withAlphaComponent(0.6).cgColor

    }
    
    func setupRatingView() {
        
        //setup
        ratingView.rating = 0
        
        // Change the text
        ratingView.text = ""
        ratingView.settings.textColor = Colors.black
        
        ratingView.settings.updateOnTouch = true
        
        ratingView.settings.starSize = 30
        
        if let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17) {
            ratingView.settings.textFont = font
        }
        
        
        // Called when user finishes changing the rating by lifting the finger from the view.
        // This may be a good place to save the rating in the database or send to the server.
        ratingView.didFinishTouchingCosmos = { rating in }
        
        // A closure that is called when user changes the rating by touching the view.
        // This can be used to update UI as the rating is being changed by moving a finger.
        ratingView.didTouchCosmos = { rating in
            
        }
    }
    
    var nbrPress = 0
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
        
        let touch: UITouch? = touches.first
        if touch?.view == popupView {
            
        }else if touch?.view == mainView {
            nbrPress += 1
            if nbrPress > 1{
                self.dismiss(animated: true)
            }
            
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        textField.resignFirstResponder()
        return true
    }
    
   
    
    func showErros(messages: [String: String]) {
        
        self.showAlertError(title: "Error",content: messages,msgBnt: "OK")
        
    }
    
    func showAlert(messages: [String: String]) {
        
        self.showAlertError(title: "Error",content: messages,msgBnt: "OK")
        
    }
    
    
    
    class TextField: UITextField {
        
        let padding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5);
        
        override open func textRect(forBounds bounds: CGRect) -> CGRect {
            return UIEdgeInsetsInsetRect(bounds, padding)
        }
        
        override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
            return UIEdgeInsetsInsetRect(bounds, padding)
        }
        
        override open func editingRect(forBounds bounds: CGRect) -> CGRect {
            return UIEdgeInsetsInsetRect(bounds, padding)
        }
    }
    
   
    
    func sendToServer(review: String, rating: Double) {
        
        self.rateNowBtn.backgroundColor = UIColor.gray
        
        if let guest = Guest.getInstance(){
            
            var params = [
                "limit": "7"
            ]
            
            if let store = store_id{
                
                params["store_id"] = String(store)
                params["rate"] = String(rating)
                params["review"] = review
                params["pseudo"] = ""
                params["guest_id"] = String(guest.id)
                
                if Session.isLogged(){
                    if let user = Session.getInstance()?.user {
                         params["pseudo"] = user.username
                    }
                }else{
                    
                    if let pesudo = self.pseudo_field.text{
                        
                        if pesudo != ""{
                            params["pseudo"] = pesudo
                        }else{
                             params["pseudo"] = "Guest".localized+"-\(guest.id)"
                        }
                        
                    }else{
                         params["pseudo"] = "Guest".localized+"-\(guest.id)"
                    }
                   
                }
                
                
                 params["token"] = Token.getDeviceId()
                
                Utils.printDebug("\(params)")
                let api = SimpleLoader()
                api.run(url: Constances.Api.API_RATING_STORE, parameters: params) { (parser) in
                   
                    
                    self.dismiss(animated: true)
                    if let delegate = self.delegate{
                        delegate.onRate(rating: rating, review: review)
                    }
                    
                }
            }
           
            
        }
        
    }
    
    
}


extension UITextField {
    func setLeftPaddingPoints(_ size:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ size:CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}
