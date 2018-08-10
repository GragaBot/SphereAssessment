//
//  CommentViewController.swift
//  FashionRaffle
//
//  Created by Mac on 6/8/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import FirebaseDatabase
import SVProgressHUD


class CommentViewController: UIViewController, UITextFieldDelegate {
    var viewUserID : String?
    var postId: String!
    var comments = [Comments]()
    
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        self.commentTextField.delegate = self
        self.title = "Comment"
        empty()
        handleTextField()
        loadComments()

        
    }
    func loadComments() {
        API.commentAPI.fetchComments(fromPostID: postId, withLimitToLast: 100, completed: {
            tempComments in
            if tempComments != nil {
                self.comments = tempComments!
            }
            else {
                print("no comment")
                return
            }
            print(self.comments.count, "FFFFFFFFFFFFFFFFFFFFFFFFFFF")
            
            self.tableView.reloadData()
        })
    }
    func textFieldShouldReturn(userText: UITextField!) -> Bool {
        commentTextField.resignFirstResponder()
        return true;
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func comment(_ sender: Any) {
        
        API.commentAPI.createComment(forPost: postId, withCaption: commentTextField.text!, completed: self.empty)
        self.view.endEditing(true)
        loadComments()
    }
    
    
        
    func empty() {
        self.commentTextField.text = ""
        self.sendButton.isEnabled = false
        sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        
        
    }


    
    func handleTextField() {
        commentTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControlEvents.editingChanged)
    }
    
    func textFieldDidChange() {
        if let commentText = commentTextField.text, !commentText.isEmpty {
            sendButton.setTitleColor(UIColor.black, for: UIControlState.normal)
            sendButton.isEnabled = true
            return
        }
        sendButton.setTitleColor(UIColor.lightGray, for: UIControlState.normal)
        sendButton.isEnabled = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}

extension CommentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = self.comments[indexPath.section]
        let cell = tableView.dequeueReusableCell(withIdentifier: "commentCell", for: indexPath) as! CommentTableViewCell
        cell.comment = comment
        
        return cell
    }
    
    func numberOfSections(in commentTableView: UITableView) -> Int {
        return 1
    }
    
    
   
}
