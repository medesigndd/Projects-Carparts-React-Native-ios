//
//  LoginViewController.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SwiftEventBus
import SkyFloatingLabelTextField

class LoginViewController: UIViewController,UserLoaderDelegate, UITextFieldDelegate {
   

    
    @IBOutlet weak var constraintScrollBottomHeight: NSLayoutConstraint!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var forgotpassword: UIButton!
    @IBOutlet weak var login_field: SkyFloatingLabelTextField!
    @IBOutlet weak var password_field: SkyFloatingLabelTextField!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var signin: CustomButton!
    
    @IBOutlet weak var goBack: UIButton!
    
    @IBAction func goBack(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBOutlet weak var signup: UIButton!
    @IBAction func signInAction(_ sender: Any) {
    
        dologin()
    
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        
        
        if let url = URL(string: AppConfig.Api.base_url+"/fpassword"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        
        
    }
    @IBAction func signUpAction(_ sender: Any) {
        startSignUpView()
    }
    

    
    @objc func onBackHandler()  {
        self.dismiss(animated: true)
    }
    
    func startSignUpView()  {
        
        
        let sb = UIStoryboard(name: "Signup", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "signupVC")
        self.present(vc, animated: true, completion: nil)
        
    }
    
   

    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        
        if Session.isLogged() {
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                self.dismiss(animated: true)
            }
        }

        setupViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        SwiftEventBus.onMainThread(self, name: "on_close_it") { result in
            
            if let _ = result?.object{
                
                if let mySession = Session.getInstance(), let user = mySession.user{
                    SwiftEventBus.post("on_main_refresh", sender: user)
                    self.dismiss(animated: true)
                }
            }
            
        }
        
       
      
    }
    
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            
            if let textField = self.lastTextField, let _ = textField.superview?.convert(textField.frame, to: nil) {
                
                if isKeyboardShowing{
                    // so increase contentView's height by keyboard height
                    self.constraintScrollBottomHeight.constant = keyboardFrame.height
                    UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                }else{
                    // so increase contentView's height by keyboard height
                    self.constraintScrollBottomHeight.constant = 0
                    UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                }
                
            }
        
        }
    
    }
    
    
    var lastTextField: UITextField? = nil
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        lastTextField = textField
    }
    

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        lastTextField = textField
        return true
    }
    
    func startMainVC() {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.present(vc, animated: true)
        }
        
    }
    
    
    func keyboardDismiss() {
        self.view.endEditing(true)
    }
    
   
    func setupViews() {
        
        let yourAttributes : [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),
            NSAttributedStringKey.foregroundColor : Colors.primaryColor,
            NSAttributedStringKey.underlineStyle : NSUnderlineStyle.styleSingle.rawValue]

        let attributeString = NSMutableAttributedString(string: "Forgot password?".localized,
                                                        attributes: yourAttributes)
        forgotpassword.setAttributedTitle(attributeString, for: .normal)
        
        login_field.delegate = self
        password_field.delegate = self
        
        
        login_field.textColor = UIColor.black
        login_field.lineColor = UIColor.gray
        login_field.selectedTitleColor = UIColor.black
        login_field.selectedLineColor = Colors.primaryColor
        login_field.selectedLineHeight = 1.5
        login_field.lineHeight = 0.5
        login_field.titleColor = Colors.primaryColor
        
        
        password_field.textColor = UIColor.black
        password_field.lineColor = UIColor.gray
        password_field.selectedTitleColor = UIColor.black
        password_field.selectedLineColor = Colors.primaryColor
        password_field.selectedLineHeight = 1.5
        password_field.lineHeight = 0.5
        password_field.titleColor = Colors.primaryColor
        
        login_field.placeholder = "Enter login".localized
        password_field.placeholder = "Enter password".localized
        orLabel.text = "OR".localized
        signin.setTitle("Sign In".localized, for: .normal)
        signup.setTitle("Don't have account?".localized, for: .normal)
        
        
        login_field.delegate = self
        password_field.delegate = self
        
        
     

    }

    

    var userLoader: UserLoader = UserLoader()
    func dologin () {
        
        
        MyProgress.show()
        
    
        self.userLoader.delegate = self
        
        
        guard let loginValue = login_field.text else {
            showErros(messages:["login":"Login field is empty"])
            return
        }
    
        guard let passwordValue = password_field.text else {
            showErros(messages:["password":"Password field is empty"])
            return
        }
        
        
        //Get current Location
        var lat = 0.0
        var lng = 0.0
        var guest_id = 0
        
        if let guest = Guest.getInstance() {
            lat = guest.lat
            lng = guest.lng
            guest_id = guest.id
        }
        
        self.userLoader.load(url: Constances.Api.API_USER_LOGIN,parameters: [
            "login"     : loginValue,
            "password"  : passwordValue,
            "lat"       : String(lat),
            "lng"       : String(lng),
            "guest_id"  : String(guest_id)
        ])
        
        
    }
    
    
    func success(parser: UserParser,response: String) {
        
        if parser.success == 1 {
            
        
            MyProgress.showProgressWithSuccess(withStatus: "Success!")
            
            let users = parser.parse()
            
            if users.count == 1 {
                
                Utils.printDebug("\(users)")
                
                Session.createSession(user: users[0])
                
                SwiftEventBus.post("on_main_refresh", sender: users[0])
                
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    
                    if MainViewController.mInstance != nil {
                        self.dismiss(animated: true)
                    }else{
                        self.startMainVC()
                    }
                    
                }
                
            }else{
                showErros(messages: ["err": "User not found!"])
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                //start main activity
                
            }
            
            
            
        }else {
            
        
            
            if let errors = parser.errors {
                
                MyProgress.dismiss()
                self.showAlertError(title: "Error",content: errors ,msgBnt: "OK")
            }
            
        }
        
    }
    
    func error(error: Error?,response: String) {
    
        MyProgress.dismiss()
        
        let errors: [String: String] = [
            "err": "Technical error"
        ]
        
       
        self.showAlertError(title: "Error",content: errors,msgBnt: "OK")
        
        
    }
    
    
    func showErros(messages: [String: String]) {
        
         self.showAlertError(title: "Error",content: messages,msgBnt: "OK")
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
  


}




