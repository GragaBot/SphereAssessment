//
//  NewsReusableCell.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/3/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit
import EventKit

class NewsDataCell: UITableViewCell{
    
    @IBOutlet weak var Cellimage: UIImageView!
    
    
    @IBOutlet weak var Title: UILabel!
    
    @IBOutlet weak var timestamp: UILabel!
    @IBOutlet weak var Subtitle: UILabel!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var releaseDateEvent: UIButton!
    
    var releaseNews: NewsFeed? {
        didSet {
            updateCellView()
        }
    }
    
    
    
    
    func updateCellView() {
        
        if let news = releaseNews {
            self.loadingIndicator.startAnimating()
            if let imageUrl = news.headImageUrl {
                self.Cellimage.setImage(url: imageUrl){
                    _ in
                    self.loadingIndicator.stopAnimating()
                }
            }
            self.timestamp.text = news.timestamp
            self.Title.text = news.title
            self.Subtitle.text = news.subtitle
            if let releaseD = news.releaseDate {
                self.releaseDateEvent.setTitle(releaseD, for: .normal)
            }
            else {
                self.releaseDateEvent.setTitle("TBD", for: .normal)
            }
        }
        
    }
    
    
    
    
    
    
    
    // Events Manager //
    
    
    @IBAction func createEvent(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        print(self.releaseDateEvent.currentTitle!)
        
        if appDelegate.eventStore == nil {
            appDelegate.eventStore = EKEventStore()
            
            appDelegate.eventStore?.requestAccess(
                to: EKEntityType.reminder, completion: {(granted, error) in
                    if !granted {
                        print("Access to store not granted")
                        print(error?.localizedDescription)
                    } else {
                        print("Access granted")
                    }
            })
        }
        
        if (appDelegate.eventStore != nil) {
            print( self.releaseDateEvent.currentTitle! + "test")//
            if(self.releaseDateEvent.currentTitle == "TBD"){
                return
            }
            else{
                createReminder(releasedate: self.releaseDateEvent.currentTitle!)
            }
        }
        open(scheme: "x-apple-reminder://")
        
        
    }
    
    func createReminder(releasedate: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let reminder = EKReminder(eventStore: appDelegate.eventStore!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy HH:mm"
        
        
        
        reminder.calendar = appDelegate.eventStore!.defaultCalendarForNewReminders()
        //let dateString = "12/12/2017 5:00"//test
        let dateString = releasedate
        print(releasedate + "----")
        
        reminder.title = self.Title.text! + ": "+dateString
        
        let date = dateFormatter.date(from: dateString)
        let datesss = dateFormatter.date(from: releasedate)
        print(datesss!,  "actual")
        
        
        print(dateString + "==========")
        print(date! , "result")
        let alarm = EKAlarm(absoluteDate: date!)
        
        reminder.addAlarm(alarm)
        
        do {
            try appDelegate.eventStore?.save(reminder,
                                             commit: true)
        } catch let error {
            print("Reminder failed with error \(error.localizedDescription)")
        }
    }
    
    
}

func open(scheme: String) {
    if let url = URL(string: scheme) {
        if #available(iOS 10, *) {
            UIApplication.shared.open(url, options: [:],
                                      completionHandler: {
                                        (success) in
                                        print("Open \(scheme): \(success)")
            })
        } else {
            let success = UIApplication.shared.openURL(url)
            print("Open \(scheme): \(success)")
        }
    }
}
