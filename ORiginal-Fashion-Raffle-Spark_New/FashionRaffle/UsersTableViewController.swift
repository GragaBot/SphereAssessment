//
//  followersVCTableViewController.swift
//  FashionRaffle
//
//  Created by Mac on 5/25/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Imaginary
import ESPullToRefresh

class UsersTableViewController: UITableViewController {
    
    var userProfiles = [Profile]()
    var userLimit : UInt = 20
    var singleLoadCount : UInt = 20
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Find Users"
        fetchDetails()
        
        tableView.es.addPullToRefresh {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.4, execute: {
                self.tableView.es.stopPullToRefresh()
            })
        }
        tableView.es.addInfiniteScrolling {
            self.loadMore()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    func fetchDetails() {
        Config.showPlainLoading(withStatus: nil)
        API.userAPI.fetchAllUsers(withLimitToLast: userLimit, completed: {
            fetchProfiles in
            self.userProfiles = fetchProfiles
            self.tableView.reloadData()
            Config.dismissPlainLoading()
        })
    }

    func loadMore() {
        if userLimit <= UInt(userProfiles.count) {
            userLimit = userLimit + singleLoadCount
            let checkCount = self.userProfiles.count
            API.userAPI.fetchAllUsers(withLimitToLast: userLimit, completed: {
                fetchProfiles in
                if fetchProfiles.count > checkCount {
                    self.userProfiles.removeAll()
                    self.userProfiles = fetchProfiles
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.2, execute: {
                        self.tableView.reloadData()
                        self.tableView.es.stopLoadingMore()
                        return
                    })
                }
                else {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                        self.tableView.es.noticeNoMoreData()
                        return
                    })
                }
                
            })
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5, execute: {
                self.tableView.es.noticeNoMoreData()
            })
        }
    }
    
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TableView Delegate

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userProfiles.count

    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "UsersCell", for: indexPath) as! UsersTableViewCell
        
        cell.selectedUser = userProfiles[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser = userProfiles[indexPath.row]
        let userId = selectedUser.userID
        if userId == Profile.currentUser?.userID {
            return
        }
        let profileViewController = UIStoryboard(name: "Profile", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileCollectionViewController
        profileViewController.isProfilePage = false
        profileViewController.isCurrentUser = false
        profileViewController.selectedUser = selectedUser
        self.navigationController?.pushViewController(profileViewController, animated: true)
        
    }


}
