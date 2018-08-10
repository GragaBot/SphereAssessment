//
//  ProfileCollectionViewController.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/19/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit
import Imaginary
import ESPullToRefresh

class ProfileCollectionViewController: UIViewController {
    
    @IBOutlet var userProfileCollectionView: UICollectionView!
    @IBOutlet var noPostLabel: UILabel!

    var chooseProfileImage = true
    var isCurrentUser : Bool = true
    var isProfilePage : Bool = true
    var currentLoad: UInt = 9
    var singleLoadLimit: UInt = 9
    
    @IBOutlet var editProfileButton: UIBarButtonItem!
    @IBOutlet var searchUserButton: UIBarButtonItem!
    
    var selectedUser: Profile? {
        didSet {

            fetchUserName()
            fetchPostStrings()
            
        }
    }
    
    var userPosts = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noPostLabel.text = ""
        userProfileCollectionView.es.addInfiniteScrolling {
            self.loadMore()
        }
        userProfileCollectionView.delegate = self
        userProfileCollectionView.dataSource = self
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.tintColor = UIColor.black
        self.navigationController?.hidesBarsOnSwipe = false
        if isProfilePage {
            self.navigationItem.rightBarButtonItems = [self.editProfileButton, self.searchUserButton]
        }
        else {
            self.navigationItem.rightBarButtonItems = nil
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isProfilePage {
            selectedUser = Profile.currentUser
            self.updateHeaderView()
        }
    }
    
    func fetchPostStrings() {
        if let user = selectedUser {
            let userID = user.userID
            API.userAPI.fetchUserPostsID(withUserID: userID, withLimitToLast: self.currentLoad, completion: {
                fetchedStr in
                if let nowStrs = fetchedStr {
                    if self.userPosts == nowStrs {
                        print("No new stuff")
                        return
                    }
                    self.noPostLabel.isHidden = true
                    self.userPosts = nowStrs
                    self.userProfileCollectionView.reloadData()
                }
                else {
                    self.noPostLabel.isHidden = false
                    self.noPostLabel.text = "No Posts Yet"
                }
            })
        }
    }
    
    func loadMore() {
        if currentLoad <= UInt(userPosts.count) {
            currentLoad = currentLoad + singleLoadLimit
            let checkCount = self.userPosts.count
            API.userAPI.fetchUserPostsID(withUserID: (selectedUser?.userID)!, withLimitToLast: self.currentLoad, completion: {
                fetchedStr in
                if let tempStr = fetchedStr {
                    if tempStr.count > checkCount {
                        print("Has more Data")
                        self.userPosts.removeAll()
                        self.userPosts = tempStr
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                            self.userProfileCollectionView.es.noticeNoMoreData()
                            self.userProfileCollectionView.reloadData()
                            self.userProfileCollectionView.es.stopLoadingMore()
                            return
                        })
                        
                    }
                    else {
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                            self.userProfileCollectionView.es.noticeNoMoreData()
                            return
                        })
                        
                    }
                }
            })
        }
        else {
            print("No more data")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                self.userProfileCollectionView.es.noticeNoMoreData()
            })
        }
    }
    
    func fetchUserName() {
        navigationItem.title = selectedUser?.username
    }

    func updateHeaderView() {
        guard let headerView = userProfileCollectionView.viewWithTag(60) as? ProfileHeaderView else {
            return
        }
        headerView.updateProfileView(currentUser: true)
        
    }
    
    
}


extension ProfileCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    // Scroll View

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard let headerView = userProfileCollectionView.viewWithTag(60) as? ProfileHeaderView else {
            print("No headerView")
            return
        }
        let appBarHeight = Size.appBarHeight(self)
        let y = scrollView.contentOffset.y
        if y < 0 - appBarHeight {
            headerView.profileBackgroundImageView.frame.origin.y = appBarHeight + y
            headerView.profileBackgroundImageView.frame.size.height = 250 - appBarHeight - y
        }
        
    }

    // HeaderView
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ProfileHeaderView", for: indexPath) as! ProfileHeaderView

        if let user = selectedUser {
            headerView.isCurrentUser = self.isCurrentUser
            headerView.user = user
            headerView.initializeView()
            headerView.homeViewController = self

        }
        return headerView
    }

    // CollectionView stuff
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionCell", for: indexPath) as! ProfileCollectionCell
        
        let currentPostID = userPosts[indexPath.item]
        cell.postID = currentPostID
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.width
        let cellWidth = CGFloat((screenWidth - 3*2)/3)
        let cellSize = CGSize(width: cellWidth, height: cellWidth)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.userPosts.count
    }
    
    
}
