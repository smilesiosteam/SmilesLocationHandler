//
//  SmilesManageAddressTableViewCell.swift
//  
//
//  Created by Ghullam  Abbas on 17/11/2023.
//

import UIKit
import SmilesUtilities
import SmilesFontsManager
import SmilesLanguageManager

protocol AddressDetailsTbaleViewCellDelegate: AnyObject {
    func didTapDeleteButtonInCell(_ cell: AddressDetailsTableViewCell)
    func didTapDetailButtonInCell(_ cell: AddressDetailsTableViewCell)
}

extension AddressDetailsTbaleViewCellDelegate {
    func didTapDeleteButtonInCell(_ cell: AddressDetailsTableViewCell) {}
}


class AddressDetailsTableViewCell: UITableViewCell {
    
    // MARK: - OUTLETS -
    @IBOutlet weak var mainView: UICustomView!
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var mainViewLeading: NSLayoutConstraint!
    @IBOutlet weak var mainViewTrailing: NSLayoutConstraint!
    
    // MARK: - PROPERTIES
    weak var delegate: AddressDetailsTbaleViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        styleFontAndTextColor()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    private func styleFontAndTextColor() {
        
        self.headingLabel.fontTextStyle = .smilesHeadline4
        self.detailLabel.fontTextStyle = .smilesBody3
        self.headingLabel.textColor = .black
        self.detailLabel.textColor = .black.withAlphaComponent(0.6)
        self.forwardButton.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        self.headingLabel.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        self.detailLabel.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        
    }
    func configureCell(with address: Address?, isFromManageAddress: Bool, isEditingEnabled: Bool, isSelected: Bool? = nil) {
        
        if let address = address {
            self.headingLabel.text = address.nickname
            let flatNo = address.flatNo.asStringOrEmpty()
            let building = address.building.asStringOrEmpty()
            let street = address.street.asStringOrEmpty()
            let locationName = address.locationName.asStringOrEmpty()

            self.detailLabel.text =  createAddressString(flatNo: flatNo, building: building, street: street, locationName: locationName)
            self.addressIcon.setImageWithUrlString(address.nicknameIcon ?? "")
            
            editButton.isHidden = !isEditingEnabled
            mainViewLeading.constant = isEditingEnabled ? 48 : 16
            mainViewTrailing.constant = isEditingEnabled ? 0 : 16
            
            if !isFromManageAddress {
                if isEditingEnabled {
                    setupSelection(isSelected: false)
                    return
                }
                
                if let isSelected {
                    setupSelection(isSelected: isSelected)
                } else {
                    if let userInfo = LocationStateSaver.getLocationInfo(), let location = userInfo.location, let latitude = userInfo.latitude, let longitude = userInfo.longitude {
                        if location == address.locationName, latitude == address.latitude, longitude == address.longitude {
                            setupSelection(isSelected: true)
                            return
                        }
                    }
                    setupSelection(isSelected: false)
                }
            } else {
                forwardButton.setImage(UIImage(named: "manage_address_chevron", in: .module, with: nil), for: .normal)
            }
            
        }
        
    }
    
    private func setupSelection(isSelected: Bool) {
        
        mainView.borderColor = isSelected ? .appRevampPurpleMainColor : UIColor(red: 66/255, green: 76/255, blue: 152/255, alpha: 0.2)
        forwardButton.setImage(UIImage(named: isSelected ? "checked_address_radio" : "unchecked_address_radio", in: .module, with: nil), for: .normal)
        
    }
    
    func createAddressString(flatNo: String?, building: String?, street: String?, locationName: String?) -> String {
        let components = [flatNo, building, street, locationName]
        var addressString = ""

        for component in components {
            if let comp = component, !comp.isEmpty {
                addressString += "\(comp), "
            }
        }

        // Remove trailing comma and space if present
        if addressString.hasSuffix(", ") {
            addressString.removeLast(2)
        }

        return addressString
    }
    // MARK: - IBActions
    @IBAction func didTabDeleteButton(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.didTapDeleteButtonInCell(self)
        }
    }
    @IBAction func didTaDetailButton(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.didTapDetailButtonInCell(self)
        }
    }
}
