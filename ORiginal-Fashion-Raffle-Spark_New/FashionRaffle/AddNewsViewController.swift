//
//  AddNewsViewController.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 4/3/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import Photos
import NohanaImagePicker

class AddNewsTableViewController: UITableViewController {
    
    var imagePool : [UIImage?] = []
    
    var imageDetailPool : [UIImage] = []
    
    var maxSelection : Int = 8
    
    var showDetails: Bool?
    
    @IBOutlet weak var titleImage: UIImageView!
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var subtitleText: UITextField!
    @IBOutlet weak var releaseDLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var detailText: UITextView!
    
    @IBOutlet var imageCollectionView: UICollectionView!
    @IBOutlet var addDetailsTableCell: UITableViewCell!
    @IBOutlet var releaseHandleTable: UITableViewCell!
    @IBOutlet var detailbutton: UIButton!
    
    @IBOutlet var datapickerCell: UITableViewCell!
    
    @IBAction func HideShowButton(_ sender: Any) {
        if self.showDetails == false {
            
            UIView.animate(withDuration: 0.3, animations: {
                //self.releaseHandleTable.frame.size.height = 324
                self.datapickerCell.frame.size.height = 274
                self.detailbutton.setTitle("△", for: .normal)
            })
            self.showDetails = true
            print("show is true")
            return
        }
        else {

            UIView.animate(withDuration: 0.3, animations: {
                //self.releaseHandleTable.frame.size.height = 50
                self.datapickerCell.frame.size.height = 0
                self.detailbutton.setTitle("▽", for: .normal)
            })
            self.showDetails = false
            print("show is false")
            return
            
        }
        
    }
    
    //Upload this release news.
    
    @IBAction func postNews(_ sender: Any) {
        let titleEdit = self.titleText.text
        let subtitleEdit = self.subtitleText.text
        let detailEdit = self.detailText.text
        let imageSelect = self.titleImage.image

        if (titleEdit == "" || subtitleEdit == "" || detailEdit == "" || imageSelect == nil) {
            Config.showAlerts(title: "", message:"Release News title, subtitle, details and title image are required!", handler: nil, controller: self)
            return
        }else if imageDetailPool.count == 0 {
            Config.showAlertsWithOptions(title: "", message: "Upload without detail photos?", controller: self, yesHandler: {
                UIAlertAction in
                self.beginUpload()
                
            }, cancelHandler: nil)
        }
        else {
            Config.showAlertsWithOptions(title: "", message: "Upload?", controller: self, yesHandler: {
                UIAlertAction in
                self.beginUpload()
            }, cancelHandler: nil)
            
        }
    }
    
    func beginUpload() {
        
        let titleEdit = self.titleText.text
        let subtitleEdit = self.subtitleText.text
        let detailEdit = self.detailText.text
        let imageSelect = self.titleImage.image
        let releaseDstr = self.releaseDLabel!.text
        
        let news = NewsFeed.createNewFeed(newsID: nil, releaseDate: releaseDstr, title: titleEdit!, subtitle: subtitleEdit!, detailInfo: detailEdit!, tags: nil, headImageURL: nil, detailImageURLs: [])
        
        API.releaseAPI.uploadNews(withNewsFeed: news!, withHeadImage: imageSelect!, withDetailImages: self.imageDetailPool, onSuccess: {
            Config.showAlerts(title: "Success!", message: "", handler: {
                _ in
                self.dismiss(animated: true, completion: nil)
            }, controller: self)
        })

    }
    
    //Finish
    
    @IBAction func backToProfile(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        showDetails = false
        tableView.allowsSelection = false
        titleImage.isUserInteractionEnabled = true
        titleImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectNewsImageView)))
    

        self.imageCollectionView.delegate = self
        self.imageCollectionView.dataSource = self
        self.imageCollectionView.allowsSelection = true

        self.titleImage.layer.borderColor = UIColor.black.cgColor
        self.titleImage.layer.borderWidth = 1
        
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        self.updateDateLabel()
        
        datePicker.addTarget(self, action: #selector(datePickerChanged(datePicker:)), for: .valueChanged)
        timePicker.addTarget(self, action: #selector(timePickerChanged(timePicker:)), for: .valueChanged)
        
    }
    
    
    func updateDateLabel() {
        let dateFormat = DateFormatter()
        let timeFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        timeFormat.dateFormat = "HH:mm"
        let strDate = dateFormat.string(from: self.datePicker.date)
        let strTime = timeFormat.string(from: self.timePicker.date)
        self.releaseDLabel.text = strDate + " " + strTime
    }
    
    func datePickerChanged(datePicker:UIDatePicker) {
        self.updateDateLabel()
    }
    
    func timePickerChanged(timePicker:UIDatePicker) {
        self.updateDateLabel()
        
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Mess with views

    // push detail contents.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let selectedIndexPath = imageCollectionView.indexPathsForSelectedItems?.first else{
            return
        }
        let reusableVC = segue.destination as! ReusableDetaiViewController
        reusableVC.delegate = self
        
        reusableVC.imageAssets = self.imageDetailPool
        reusableVC.currentIndexPath = selectedIndexPath
        reusableVC.deletable = true
        //reusableVC.rootCollectionViewController = self
    }
}

extension AddNewsTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate,NohanaImagePickerControllerDelegate {
    func handleSelectNewsImageView() {
        let imagePC = UIImagePickerController()
        imagePC.sourceType = .photoLibrary
        imagePC.delegate = self
        imagePC.allowsEditing = true
        present(imagePC, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImage = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImage = originalImage
        }
        
        if let selectImg = selectedImage {
            titleImage.image = selectImg
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    //NohanaIP delegates
    func nohanaImagePickerDidCancel(_ picker: NohanaImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func nohanaImagePicker(_ picker: NohanaImagePickerController, didFinishPickingPhotoKitAssets pickedAssts: [PHAsset]) {
        //

        
        let imageManager = PHImageManager.init()
        let options = PHImageRequestOptions.init()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .exact
        options.isSynchronous = true
        
        for assets: PHAsset in pickedAssts {
            
            let cgSize = CGSize(width: 250, height: 250)
            let width = self.view.frame.width * 3
            let height = self.view.frame.height * 3
            let cgSize2 = CGSize(width: width, height: height)
            
            imageManager.requestImage(for: assets, targetSize: cgSize, contentMode: .aspectFit, options: options, resultHandler: {
                (image, info) in
                
                self.imagePool.append(image!)
            })
            imageManager.requestImage(for: assets, targetSize: cgSize2, contentMode: .aspectFit, options: options, resultHandler: {
                (image, info) in
                
                self.imageDetailPool.append(image!)
            })
        }
        //Results are put in imagePool

        self.imageCollectionView.reloadData()
        dismiss(animated: true, completion: nil)
        
    }

    //Delegates for collection view

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        if indexPath.row == self.imagePool.count {
            let cell2 = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionHeaderCell", for: indexPath)
            let imageV = cell2.viewWithTag(2) as! UIImageView
            imageV.layer.borderColor = UIColor.black.cgColor
            imageV.layer.borderWidth = 1
            
            return cell2
        }
        else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath)
            let imageView = cell.viewWithTag(5) as! UIImageView

            imageView.image = self.imagePool[indexPath.row]
            return cell
        }
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.imagePool.count + 1
        return count
    }

    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == self.imagePool.count {
            print("Photo Picker Revoked")
            let ipicker = NohanaImagePickerController()
            let count = self.imagePool.count
            if count == 8 {
                Config.showAlerts(title: "Oops", message: "You've selected maximum number of photos", handler: {
                    UIAlertAction in
                    return
                }, controller: self)
            }
            ipicker.maximumNumberOfSelection = self.maxSelection - count
            ipicker.shouldShowMoment = false
            ipicker.shouldShowEmptyAlbum = false
            ipicker.toolbarHidden = false
            ipicker.delegate = self
            present(ipicker, animated: true, completion: nil)
            
        }
        else {
            print("----")
            print("Pre selection")
            print("Index is now \(indexPath.row)")
            print("-----")
            
        }
    }
}

// Delegates for reusableDetailVC
extension AddNewsTableViewController: ReusableDetaiViewControllerDelegate {
    
    func reusableDetailViewController(_ controller: ReusableDetaiViewController, didDeleteAtIndex indexPath: IndexPath) {
        self.imagePool.remove(at: indexPath.item)
        self.imageDetailPool.remove(at: indexPath.item)
        self.imageCollectionView.reloadData()
    }
    
}



