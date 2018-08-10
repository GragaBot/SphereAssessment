//
//  FeedSegmentedViewController.swift
//  FashionRaffle
//
//  Created by Mac on 4/3/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
class FeedSegmentedViewController: UIViewController {
    @IBOutlet weak var Controller: UISegmentedControl!
    @IBOutlet weak var RaffleFeedContainerView: UIView!
    @IBOutlet weak var SocialFeedContainerView: UIView!
    @IBOutlet weak var NewsFeedContainerView: UIView!
    
    @IBOutlet var SegmentedNaviItem: UINavigationItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let searchButton = UIBarButtonItem(image: #imageLiteral(resourceName: "search button"), style: .plain, target: self, action: #selector(self.searchTapped))
        searchButton.tintColor = UIColor.black
        SegmentedNaviItem.rightBarButtonItem = searchButton
        
        
        self.Controller.selectedSegmentIndex = 0
        NewsFeedContainerView.isHidden = false
        RaffleFeedContainerView.isHidden = true
        SocialFeedContainerView.isHidden = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changeView(_ sender: Any) {

        
        
        if Controller.selectedSegmentIndex == 0{
            UIView.animate(withDuration: 0.2, animations: {
                self.NewsFeedContainerView.isHidden = false
                self.RaffleFeedContainerView.isHidden = true
                self.SocialFeedContainerView.isHidden = true
            })
            
        }
        
        if Controller.selectedSegmentIndex == 1{
            UIView.animate(withDuration: 0.2, animations: {
                self.NewsFeedContainerView.isHidden = true
                self.RaffleFeedContainerView.isHidden = true
                self.SocialFeedContainerView.isHidden = false
            })

        }
        if Controller.selectedSegmentIndex == 2{
            UIView.animate(withDuration: 0.2, animations: {
                self.NewsFeedContainerView.isHidden = true
                self.RaffleFeedContainerView.isHidden = false
                self.SocialFeedContainerView.isHidden = true
            })

        }

    }
    
    func searchTapped() {
    
        
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
