//
//  LocationTitleTableViewCell.swift
//  
//
//  Created by Abdul Rehman Amjad on 15/11/2023.
//

import UIKit
import SmilesUtilities

class LocationTitleCollectionViewCell: UICollectionViewCell {

    // MARK: - OUTLETS -
    @IBOutlet weak var mainView: UICustomView!
    @IBOutlet weak var locationLabel: UILabel!
    
    // MARK: - PROPERTIES -
    
    
    // MARK: - ACTIONS -
    
    
    // MARK: - METHODS -
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setValues(city: GetCitiesModel) {
        
        locationLabel.text = city.cityName
        mainView.backgroundColor = city.isSelected ? UIColor(hexString: "#424c99") : .white
        mainView.borderColor = .black.withAlphaComponent(city.isSelected ? 0.5 : 0.2)
        
    }
    
}
