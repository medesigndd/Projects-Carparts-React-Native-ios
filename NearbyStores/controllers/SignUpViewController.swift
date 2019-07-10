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

class SignUpViewController: UIViewController, UserLoaderDelegate,  UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {


    
    
    @IBOutlet weak var constraintScrollBottom: NSLayoutConstraint!
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var full_name_field: SkyFloatingLabelTextField!
    @IBOutlet weak var email_field: SkyFloatingLabelTextField!
    @IBOutlet weak var login_field: SkyFloatingLabelTextField!
    @IBOutlet weak var password_field: SkyFloatingLabelTextField!
    @IBOutlet weak var pick_photo_btn: UIButton!
    @IBOutlet weak var photo_profile: UIImageView!
    
    @IBOutlet weak var signUpBtn: UIButton!
    
    @IBOutlet weak var goBack: UIButton!
    
    @IBAction func goBackAction(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    
    @IBAction func onPickPhotoAction(_ sender: Any) {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        self.present(imagePicker, animated: true)
      
    }
    
    
    @IBAction func signUpAction(_ sender: Any) {
        
        doSignup()
        
    }
    

    
    @objc func onBackHandler()  {
        self.dismiss(animated: true)
    }
    
    
    var imageId: String = ""
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        if Session.isLogged() {
            DispatchQueue.main.asyncAfter(deadline: .now()+1.0) {
//                self.startMainVC()
            }
        }
        
//        self.navigationController?.hidesBarsOnSwipe = true
//
//        self.navigationBar.isTranslucent = true
//        self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
//        self.navigationBar.shadowImage = UIImage()
//        self.navigationBar.backgroundColor = UIColor.clear
//        setupNavBarButtons()

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
        
        
        full_name_field.delegate = self
        email_field.delegate = self
        login_field.delegate = self
        password_field.delegate = self

        pick_photo_btn.setTitle("Pick Photo".localized, for: .normal)
        signUpBtn.setTitle("Pick Photo".localized, for: .normal)
        
        
        self.photo_profile.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.photo_profile.layer.masksToBounds = true
        self.photo_profile.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        self.photo_profile.clipsToBounds = true
        
       
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
    func doSignup () {
        
        
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
        
        
        self.userLoader.load(url: Constances.Api.API_USER_SIGNUP,parameters: [
            "username"  : loginValue,
            "email"     : emailValue,
            "name"      : nameValue,
            "password"  : passwordValue,
            "image"     : imageId,
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
                
                //upload image
                if let image = SignUpViewController.imageProfile{
                   
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
                
                
                DispatchQueue.main.asyncAfter(deadline: .now()+2.0) {
                     SwiftEventBus.post("on_close_it", sender: true)
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
                SignUpViewController.imageProfile = UIImage(data: imageData)
                self.photo_profile.contentMode = .scaleAspectFill
                self.photo_profile.image = SignUpViewController.imageProfile
            }
        }
        
        picker.dismiss(animated: true)
        
    }
    
    
  

}

extension UIImage{
    
    enum JPEGQuality: CGFloat {
        case lowest  = 0
        case low     = 0.25
        case medium  = 0.5
        case high    = 0.75
        case highest = 1
    }
    
    /// Returns the data for the specified image in JPEG format.
    /// If the image object’s underlying image data has been purged, calling this function forces that data to be reloaded into memory.
    /// - returns: A data object containing the JPEG data, or nil if there was a problem generating the data. This function may return nil if the image has no data or if the underlying CGImageRef contains data in an unsupported bitmap format.
    func jpeg(_ quality: JPEGQuality) -> Data? {
        return UIImageJPEGRepresentation(self, quality.rawValue)
    }
    
    public func toBase64() -> String{
        let imageData = UIImageJPEGRepresentation(self, 1.0)
        return (imageData?.base64EncodedString())!
    }
    
    public func scaleTo(ratio: CGFloat) -> UIImage {
        let size = self.size
        let newSize: CGSize = CGSize(width: size.width  * ratio, height: size.height * ratio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    public func isEqualToImage(image: UIImage) -> Bool {
        let data1 = UIImagePNGRepresentation(self)
        let data2 = UIImagePNGRepresentation(image)
        return data1 == data2
    }
}




