//
//  LocationSearchResultTableViewCell.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import UIKit

class LocationSearchResultTableViewCell: UITableViewCell {

    // MARK: - OUTLETS -
    @IBOutlet weak var locationTitleLabel: UILabel!
    @IBOutlet weak var locationSubTitleLabel: UILabel!
    
    
    // MARK: - PROPERTIES -
    
    
    // MARK: - ACTIONS -
    
    
    // MARK: - METHODS -
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setValues(location: SearchedLocationDetails) {
        
        locationTitleLabel.text = location.title
        locationSubTitleLabel.text = location.subTitle
        
    }
    
}
