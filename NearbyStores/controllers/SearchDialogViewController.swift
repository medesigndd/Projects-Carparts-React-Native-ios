//
//  SearchDialogViewController.swift
//  NearbyStores
//
//  Created by Amine on 6/3/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit


protocol SearchDialogViewControllerDelegate:class  {
    //func successUtf8(data: String)
    func onSearch(search: String, radius: Int, args: String...)
    
}

class SearchDialogViewController: UIViewController, UITextFieldDelegate {

    //varaiables
    var searchType: String?
    var savedFilterInstance: [String: String]? = nil
    
    var delegate: SearchDialogViewControllerDelegate?
    
    @IBOutlet weak var closeBtnView: UIButton!
    
    @IBOutlet var mainView: UIView!
    
    
    @IBOutlet weak var search_field: UITextField!
    
    
    @IBOutlet weak var searchViewBtn: CustomButton!
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var header: UILabel!
    @IBOutlet weak var search_label: UILabel!
    @IBOutlet weak var radius_label: UILabel!
    
    @IBOutlet weak var sliderView: UISlider!
    
    
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    
    
    @IBAction func searchAction(_ sender: Any) {
        
        self.dismiss(animated: true)
        
        if let delegate = self.delegate {
            delegate.onSearch(search: search_field.text!, radius: Int(sliderView.value))
        }
        
    }
    
    @IBAction func radiusSlide(_ sender: Any) {
        
        let slider: UISlider = sender as! UISlider
        let value = Int(slider.value)
        
        if value < 100  {
            radius_label.text = "\("Radius".localized) \(value) \(AppConfig.distanceUnit.localized)"
        }else{
            radius_label.text = "\("Radius".localized) +\(value) \(AppConfig.distanceUnit.localized)"
        }
        
    }
    
    
    @IBAction func closeAction(_ sender: Any) {
        
        
        self.dismiss(animated: true)
   
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.search_field.placeholder = "Write Name, Address, City ...".localized
        
        
        self.searchViewBtn.layer.cornerRadius = 0
        
        view.backgroundColor?.withAlphaComponent(0.1)
        
        self.popupView.layer.cornerRadius = 5/UIScreen.main.nativeScale
        self.popupView.layer.masksToBounds = true
        self.popupView.layer.borderWidth = 5/UIScreen.main.nativeScale
        self.popupView.layer.borderColor = Colors.white.cgColor
        
        
        self.search_label.text = "Search".localized
        self.searchViewBtn.setTitle("_Search".localized, for: .normal)
        
        if let title = searchType {
            self.header.text = "\("Search on".localized) \(title.localized)"
        }
        
        
        self.sliderView.minimumValue = Float(0)
        self.sliderView.maximumValue = Float(AppConfig.distanceMaxValue)
        self.sliderView.value = Float(AppConfig.distanceMaxValue)
        
        self.sliderView.tintColor = Colors.primaryColor
        
        
        if let data = savedFilterInstance, let search = data["search"] {
            self.search_field.text = search
        }
        
        if let data = savedFilterInstance, let radius = data["radius"] {
            self.sliderView.value = Float(radius)!
           
            let value = Int(Float(radius)!)
            
            if value < 100  {
                self.radius_label.text = "\("Radius".localized) \(value) \(AppConfig.distanceUnit.localized)"
            }else{
                self.radius_label.text = "\("Radius".localized) +\(value) \(AppConfig.distanceUnit.localized)"
            }
            
        }
        
        
        let closeIcon = UIImage.init(icon: .googleMaterialDesign(.close), size: CGSize(width: 25, height: 25), textColor: Colors.black)
        
        closeBtnView.setImage(closeIcon, for: .normal)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        
        
        search_field.delegate = self
       
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
    
 

}
