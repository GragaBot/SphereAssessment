//
//  RafflesReusableCell.swift
//  FashionRaffle
//
//  Created by Spark Da Capo on 6/3/17.
//  Copyright © 2017 Mac. All rights reserved.
//

import Foundation
import UIKit

class RafflePoolCell: UITableViewCell{
    @IBOutlet weak var CellImage: UIImageView!
    
    @IBAction func PullMenu(_ sender: Any) {
        
        
        
    }
    @IBOutlet weak var Subtitle: UILabel!
    @IBOutlet weak var Title: UILabel!
    
    var raffleValue : RaffleFeed? {
        didSet {
            updateCellView()
        }
    }
    
    func updateCellView() {
        if let raffle = raffleValue {
            let imageUrl = raffle.headImageUrl
            self.CellImage.setImage(url: imageUrl)
            self.Title.text = raffle.title
            self.Subtitle.text = raffle.subtitle
        }
    }
    
    
}
