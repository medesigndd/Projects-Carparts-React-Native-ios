//
//  LoaderViewManager.swift
//  NearbyStores
//
//  Created by Amine on 6/4/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit


protocol LoaderViewManagerDelegare {
    func onReload(action: EmptyLayout)
    func onReload(action: ErrorLayout)
}

class LoaderViewManager: UIView {
    
   
    class func instanceFromNib(name: String) -> UIView {
        return UINib(nibName: name, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }

    func getErrorLayout() -> ErrorLayout {
        return errorLayout
    }
    
    func getEmptyLayout() -> EmptyLayout {
        return emptyLayout
    }
    
    func getCustomLayout() -> CustomLayout {
        return customLayout
    }
   
    
    public let customLayout: CustomLayout = {
        
        let layout:CustomLayout = instanceFromNib(name: "CustomVMLayout") as! CustomLayout
        
        layout.backgroundColor = Colors.bg_gray
        
    
        return layout
    }()
    
    private let errorLayout: ErrorLayout = {
        
        let layout:ErrorLayout = instanceFromNib(name: "ErrorLayout") as! ErrorLayout
       
        layout.backgroundColor = Colors.bg_gray
        
        layout.header.text = "Ops!".localized
        layout.messageError.text = "Couldn't load data from server".localized
        layout.reloadBtnView.setTitle("Reload".localized, for: .normal)
        
        
        return layout
    }()
    
    
    private let emptyLayout: EmptyLayout = {
        
        let layout:EmptyLayout = instanceFromNib(name: "EmptyLayout") as! EmptyLayout
        
        layout.backgroundColor = Colors.bg_gray
        
        layout.header.text = "Ops!".localized
        layout.messageError.text = "No Result Found!".localized
        layout.reloadBtnView.setTitle("Reload".localized, for: .normal)
        
        return layout
    }()
    
    
    private let loadingLayout: LoadingLayout = {
        
        let layout:LoadingLayout = instanceFromNib(name: "LoadingLayout") as! LoadingLayout
        
       
        return layout
    }()
    
    
    func setup(parent: UIView) {
        
        self.frame = parent.frame
        self.backgroundColor = Colors.bg_gray
        
        //setup custom layout
        addSubview(customLayout)
        
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: customLayout)
        self.addConstraintsWithFormat(format: "V:|[v0]|", views: customLayout)
        
        
        //setup error layout
        addSubview(errorLayout)
        
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: errorLayout)
        self.addConstraintsWithFormat(format: "V:|[v0]|", views: errorLayout)
        
        
        //setup empty layout
        addSubview(emptyLayout)
        
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: emptyLayout)
        self.addConstraintsWithFormat(format: "V:|[v0]|", views: emptyLayout)
        
        
        //setup empty layout
        addSubview(loadingLayout)
        
        self.addConstraintsWithFormat(format: "H:|[v0]|", views: loadingLayout)
        self.addConstraintsWithFormat(format: "V:|[v0]|", views: loadingLayout)
        
        
        parent.addSubview(self)
        
        parent.addConstraintsWithFormat(format: "H:|[v0]|", views: self)
        parent.addConstraintsWithFormat(format: "V:|[v0]|", views: self)
        
        
        
        //actions
      
        self.parentview = parent
        
        showMain()
        
    }
    
    private var parentview: UIView? = nil
    
    
    
//    func setup(frame: CGRect) {
//
//        self.frame = frame
//        self.backgroundColor = Colors.black
//
//        addSubview(errorLayout)
//
//        self.addConstraintsWithFormat(format: "H:|[v0]|", views: errorLayout)
//        self.addConstraintsWithFormat(format: "V:|[v0]|", views: errorLayout)
//
//    }
    
    
    func showAsLoading() {
        
        self.emptyLayout.isHidden = true
        self.errorLayout.isHidden = true
        self.customLayout.isHidden = true
        self.isHidden = true
        
       // self.loadingLayout.isHidden = true
        
        if let main = parentview {
             MyProgress.show(parent: main)
        }

    }
    
    func showAsLoading(parent: UIView) {
        
        self.emptyLayout.isHidden = true
        self.errorLayout.isHidden = true
        self.customLayout.isHidden = true
        self.isHidden = true
        
        // self.loadingLayout.isHidden = true
        
        MyProgress.show(parent: parent)
        
    }
    
    
    func showAsEmpty() {
        
        self.emptyLayout.isHidden = false
        self.isHidden = false
        
       // self.loadingLayout.isHidden = true
        self.errorLayout.isHidden = true
        self.customLayout.isHidden = true
        
         MyProgress.dismiss()
        
    }
    
    func showAsError() {
       
        self.errorLayout.isHidden = false
        self.isHidden = false
        
        self.backgroundColor = UIColor.green
        
       // self.loadingLayout.isHidden = true
        self.emptyLayout.isHidden = true
        self.customLayout.isHidden = true
        
         MyProgress.dismiss()
        
    }
    
    func showAsCustomLayout() {
        
        self.customLayout.isHidden = false
        self.isHidden = false
        
        // self.loadingLayout.isHidden = true
        self.emptyLayout.isHidden = true
        self.errorLayout.isHidden = true
        
        MyProgress.dismiss()
        
    }
    
    func showMain() {
        
        self.isHidden = true
        
        self.loadingLayout.isHidden = true
        self.emptyLayout.isHidden = true
        self.errorLayout.isHidden = true
        self.customLayout.isHidden = true
        
        if let main = self.parentview{
            main.isHidden = false
        }
        
    
        
         MyProgress.dismiss()
        
    }
    
    

}


class LoadingLayout: UIView {
    
    
}


protocol EmptyLayoutDelegate {
    func onReloadAction(action: EmptyLayout)
}

protocol ErrorLayoutDelegate {
    func onReloadAction(action: ErrorLayout)
}

protocol CustomLayoutDelegate {
    func onReloadAction(action: CustomLayout)
}

class EmptyLayout: UIView {
    
    var delegate: EmptyLayoutDelegate? = nil

    
    @IBAction func reloadAction(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.onReloadAction(action: self)
        }
    }
    @IBOutlet weak var header: UILabel!
    
    @IBOutlet weak var reloadBtnView: CustomButton!
    @IBOutlet weak var messageError: UILabel!
    
}


class ErrorLayout: UIView {
    
    var delegate: ErrorLayoutDelegate? = nil
    
    @IBAction func reloadAction(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.onReloadAction(action: self)
        }
    }

    @IBOutlet weak var header: UILabel!
    
    
    @IBOutlet weak var messageError: UILabel!
    
    @IBOutlet weak var reloadBtnView: CustomButton!
    

}

class CustomLayout: UIView {
    
    var delegate: CustomLayoutDelegate? = nil
    
    
    @IBAction func reloadAction(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.onReloadAction(action: self)
        }
    }
  
    @IBOutlet weak var customBtn: CustomButton!
    @IBOutlet weak var customText: UILabel!
    
}



