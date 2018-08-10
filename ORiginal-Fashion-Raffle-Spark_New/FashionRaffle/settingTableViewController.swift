//
//  settingTableViewController.swift
//  FashionRaffle
//
//  Created by Mac on 5/26/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import FirebaseStorageUI
import SVProgressHUD
import Cache
import PassKit
import Imaginary
import Foundation

class dayPickerModel {
    func cateValues() -> [String] {
        return ["Day", "Hour", "Minute"]
    }
    
    func modelValues(make: String) -> [String] {
        if make == "Day" {
            return ["0","1", "2", "3", "4", "5"]
        } else if make == "Hour" {
            return ["0","1", "2", "3", "4", "5", "6", "7", "8", "9", "10","11", "12", "13", "14", "15", "16", "17", "18", "19", "20","21", "22", "23", "24"]
        } else {
            return ["0", "5", "10", "15", "20", "25", "30", "35", "40", "45","50", "55", "60"]
        }
    }
}

var temp = 24*60*60



class settingTableViewController: UITableViewController, FBSDKLoginButtonDelegate, UIPickerViewDelegate, UIPickerViewDataSource{

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var Website: UITextField!
    
    @IBOutlet weak var Bio: UITextView!
    
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var addNews: UIButton!
    @IBOutlet weak var emailLogoutButton: UIButton!
    
    @IBOutlet weak var dayPicker: UIPickerView!
    

    
    
    var picker1Options:[String] = []
    var picker2Options:[String] = []
    
    var day = Double()
    var hour = Double()
    var minute = Double()
    var alarmTime = Int()
    
   
    
    @IBAction func emailLogout(_ sender: Any) {
        Config.showAlertsWithOptions(title: "", message: "Are you sure to sign out?", controller: self, yesHandler: {
            UIAlertAction in
            API.authAPI.authLogOut()
            self.logOut()
            
        }, cancelHandler: nil)
    }
    
    @IBOutlet weak var setAlarmButton: UIButton!
    @IBOutlet weak var cancelAlarmButton: UIButton!
    @IBOutlet weak var submitAlarmButton: UIButton!
    
    @IBOutlet weak var alarmCell: UITableViewCell!
    @IBAction func setAlarmButtonTapped(_ sender: Any) {
        setAlarmButton.isHidden = true
        dayPicker.isHidden = false
        cancelAlarmButton.isHidden = false
        submitAlarmButton.isHidden = false
    }
    
    @IBAction func cancelSetAlarm(_ sender: Any) {
        setAlarmButton.isHidden = false
        dayPicker.isHidden = true
        cancelAlarmButton.isHidden = true
        submitAlarmButton.isHidden = true
        //setDayPicker()
        
    }
    
    @IBAction func submitAlarm(_ sender: Any) {
        setAlarmButton.isHidden = false
        dayPicker.isHidden = true
        cancelAlarmButton.isHidden = true
        submitAlarmButton.isHidden = true
        print(alarmTime)
        let defaults = UserDefaults.standard
        defaults.set(alarmTime, forKey:"AlarmTime")
        
        
        setAlarmButtonTitle()


        
    }
    
    @IBOutlet var fbLogoutBtn : FBSDKLoginButton! = {
        let button = FBSDKLoginButton()
        return button
    }()
    
    
    @IBAction func uploadProfile(_ sender: Any) {
        
        self.view.endEditing(true)
        Profile.currentUser?.bio = self.Bio.text!
        Profile.currentUser?.website = self.Website.text!
        Profile.currentUser?.username = self.username.text!
        Profile.currentUser?.sync(onSuccess: {}, onError: {
            error in
            print(error.localizedDescription)
        })
        Config.showAlerts(title: "Profile upload", message: "Success", handler: nil, controller: self)
        
        
        
    }
    
    func setAlarmButtonTitle(){
        let defaults = UserDefaults.standard
        let D = Int(defaults.double(forKey: "AlarmTime"))
        
        
        print("Test",D)
        var t = "0 Minute"
        if D/86400 >= 1{
            t = String(Int(D/86400)) + " Day"
        } else if D/3600 >= 1{
            t = String(Int(D/3600)) + " Hour"
        } else if D/60 >= 1{
            t = String(Int(D/60)) + " Minute"
        }
        
        
        setAlarmButton.setTitle(t, for: .normal)

        
        
    }
    
    func setDayPicker() {
        let defaults = UserDefaults.standard
        let Day = defaults.double(forKey: "Day")
        let Hour = defaults.double(forKey: "Hour")
        let minute = defaults.double(forKey: "minute")
        dayPicker.selectRow(Int(Day), inComponent: 0, animated: false)
        dayPicker.selectRow(Int(Hour), inComponent: 1, animated: false)
        dayPicker.selectRow(Int(minute/5), inComponent: 2, animated: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setAlarmButtonTitle()
        

        setAlarmButton.layer.cornerRadius = setAlarmButton.frame.size.height / 2
        submitAlarmButton.isEnabled = false
        submitAlarmButton.layer.cornerRadius = submitAlarmButton.frame.size.width / 2
        cancelAlarmButton.layer.cornerRadius = submitAlarmButton.frame.size.width / 2
        submitAlarmButton.isHidden = true
        cancelAlarmButton.isHidden = true
        dayPicker.isHidden = true
        
        let makeAndModel = dayPickerModel();
        picker1Options = makeAndModel.cateValues()
        let firstValue = picker1Options[0]
        picker2Options = makeAndModel.modelValues(make: firstValue)

        
        
        dayPicker.delegate = self
        dayPicker.dataSource = self
        self.Bio.layer.borderWidth = 0.5
        self.Bio.layer.cornerRadius = 5
        self.Bio.layer.borderColor = UIColor.groupTableViewBackground.cgColor
        
        self.fbLogoutBtn.layer.cornerRadius = 5
        self.fbLogoutBtn.delegate = self
        self.emailLogoutButton.layer.cornerRadius = 5
        self.emailLogoutButton.layer.borderWidth = 1
        self.emailLogoutButton.layer.borderColor = UIColor.black.cgColor
        if FBSDKAccessToken.current() == nil{
            self.fbLogoutBtn.isHidden = true
            self.emailLogoutButton.isHidden = false
        }
        else {
            self.fbLogoutBtn.isHidden = false
            self.emailLogoutButton.isHidden = true
        }

        tableView.allowsSelection = false
        navigationController?.navigationBar.backgroundColor = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.black
        
        let username = Profile.currentUser?.username
        self.email.text = Profile.currentUser?.email
        
        
        self.username.text = username
        if let Bio = Profile.currentUser?.bio {
            if Bio == ""{
                self.Bio.text = "Bio"
                self.Bio.textColor = UIColor.lightGray
            } else {
            self.Bio.text = Bio
            }
        }
        if let web = Profile.currentUser?.website{
            self.Website.text = web
        }
        
        if Profile.currentUser?.editor == true {
            print("Is Editor")
            self.title = "Editor Profile"
            
            self.addNews.isHidden = false
            self.addNews.tintColor = UIColor.black
        }
        else {
            print("Not Editor")
            self.title = "User Profile"
            self.addNews.isHidden = true
            self.addNews.tintColor = self.navigationController?.navigationBar.tintColor
        }

        

    }
    
    func logOut() {
        Profile.currentUser = nil
        let cache = HybridCache(name: "UserCache")
        let syncCache = SyncHybridCache(cache)
        syncCache.remove("UserProfile")
        print("Cache Removed")
        let storyboard = UIStoryboard(name: "Start", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! LoginViewController
        self.present(loginVC, animated: true, completion: {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = loginVC
            
            print("Logged Out!")
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView ( _ dayPicker: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        if (component == 0) {
            return picker1Options.count
        } else {
            return picker2Options.count
        }
        
    }
    
    func pickerView (_ dayPicker: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(picker1Options[row])"
        } else {
            return "\(picker2Options[row])"
        }
    }
    
    func pickerView (_ dayPicker: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        let factor = [24*60*60, 3600, 5*60]
        
        if component == 0 {
            let makeAndModel = dayPickerModel();
            let currentValue = picker1Options[row]
            picker2Options = makeAndModel.modelValues(make: currentValue)
            temp = factor[row]
            print(temp)
            submitAlarmButton.isEnabled = false
            dayPicker.reloadAllComponents()
        } else {
            alarmTime = row * temp
            print(row * temp)
        
            submitAlarmButton.isEnabled = true
        }
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error?) {
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        API.authAPI.authLogOut()
        self.logOut()
    }
    
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool {
        return true
    }


    
    
   
}
