//
//  BrandsViewController.swift
//  FashionRaffle
//
//  Created by Mac on 4/2/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorageUI
import SVProgressHUD

class BrandsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    
    @IBOutlet weak var brandsCollectionView: UICollectionView!
    
    @IBAction func cancel(_ sender: Any) {
        Profile.currentUser?.followBrands = followed!
        //dismiss(animated: true, completion: nil)
        //print(Profile.currentUser?.followBrands, "=====", followed)
    }
    

    
    @IBAction func Done(_ sender: Any) {
        SVProgressHUD.show(withStatus: "Updating...")
        Profile.currentUser?.sync(onSuccess: {
            SVProgressHUD.dismiss()
            Config.showAlerts(title: "Have fun!", message: "Your favorite brands are updated!", handler: nil, controller: self)
        }, onError: {
            error in
            SVProgressHUD.showError(withStatus: error.localizedDescription)
            SVProgressHUD.dismiss(withDelay: 1.5)
            return
        })
        
    }
    
    
    let storageReference = FIRStorage.storage()
    let ref = FIRDatabase.database().reference()
    let followed = Profile.currentUser?.followBrands
    var brandDatas : [BrandData] = []
    var i = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.brandsCollectionView.delegate = self
        self.brandsCollectionView.dataSource = self
        self.brandsCollectionView.allowsMultipleSelection = true
        
        
        ref.child("Brands").queryOrderedByKey().observe(.childAdded, with: {
            snapshot in
            let value = snapshot.value as? NSDictionary
            
            let image = value!["Logo"] as! String
            let name = value!["Name"] as! String
            let brandData = BrandData.init(image: image, name: name)
            self.brandDatas.append(brandData)
            self.brandsCollectionView.reloadData()
            
            
        })
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.brandDatas.count
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let brandCell = collectionView.dequeueReusableCell(withReuseIdentifier: "brand", for: indexPath) as! brandCollectionViewCell
        
        
        var brandsTemp : BrandData
        brandsTemp = brandDatas[indexPath.row]
        let imageURL = brandsTemp.image
        let storage = storageReference.reference(forURL: imageURL)
        
        brandCell.brandImage.sd_setImage(with: storage)
        
        
        brandCell.layer.cornerRadius = 50
        
        brandCell.brandImage.contentMode = .scaleAspectFit
        
        
        
        
        if Profile.currentUser?.followBrands?.contains(brandsTemp.name) == true {
            brandCell.layer.borderWidth = 5
            brandCell.layer.borderColor = UIColor.darkGray.cgColor
            brandCell.visualEffectView.alpha = 0.7
            return brandCell
        } else {
            brandCell.layer.borderColor = UIColor.lightGray.cgColor
            brandCell.layer.borderWidth = 3
            brandCell.visualEffectView.alpha = 0.1
            return brandCell
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
        let brandCell = brandsCollectionView.cellForItem(at: indexPath) as! brandCollectionViewCell
        print(indexPath)
        

        if Profile.currentUser?.followBrands?.contains(brandDatas[indexPath.row].name) == false{
            Profile.currentUser?.followBrands?.append(brandDatas[indexPath.row].name)
            brandCell.layer.borderColor = UIColor.black.cgColor
            brandCell.visualEffectView.alpha = 0.5
            
        } else {
            
            let removeName = brandDatas[indexPath.row].name
            if let index = Profile.currentUser?.followBrands?.index(of:removeName){
                Profile.currentUser?.followBrands?.remove(at: index)
            }
            
            //print("======", Profile.currentUser?.followBrands)
            
            brandCell.layer.borderColor = UIColor.lightGray.cgColor
            brandCell.layer.borderWidth = 6
            brandCell.visualEffectView.alpha = 0
            brandCell.isSelected = false
        }
        
        
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = brandsCollectionView.cellForItem(at: indexPath) as! brandCollectionViewCell
        
        cell.layer.borderColor = UIColor.lightGray.cgColor
        cell.visualEffectView.alpha = 0
        
        
        //print(Profile.currentUser?.followBrands)
        
        if Profile.currentUser?.followBrands?.contains(brandDatas[indexPath.row].name) == false {
            Profile.currentUser?.followBrands?.append(brandDatas[indexPath.row].name)
            cell.layer.borderColor = UIColor.black.cgColor
            cell.visualEffectView.alpha = 0.5
            //print(Profile.currentUser?.followBrands)
        } else {
            let removeName = brandDatas[indexPath.row].name
            
            if let index = Profile.currentUser?.followBrands?.index(of:removeName){
                Profile.currentUser?.followBrands?.remove(at: index)
            }
            //print(Profile.currentUser?.followBrands)
        }
    }
    
    
}
