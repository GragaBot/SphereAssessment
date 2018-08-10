
//
//  LoginViewController.swift
//  FashionRaffle
//
//  Created by OneSpark Mac on 2016/10/28.
//  Copyright © 2016年 Mac. All rights reserved.
//

import UIKit
import SVProgressHUD

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    

    let defaultTickets = 0
    
    @IBOutlet var addForgetPasswordView: UIView!
    
    @IBOutlet weak var forgetPasswordTextField: UITextField!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.black
        button.setTitle("Login", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    
    let forgotPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Forgot your password?"
        return tf
    }()
    
    let nameTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.clearButtonMode = UITextFieldViewMode.whileEditing
        tf.tintColor = UIColor(red: 55/255, green: 183/255, blue: 255/255, alpha: 1)
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        return tf
    }()
    
    let nameSeparatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.keyboardType = UIKeyboardType.emailAddress
        tf.clearButtonMode = UITextFieldViewMode.whileEditing
        
        tf.tintColor = UIColor(red: 55/255, green: 183/255, blue: 255/255, alpha: 1)
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let passwordTextField:UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.clearButtonMode = UITextFieldViewMode.whileEditing
        tf.tintColor = UIColor(red: 55/255, green: 183/255, blue: 255/255, alpha: 1)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    
    //function that create the Segmented UI
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    

    //facebook login button
    @IBOutlet var fbLoginButton : FBSDKLoginButton! = {
        let button = FBSDKLoginButton()
        //button.width(equalTo: inputsContainerView.width)
        //button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        button.readPermissions = ["email"]
        return button
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.fbLoginButton.isHidden = false
    }
    //FB stuff ends
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hide the keyboard when tapping around
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.dismissKeyboard))
        
        
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(loginRegisterSegmentedControl)
        
        setUpInputsContainerView()
        setUpLoginRegisterButton()
        setUpLoginRegisterSegmentControl()
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
        
        fbLoginButton.delegate = self
        applyMotionEffect(toView:logoImageView, magnitude: 5)
        
        applyMotionEffect(toView:backgroundImageView, magnitude: 15)
        //If FB signed in

        
        let attributedString = NSAttributedString(string:"Forget your password?", attributes:[NSAttributedStringKey.foregroundColor:UIColor.white, NSAttributedStringKey.underlineStyle:1])
        passwordButton.setAttributedTitle(attributedString, for: .normal)
        
    }
    

    @IBOutlet var DimView: UIView!
    //add forgot Password Pop Up
    @IBAction func addForgetPasswordPopUp(_ sender: Any) {
        self.view.addSubview(DimView)
        self.DimView.alpha = 0
        self.view.addSubview(addForgetPasswordView)
        addForgetPasswordView.center = self.view.center
        addForgetPasswordView.transform = CGAffineTransform.init(scaleX:1.3,y:1.3)
        addForgetPasswordView.alpha = 0
        addForgetPasswordView.layer.cornerRadius = 8
        addForgetPasswordView.layer.masksToBounds = true
        self.forgetPasswordTextField.tintColor = UIColor.blue
        UIView.animate(withDuration:0.4){
            self.addForgetPasswordView.alpha = 1
            self.DimView.alpha = 0.56
            self.addForgetPasswordView.transform = CGAffineTransform.identity
        }
    }
    
    
    //do the forget password work and if successfully sent then dismiss the view
    @IBAction func dismissForgetPasswordPopUp(_ sender: Any) {
        if self.forgetPasswordTextField.text == "" {
            Config.showAlerts(title: "Oops!", message: "Please enter your email!", handler: nil, controller: self)
        }
        else{
            API.authAPI.sendPasswordReset(withEmail: self.forgetPasswordTextField.text!, onSuccess: {
                self.forgetPasswordTextField.text = ""
                Config.showAlerts(title: "Success!", message: "The password reset email was sent!", handler: {
                    UIAlertAction in
                    UIView.animate(withDuration:0.3, animations:{
                        self.addForgetPasswordView.transform = CGAffineTransform.init(scaleX:1.3,y:1.3)
                        self.addForgetPasswordView.alpha = 0
                        self.DimView.alpha = 0
                    }) {(success:Bool) in
                        self.addForgetPasswordView.removeFromSuperview()
                    }
                }, controller: self)
            })
        }
        
    }
    //Directly dismiss the password reset view
    @IBAction func dismissPasswordReset(_ sender: AnyObject) {
        UIView.animate(withDuration:0.3, animations:{
            self.addForgetPasswordView.transform = CGAffineTransform.init(scaleX:1.3,y:1.3)
            self.addForgetPasswordView.alpha = 0
            self.DimView.alpha = 0
        }) {(success:Bool) in
            self.addForgetPasswordView.removeFromSuperview()
        }
    }
    
    //TextFields Edit
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
