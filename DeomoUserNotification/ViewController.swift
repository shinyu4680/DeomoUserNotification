//
//  ViewController.swift
//  DeomoUserNotification
//
//  Created by kevin on 2018/6/29.
//  Copyright © 2018 KevinChang. All rights reserved.
//

import UIKit
import UserNotifications



class ViewController: UIViewController {

    @IBOutlet weak var notificationTitileTextField: UITextField!
    @IBOutlet weak var notificationBodyTextField: UITextField!
    @IBOutlet weak var triggerTimePicker: UIDatePicker!
    
    
    let app = UIApplication.shared.delegate as! AppDelegate
    var center: UNUserNotificationCenter?
    
    let snoozeAction = UNNotificationAction(identifier: "SnoozeAction",
                                            title: "Snooze", options: [.authenticationRequired])
    let deleteAction = UNNotificationAction(identifier: "DeleteAction",
                                            title: "Delete", options: [.destructive])
    
    
    @IBAction func sendNotificationBtnPressed(_ sender: UIButton) {
        center?.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized {
                self.sendNotification()
            }else if settings.authorizationStatus == .denied {
                self.deniedAlert()
            }else { return }
        }
    }
    
    func sendNotification() {
        // Main thread checker
        DispatchQueue.main.async {
            let titleText = self.notificationTitileTextField.text
            let bodyText = self.notificationBodyTextField.text
            
            if titleText != nil && bodyText != nil {
                let customID = titleText!
                let identifier = "DemoNotifiaction" + customID
                let content = UNMutableNotificationContent()
                content.title = titleText!
                content.body = bodyText!
                content.sound = UNNotificationSound.default()
                content.badge = NSNumber(integerLiteral: UIApplication.shared.applicationIconBadgeNumber + 1)
                content.categoryIdentifier = "DemoNotificationCategory"
                let timeInterval = self.triggerTimePicker.countDownDuration
                // for testing the timeInterval set to 10 sec
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                self.center?.add(request, withCompletionHandler: {(error) in
                    if let error = error {
                        print("\(error)")
                    }else {
                        print("successed")
                    }
                })
            } else if titleText == nil || bodyText == nil{
                self.emptyAlert()
            }
        }
        
        
    }
    
    func emptyAlert() {
        let controller = UIAlertController(title: "Warning", message: "Title or Body can't be empty!", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(action)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    func deniedAlert() {
        let useNotificationsAlertController = UIAlertController(title: "Turn on notifications", message: "This app needs notifications turned on for the best user experience \n ", preferredStyle: .alert)
        
        // go to setting alert action
        let goToSettingsAction = UIAlertAction(title: "Go to settings", style: .default, handler: { (action) in
            guard let settingURL = URL(string: UIApplicationOpenSettingsURLString) else { return }
            if UIApplication.shared.canOpenURL(settingURL) {
                UIApplication.shared.open(settingURL, completionHandler: { (success) in
                    print("Settings opened: \(success)")
                })
            }
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        useNotificationsAlertController.addAction(goToSettingsAction)
        useNotificationsAlertController.addAction(cancelAction)
        
        self.present(useNotificationsAlertController, animated: true)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let category = UNNotificationCategory(identifier: "DemoNotificationCategory",
                                              actions: [snoozeAction,deleteAction],
                                              intentIdentifiers: [], options: [])
        center = app.center
        center?.setNotificationCategories([category])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func checkPendingNotification(_ sender: Any) {
        center?.getPendingNotificationRequests(completionHandler: {requests in
            for request in requests{
                print(request)
            }
        })
        
        /*
         center?.getDeliveredNotificationRequest(completionHandler: {requests in
            for request in requests{
                print(request)
            }
         })
        center?.removeAllPendingNotificationRequests()
        center?.removePendingNotificationRequests(withIdentifiers: ["String"])
        center?.removeAllDeliveredNotifications()
        center?.removeDeliveredNotifications(withIdentifiers: ["String"])
        */
    }

}


