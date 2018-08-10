//
//  PhotoViewController.swift
//  FashionRaffle
//
//  Created by Mac on 4/29/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
//import Sharaku
import AnimatedDropdownMenu
import Fusuma


class PhotoViewController: UIViewController, FusumaDelegate {

    
    
    @IBOutlet var background: UIView!
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var fileUrlLabel: UILabel!
    @IBOutlet weak var captionLabel: UITextView!
    
    @IBOutlet weak var giveAwayContainer: UIView!
    
    
    var fusumaOne : FusumaViewController?
    //var shOne : SHViewController?
    var passingImage : UIImage?
    
    var centralVC : CentralTabBarController?
    
    //set up dropdown menu
    fileprivate let dropdownItems: [AnimatedDropdownMenu.Item] = [
        AnimatedDropdownMenu.Item.init("New Post", nil, nil),
        AnimatedDropdownMenu.Item.init("Direct Message", nil, nil),
        AnimatedDropdownMenu.Item.init("Give Away Post", nil, nil)
    ]
    
    fileprivate var selectedStageIndex: Int = 0
    fileprivate var lastStageIndex: Int = 0
    fileprivate var dropdownMenu: AnimatedDropdownMenu!
    //
    
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.captionLabel.tintColor = UIColor.black
        
        self.fileUrlLabel.isHidden = true
        
        self.navigationController?.isNavigationBarHidden = true
        
        
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        //fusuma.hasVideo = true //To allow for video capturing with .library and .camera available by default
        fusuma.cropHeightRatio = 0.6 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        fusuma.allowMultipleSelection = false // You can select multiple photos from the camera roll. The default value is false.
        fusuma.view.frame = self.view.frame
        self.addChildViewController(fusuma)
        self.view.addSubview(fusuma.view)
        fusuma.didMove(toParentViewController: self)
        fusumaOne = fusuma
        
        /*
         let fusuma = FusumaViewController()
         fusuma.delegate = self
         fusuma.view.frame = self.view.frame
         self.addChildViewController(fusuma)
         self.view.addSubview(fusuma.view)
         fusuma.didMove(toParentViewController: self)
         fusumaOne = fusuma*/
        
        setupAnimatedDropdownMenu()
        giveAwayContainer.isHidden = true
        
        
        
    }
    
    @IBAction func uploadPost(_ sender: Any) {
        let image = self.imageView.image
        let caption = self.captionLabel.text!
        if caption == "Captions." || caption == "" {
            Config.showAlerts(title: "Error", message: "Please write the caption section.", handler: nil, controller: self)
            return
        }
        else{
            
            self.view.endEditing(true)
            Config.showAlertsWithOptions(title: "Upload?", message: "", controller: self, yesHandler: {
                UIAlertAction in
                
                let imageData = UIImageJPEGRepresentation(image!, 0.6)!

                API.postAPI.uploadPostImage(withImageData: imageData, captions: caption, onSuccess: {
                    Config.showAlerts(title: "Success!", message: "", handler: {
                        _ in
                        UIView.animate(withDuration: 0.4, animations: {
                            self.dismiss(animated: true, completion: nil)
                            if let central = self.centralVC {
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1, execute: {
                                    UIView.animate(withDuration: 0.3, animations: {
                                        central.setNeedsStatusBarAppearanceUpdate()
                                        central.view.alpha = 1
                                    })
                                })
                            }
                        })
                    }, controller: self)
                })
            }, cancelHandler: nil)
            
        }
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func cancel(_ sender: Any) {
        
        UIView.animate(withDuration: 0.4, animations: {
            let animatedDropDown = self.navigationItem.titleView as! AnimatedDropdownMenu
            animatedDropDown.dismiss()
            
            self.navigationController?.isNavigationBarHidden = true
            self.fusumaOne?.view.frame.origin.x = self.view.frame.origin.x
            
        })
        
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        print("Image selected")
        
        imageView.image = image
        print("selected - filter")
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        print("disabled")
    }
    
    func fusumaDismissedWithImage(_ image: UIImage, source: FusumaMode) {
        
        print("Called when success")
        self.imageView.image = image
        /*
        let shVC = SHViewController(image: image)
        shVC.delegate = self
        
        
        self.fusumaOne?.addChildViewController(shVC)
        shVC.view.frame = self.view.frame
        self.fusumaOne?.view.addSubview(shVC.view)
        shVC.didMove(toParentViewController: self.fusumaOne)
        self.shOne = shVC
        shVC.view.frame.origin.x = self.view.frame.width + 1
        UIView.animate(withDuration: 0.3, animations: {
            shVC.view.frame.origin.x = 0
        }, completion: nil)*/
        
        UIView.animate(withDuration: 0.4, animations: {
            self.navigationController?.isNavigationBarHidden = false
            self.fusumaOne?.view.frame.origin.x = 0 - self.view.frame.width - 100
        })
        
       
    }
    // Return the image but called after is dismissed.
    
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        print("video completed and output to file: \(fileURL)")
        self.fileUrlLabel.text = "file output to: \(fileURL.absoluteString)"
        print("Called just after a video has been selected.")
    }
    
    // When camera roll is not authorized, this method is called.
    
    func fusumaCameraRollUnauthorized() {
        
        print("Camera roll unauthorized")
    }
    func fusumaClosed() {
        if let central = self.centralVC {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1, execute: {
                UIView.animate(withDuration: 0.3, animations: {
                    central.setNeedsStatusBarAppearanceUpdate()
                    central.view.alpha = 1
                })
            })
        }
    }
    
    
    //dropdown menu
    
    fileprivate func setupAnimatedDropdownMenu() {
        
        let dropdownMenu = AnimatedDropdownMenu(navigationController: navigationController, containerView: view, selectedIndex: selectedStageIndex, items: dropdownItems)
        
        dropdownMenu.cellBackgroundColor = UIColor.white
        dropdownMenu.cellSelectedColor = UIColor.lightGray
        dropdownMenu.menuTitleColor = UIColor.black
        dropdownMenu.menuArrowTintColor = UIColor.black
        dropdownMenu.cellTextColor = UIColor.black
        
        
        dropdownMenu.cellTextAlignment = .center
        dropdownMenu.cellSeparatorColor = .clear
        
        dropdownMenu.didSelectItemAtIndexHandler = {
            [weak self] selectedIndex in
            
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.lastStageIndex = strongSelf.selectedStageIndex
            strongSelf.selectedStageIndex = selectedIndex
            
            guard strongSelf.selectedStageIndex != strongSelf.lastStageIndex else {
                return
            }
            
            //Configure Selected Action
            strongSelf.selectedAction()
        }
        
        self.dropdownMenu = dropdownMenu
        navigationItem.titleView = dropdownMenu
    }
    
    private func selectedAction() {
        
        if selectedStageIndex == 0{
            giveAwayContainer.isHidden = true
        }
        if selectedStageIndex == 1{
            giveAwayContainer.isHidden = true
        }
        if selectedStageIndex == 2{
            giveAwayContainer.isHidden = false
        }
        print("\(dropdownItems[selectedStageIndex].title)")
    }
    
    
    fileprivate func resetNavigationBarColor() {
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.barTintColor = UIColor.brown
        
        let textAttributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.purple,
            NSAttributedStringKey(rawValue: NSAttributedStringKey.font.rawValue): UIFont.boldSystemFont(ofSize: 6)
        ]
        
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    
    
    
}
/*
extension PhotoViewController : SHViewControllerDelegate {
    func shViewControllerDidCancel() {
        UIView.animate(withDuration: 0.3, animations: {
            self.shOne?.view.frame.origin.x = self.view.frame.width + 100
        }, completion: {
            _ in
            self.shOne?.view.removeFromSuperview()
            self.shOne?.removeFromParentViewController()
        })
    }
    func shViewControllerImageDidFilter(image: UIImage) {
        
        self.imageView.image = image
        
        UIView.animate(withDuration: 0.4, animations: {
            self.navigationController?.isNavigationBarHidden = false
            self.fusumaOne?.view.frame.origin.x = 0 - self.view.frame.width - 100
        })
    }
}*/
