//
//  ProfileViewController.swift
//  SphereAssessment
//
//  Created by T on 5/17/18.
//  Copyright © 2018 T. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {
    let locationManager = CLLocationManager()
    
    var activityIndicator : UIActivityIndicatorView = UIActivityIndicatorView()
    @IBOutlet weak var gif: UIImageView!
    
    @IBOutlet weak var firstname: RoundedTextField!
    
    @IBOutlet weak var lastname: RoundedTextField!
    
    @IBOutlet weak var street: RoundedTextField!
    
    @IBOutlet weak var city: RoundedTextField!
    
    @IBOutlet weak var state: RoundedTextField!
    
    @IBOutlet weak var zip: RoundedTextField!
    
    let activityIN : UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x: 100, y: 200, width: 50, height: 50)) as UIActivityIndicatorView
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            print("Found user's location: \(location)")
            let geoCoder = CLGeocoder()
            
            geoCoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                guard let addressDict = placemarks?[0].addressDictionary else {
                    return
                }
                
                addressDict.forEach { print($0) }
                
                // Print fully formatted address
                if let formattedAddress = addressDict["FormattedAddressLines"] as? [String] {
                    print(formattedAddress.joined(separator: ", "))
                }
                
                // Access each element manually
                if let state = addressDict["State"] as? String {
                    print(state)
                    self.state.text = state
                    
                }
                //if let street = addressDict["Thoroughfare"] as? String {
                //    print(street)
                //}
                if let city = addressDict["City"] as? String {
                    print(city)
                    self.city.text = city
                }
                if let zip = addressDict["ZIP"] as? String {
                    print(zip)
                    self.zip.text = zip
                }
              
            })
            activityIN.stopAnimating()

        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if(status == CLAuthorizationStatus.denied) {
            showLocationDisabledPopUp()
        }
    }
    
    func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Background Location Access Disabled",
                                                message: "In order to deliver pizza we need your location",
                                                preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            
            activityIN.center = self.view.center
            activityIN.hidesWhenStopped = true
            activityIN.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            activityIN.startAnimating()
            self.view.addSubview(activityIN)
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
            locationManager.requestLocation()
            
            

        }
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.done, target: self, action: #selector(self.doneClicked))
        toolBar.setItems([doneButton], animated: false)
        firstname.inputAccessoryView = toolBar
        lastname.inputAccessoryView = toolBar
        street.inputAccessoryView = toolBar
        city.inputAccessoryView = toolBar
        state.inputAccessoryView = toolBar
        zip.inputAccessoryView = toolBar
        zip.delegate = self
        
       
        gif.loadGif(name: "gif")

    }
    @objc func doneClicked(){
        view.endEditing(true)
    }
    
 

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters, options: [], range: string.startIndex ..< string.endIndex) == nil
    }
   
    @IBAction func upload(_ sender: Any) {
        view.endEditing(true)
        if (firstname.text?.isEmpty)! || (lastname.text?.isEmpty)! || (street.text?.isEmpty)! || (city.text?.isEmpty)! || (state.text?.isEmpty)! || (zip.text?.isEmpty)!{
            print("empty")
        } else {
            
            let newProfile = Profile(firstname: firstname.text, lastname: lastname.text, street: street.text, city: city.text, state: state.text, zip: zip.text)
            guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else { return}
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            let session = URLSession.shared

            do {
                request.httpBody = try JSONEncoder().encode(newProfile)
                
            } catch let error {
                print(error.localizedDescription)
                
                Config.showAlerts(title: "Error", message: "Registration Failed", handler: nil, controller: self)
                print(error.localizedDescription)
            }
            
            session.dataTask(with: request) {
                (data, response, error) in
                guard error == nil else {
                    print(error!)
                    return
                }
                guard let data = data else {
                    print("no data")
                    return
                }
                
                do{
                    
                    let json = try JSONDecoder().decode(Profile.self, from: data)
                    
                   print(json)
                        
                    let jsonString = String(describing: json)
                        

                    Config.showAlerts(title: "✔️Uploaded Information✔️ ", message: jsonString, handler: nil, controller: self)
                   
                   
                } catch  {
                    Config.showAlerts(title: "Error", message: "Failed Uploading", handler: nil, controller: self)
                }
                }.resume()
            
            

        }
        
        
    }
    
}
