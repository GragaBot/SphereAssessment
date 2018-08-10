//
//  giveAwayViewController.swift
//  FashionRaffle
//
//  Created by Mac on 5/14/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit
import Foundation
import HGCircularSlider

class giveAwayViewController: UIViewController {

    @IBOutlet weak var setWinners: CircularSlider!
    
    @IBOutlet weak var setWinnersLabel: UILabel!
    
    @IBOutlet weak var duration: CircularSlider!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBOutlet weak var deadLine: CircularSlider!
    
    @IBOutlet weak var deadLineLabel: UILabel!
    
    @IBOutlet weak var AMPM: UISegmentedControl!
    
    @IBOutlet weak var summary: UILabel!
    
    @IBOutlet weak var nWinner: UILabel!
    
    @IBOutlet weak var timeInterval: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    @IBOutlet weak var tagNumber: UISlider!
    
    @IBOutlet weak var tagLabel: UILabel!
    
    var ampm = "PM"
    public var isLikeTapped: Bool! = false
    public var isCommentTapped: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
        nWinner.layer.masksToBounds = true
        nWinner.layer.cornerRadius = nWinner.frame.width/2
        timeInterval.layer.masksToBounds = true
        timeInterval.layer.cornerRadius = timeInterval.frame.width/2
        time.layer.masksToBounds = true
        time.layer.cornerRadius = time.frame.width/2
        summary.layer.masksToBounds = true
        summary.layer.cornerRadius = summary.frame.height/2
        summary.numberOfLines = 2
        
        likeButton.layer.masksToBounds = true
        likeButton.layer.cornerRadius = likeButton.frame.height/2
        commentButton.layer.masksToBounds = true
        commentButton.layer.cornerRadius = commentButton.frame.height/2
        tagLabel.isHidden = true
        tagNumber.isHidden = true

        
        

        
        deadLineLabel.isHidden = true
        durationLabel.isHidden = true
        setWinnersLabel.isHidden = true
        
        
        self.AMPM.selectedSegmentIndex = 1
        
        setupDeadLineSlider()
        deadLineLabel.text = "9"
        time.text = "9 PM"
        
        setupSetWinnersSlider()
        setWinnersLabel.text = "9"
        nWinner.text = "x 9"
        
        setupDurationSlider()
        durationLabel.text = "16"
        timeInterval.text = "16 D"
        
        getAnnounceDay()
    }
    @IBAction func AMandPM(_ sender: Any) {
        
        if AMPM.selectedSegmentIndex == 0{
            ampm = "AM"
            updateDeadLineTexts()
            getAnnounceDay()
        }
        if AMPM.selectedSegmentIndex == 1{
            ampm = "PM"
            updateDeadLineTexts()
            getAnnounceDay()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //deadline
    func setupDeadLineSlider(){
        
        deadLine.minimumValue = 0
        deadLine.maximumValue = 12
        deadLine.endPointValue = 9
        deadLine.addTarget(self, action: #selector(updateDeadLineTexts), for: .valueChanged)
        deadLine.addTarget(self, action: #selector(adjustDeadLineTexts), for: .editingDidEnd)
        

        
    }
    func updateDeadLineTexts() {
        var value = Int(deadLine.endPointValue)
        value = (value == 0 ? 12 : value)
        deadLineLabel.text = String(value)
        
        time.text = deadLineLabel.text! + " " + ampm
        
        getAnnounceDay() //
    }
    func adjustDeadLineTexts() {
        let value = round(deadLine.endPointValue)
        deadLine.endPointValue = value
        updateDeadLineTexts()
    }
    
    //duration
    func setupDurationSlider(){
        
        duration.minimumValue = 1
        duration.maximumValue = 21
        duration.endPointValue = 16
        duration.addTarget(self, action: #selector(updateDurationTexts), for: .valueChanged)
        duration.addTarget(self, action: #selector(adjustDurationTexts), for: .editingDidEnd)
        
        
        
    }
    func updateDurationTexts() {
        var value = Int(duration.endPointValue)
        value = (value == 0 ? 21 : value)
        durationLabel.text =  String(value)
        timeInterval.text = durationLabel.text! + " D"
        getAnnounceDay()
    }
    func adjustDurationTexts() {
        let value = round(duration.endPointValue)
        duration.endPointValue = value
        updateDurationTexts()
    }

    
    //winners
    func setupSetWinnersSlider(){
        setWinners.minimumValue = 0
        setWinners.maximumValue = 12
        setWinners.endPointValue = 9
        setWinners.addTarget(self, action: #selector(updateSetWinnerTexts), for: .valueChanged)
        setWinners.addTarget(self, action: #selector(adjustSetWinnerTexts), for: .editingDidEnd)
     
        
    }
    func updateSetWinnerTexts() {
        var value = Int(setWinners.endPointValue)
        value = (value == 0 ? 12 : value)
        setWinnersLabel.text = String(value)
        nWinner.text = "x " + setWinnersLabel.text!
        getAnnounceDay()

    }
    func adjustSetWinnerTexts() {
        let value = round(setWinners.endPointValue)
        setWinners.endPointValue = value
        updateSetWinnerTexts()
    }
    func getAnnounceDay() {
       
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
       
        
        let today = NSDate()
        
        let Calender = NSCalendar.current
        
        //let future = Calender.date(byAdding: Calendar.Component.day, value: 30, to: today as Date, wrappingComponents: true)
        
        var future: Date { return (Calendar.current as NSCalendar).date(byAdding: .day, value: Int(durationLabel.text!)!, to: Date(), options: [])! }
        
        let futureDate = formatter.string(from: future)
        
        let temp = setWinnersLabel.text! + " prizes draw on " + futureDate + " " + deadLineLabel.text! + " " + ampm
        
        summary.text = temp
        
        
        
        
  }
    @IBAction func commentButton(_ sender: Any) {
        isCommentTapped == true ? dehighLightCommentButton() : highLightCommentButton()
    }
    
    func highLightCommentButton() {
        isCommentTapped = true
        print("highlight")
        commentButton.layer.borderColor = UIColor.lightGray.cgColor
        commentButton.layer.borderWidth = 5
        
        tagLabel.isHidden = false
        tagNumber.isHidden = false
        
    }
    func dehighLightCommentButton() {
        isCommentTapped = false
        print("dehighlight")
        commentButton.layer.borderWidth = 0
        tagLabel.isHidden = true
        tagNumber.isHidden = true
    }
    
    @IBAction func tagNumberChange(_ sender: Any) {
        tagLabel.text = "Tag: " + String(Int(round(tagNumber.value)))
        print(round(tagNumber.value))
    }

    
    @IBAction func likeButton(_ sender: Any) {
        isLikeTapped == true ? dehighLightLikeButton() : highLightLikeButton()
        
    }
    
    func highLightLikeButton() {
        isLikeTapped = true
        print("highlight")
        likeButton.layer.borderColor = UIColor.lightGray.cgColor
        likeButton.layer.borderWidth = 5
        
    }
    func dehighLightLikeButton() {
        isLikeTapped = false
        print("dehighlight")
        likeButton.layer.borderWidth = 0
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
