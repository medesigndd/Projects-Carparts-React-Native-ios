//
//  SignUpViewController.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import SVProgressHUD
import SwiftEventBus
import SwiftIcons
import SkyFloatingLabelTextField
import Kingfisher

class EditProfileViewController: UIViewController, UserLoaderDelegate,  UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var saveBtn: CustomButton!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var navigationBarItem: UINavigationItem!
    
    
    @IBOutlet weak var constraintScrollBottom: NSLayoutConstraint!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var full_name_field: SkyFloatingLabelTextField!
    @IBOutlet weak var email_field: SkyFloatingLabelTextField!
    @IBOutlet weak var login_field: SkyFloatingLabelTextField!
    @IBOutlet weak var password_field: SkyFloatingLabelTextField!
    @IBOutlet weak var pick_photo_btn: UIButton!
    @IBOutlet weak var photo_profile: UIImageView!
    
    @IBAction func onPickPhotoAction(_ sender: Any) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
        
    }
    
    
    @IBAction func saveChangesAction(_ sender: Any) {
        
        doSaveChanges()
        
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
        
        
        
        topBarTitle.text = "Edit Profile".localized
        
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
        
        
        navigationBarItem.leftBarButtonItems = []
        navigationBarItem.rightBarButtonItems = []
        navigationBarItem.leftBarButtonItems?.append(customBarButtonItem)
        
    }
    
    @objc func onBackHandler()  {
        self.dismiss(animated: true)
    }
    
    
    var imageId: String = ""
    
    let imagePicker = UIImagePickerController()
    
    var myUserSession: User? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let session = Session.getInstance(), let user = session.user{
            myUserSession = user
        }else{
            dismiss(animated: true)
        }
        
        
        imagePicker.delegate = self
        
        if Session.isLogged() {
            
        }
        
        self.navigationBar.isTranslucent = false
        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationBar.shadowImage = UIImage()
        
        setupNavBarTitles()
        setupNavBarButtons()
        
        setupView()
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect
            let isKeyboardShowing = notification.name == NSNotification.Name.UIKeyboardWillShow
            
            
            if let textField = self.lastTextField, let _ = textField.superview?.convert(textField.frame, to: nil) {
                
                if isKeyboardShowing{
                    // so increase contentView's height by keyboard height
                    self.constraintScrollBottom.constant = keyboardFrame.height
                    UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                }else{
                    // so increase contentView's height by keyboard height
                    self.constraintScrollBottom.constant = 0
                    UIView.animate(withDuration: 0, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                        self.view.layoutIfNeeded()
                    })
                    
                }
                
                
                
            }
            
            
            
        }
        
        
    }
    
    
    
    @IBAction func haveAccountBtn(_ sender: Any) {
        
        dismiss(animated: true, completion: nil)
    }
    
    
    func setupView ()  {
        
        full_name_field.textColor = UIColor.black
        full_name_field.lineColor = UIColor.gray
        full_name_field.selectedTitleColor = UIColor.black
        full_name_field.selectedLineColor = Colors.primaryColor
        full_name_field.selectedLineHeight = 1.5
        full_name_field.lineHeight = 0.5
        full_name_field.titleColor = Colors.primaryColor
        
        
        email_field.textColor = UIColor.black
        email_field.lineColor = UIColor.gray
        email_field.selectedTitleColor = UIColor.black
        email_field.selectedLineColor = Colors.primaryColor
        email_field.selectedLineHeight = 1.5
        email_field.lineHeight = 0.5
        email_field.titleColor = Colors.primaryColor
        
        
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
        
        
        full_name_field.placeholder = "Enter full name".localized
        email_field.placeholder = "Enter email address".localized
        login_field.placeholder = "Enter login".localized
        password_field.placeholder = "Enter password".localized
        
        saveBtn.setTitle("Save Changes".localized, for: .normal)
        
        
        full_name_field.delegate = self
        email_field.delegate = self
        login_field.delegate = self
        password_field.delegate = self
        
        pick_photo_btn.setTitle("Pick Photo".localized, for: .normal)
        
        self.photo_profile.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.photo_profile.layer.masksToBounds = true
        self.photo_profile.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        self.photo_profile.clipsToBounds = true
        
        
        //put data inside views
        
        if let user = myUserSession {
            
            full_name_field.text = user.name
            login_field.text = user.username
            email_field.text = user.email
            
            //set image
            if let cached_image = EditProfileViewController.imageProfile{
                
                self.photo_profile.image = cached_image
                
            }else if let cached_image = SignUpViewController.imageProfile{
                
                self.photo_profile.image = cached_image
                
            }else{
                
                if let image = user.images {
                    
                    let url = URL(string: image.url100_100)
                    
                    self.photo_profile.kf.indicatorType = .activity
                    self.photo_profile.kf.setImage(with: url,options: [.transition(.fade(0.2))])
                    
                }else{
                    if let img = UIImage(named: "profile_placeholder") {
                        self.photo_profile.image = img
                    }
                }
                
            }
            
            
        }
       
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
    
    
    
    var userLoader: UserLoader = UserLoader()
    func doSaveChanges () {
        
        
        guard let user = myUserSession else { return }
        
        
        MyProgress.show()
        
        
        self.userLoader.delegate = self
        
        
        guard let loginValue = login_field.text else {
            showErros(messages:["login":"Login field is empty".localized])
            return
        }
        
        guard let passwordValue = password_field.text else {
            showErros(messages:["password":"Password field is empty".localized])
            return
        }
        
        guard let emailValue = email_field.text else {
            showErros(messages:["email":"Email field is empty".localized])
            return
        }
        
        guard let nameValue = full_name_field.text else {
            showErros(messages:["name":"Full Name field is empty".localized])
            return
        }
        
        var lat = 0.0
        var lng = 0.0
        var guest_id = 0
        
        if let guest = Guest.getInstance() {
            
            guest_id = guest.id
            lat = guest.lat
            lng = guest.lng
            
        }
        
        
        self.userLoader.load(url: Constances.Api.API_UPDATE_ACCOUNT,parameters: [
            "username"      : loginValue,
            "oldUsername"   : user.username,
            
            "user_id"       : String(user.id),
            
            "email"         : emailValue,
            "name"          : nameValue,
            "password"      : passwordValue,
            "image"         : imageId,
            "lat"           : String(lat),
            "lng"           : String(lng),
            "guest_id"      : String(guest_id)
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
                
                //upload image
                if let image = EditProfileViewController.imageProfile{
                    
                    let parameters = [
                        "image":    image.toBase64(),
                        "int_id":   String(users[0].id),
                        "type":     "user",
                        ]
                    
                    let api = SimpleLoader()
                    api.run(url: Constances.Api.API_USER_UPLOAD64, parameters: parameters) { (parser) in
                        if parser?.success == 1{
                            
                        }
                    }
                    
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
                    
                    if MainViewController.mInstance != nil {
                        self.dismiss(animated: true)
                    }else{
                        self.startMainVC()
                    }
                    
                }
                
            }else{
                showErros(messages: ["err": "User not found!".localized])
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
        //
        
    }
    
    
    func showErros(messages: [String: String]) {
        
        self.showAlertError(title: "Error",content: messages,msgBnt: "OK")
        
    }
    
    
    func startMainVC() {
        
        let sb = UIStoryboard(name: "Main", bundle: nil)
        if let vc = sb.instantiateInitialViewController() {
            self.present(vc, animated: true)
        }
        
    }
    
    static var imageProfile:UIImage? = nil
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            if let imageData = pickedImage.jpeg(.lowest) {
                EditProfileViewController.imageProfile = UIImage(data: imageData)
                self.photo_profile.contentMode = .scaleAspectFill
                self.photo_profile.image = EditProfileViewController.imageProfile
            }
        }
        
        picker.dismiss(animated: true)
        
    }
    
    
    
    
}





