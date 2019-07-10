//
//  SettingViewController.swift
//  NearbyStores
//
//  Created by Amine on 7/18/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import AssistantKit


struct Settings {
    struct Keys {
        static let OFFERS_NOTIFICATION = "offers_notification"
        static let STORES_NOTIFICATION = "stores_notification"
        static let EVENTS_NOTIFICATION = "events_notification"
        static let CEVENTS_NOTIFICATION = "cevents_notification"
        static let MESSENGER_NOTIFICATION = "messenger_notification"
    }
}

class SettingsViewController: UITableViewController {
    
        
    @IBOutlet weak var offersnotificationLabel: UILabel!
    @IBOutlet weak var offernotificationDescription: UILabel!
    
    @IBOutlet weak var eventsnotificationLabel: UILabel!
    @IBOutlet weak var eventsotificationDescription: UILabel!
    
    @IBOutlet weak var storesnotificationLabel: UILabel!
    @IBOutlet weak var storesnotificationDescription: UILabel!
    
    @IBOutlet weak var coeventnotificationLabel: UILabel!
    @IBOutlet weak var coeventnotificationDescription: UILabel!
    
    @IBOutlet weak var messengernotificationLabel: UILabel!
    @IBOutlet weak var messengernotificationDescription: UILabel!
    
    
    @IBOutlet weak var offers_notification_switch: UISwitch!
    @IBOutlet weak var events_notification_switch: UISwitch!
    @IBOutlet weak var stores_notification_switch: UISwitch!
    @IBOutlet weak var cevents_notification_switch: UISwitch!
    @IBOutlet weak var messenger_notification_switch: UISwitch!
    
    
    @IBAction func offers_notification_action(_ sender: Any) {
        let view:UISwitch = sender as! UISwitch
        LocalData.setValue(key: Settings.Keys.OFFERS_NOTIFICATION, value: view.isOn)
    }
    
    
    @IBAction func events_notification_action(_ sender: Any) {
        let view:UISwitch = sender as! UISwitch
        LocalData.setValue(key: Settings.Keys.EVENTS_NOTIFICATION, value: view.isOn)
    }
    
    
    @IBAction func stores_notification_action(_ sender: Any) {
        let view:UISwitch = sender as! UISwitch
        LocalData.setValue(key: Settings.Keys.STORES_NOTIFICATION, value: view.isOn)
    }
    
    
    @IBAction func cevents_notification_action(_ sender: Any) {
        let view:UISwitch = sender as! UISwitch
        LocalData.setValue(key: Settings.Keys.CEVENTS_NOTIFICATION, value: view.isOn)
    }
    
    @IBAction func messenger_notification_action(_ sender: Any) {
        let view:UISwitch = sender as! UISwitch
        LocalData.setValue(key: Settings.Keys.MESSENGER_NOTIFICATION, value: view.isOn)
    }
    
    
    
    @IBOutlet weak var termsanduse: UILabel!
    @IBOutlet weak var privacypolicy: UILabel!
    @IBOutlet weak var appversionValue: UILabel!
    @IBOutlet weak var appversionlabel: UILabel!
    
    
    @IBAction func termsAndUseAction(_ sender: Any) {
        
        
        if let url = URL(string: AppConfig.Api.terms_of_use_url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
        
    }
    
    @IBAction func pravicyPolicyAction(_ sender: Any) {
        
        if let url = URL(string: AppConfig.Api.privacy_policy_url), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        offersnotificationLabel.text = "Offers notification".localized
        offernotificationDescription.text = "Receive a special offer notification".localized
        
        eventsnotificationLabel.text = "Nearby Events Notification".localized
        eventsotificationDescription.text = "Offers notification".localized
        
        storesnotificationLabel.text = "Nearby stores notifications".localized
        storesnotificationDescription.text = "Receive notification when there is a store near you".localized
        
        coeventnotificationLabel.text = "Coming event notification".localized
        coeventnotificationDescription.text = "Receive notification when there is a event coming".localized
        
        messengernotificationLabel.text = "Messenger notifications".localized
        messengernotificationDescription.text = "Receive notification when there is new messages".localized
        
        termsanduse.text = "Terms of use".localized
        privacypolicy.text = "Privacy Policy".localized
        appversionlabel.text = "Application Version".localized
        
        
        if(AppConfig.DEBUG){
            for (key,value) in Localization.list_to_translate{
                print("\"\(key)\" = \"\(value)\";")
            }
        }
        
       
        offers_notification_switch.isOn = LocalData.getValue(key: Settings.Keys.OFFERS_NOTIFICATION, defaultValue: true)!
        events_notification_switch.isOn = LocalData.getValue(key: Settings.Keys.EVENTS_NOTIFICATION, defaultValue: true)!
        stores_notification_switch.isOn = LocalData.getValue(key: Settings.Keys.STORES_NOTIFICATION, defaultValue: true)!
        cevents_notification_switch.isOn = LocalData.getValue(key: Settings.Keys.CEVENTS_NOTIFICATION, defaultValue: true)!
        
        messenger_notification_switch.isOn = LocalData.getValue(key: Settings.Keys.MESSENGER_NOTIFICATION, defaultValue: true)!
        
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as AnyObject
        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        
        self.appversionValue.text = "\(version)"
        
    }

    
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let headerView = view as! UITableViewHeaderFooterView
        
        headerView.textLabel?.textColor = Colors.primaryColor.withAlphaComponent(0.8)
        let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 17.0)
        headerView.textLabel?.font = font!
        
       // headerView.textLabel?.text = headerView.textLabel?.text?.localized
        
    }



    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
