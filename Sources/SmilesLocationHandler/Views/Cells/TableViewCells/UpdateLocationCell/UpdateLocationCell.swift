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

protocol SmilesUpdateLocationTableViewCellDelegate: AnyObject {
    func didTapDeleteButtonInCell(_ cell: UpdateLocationCell)
    func didTapDetailButtonInCell(_ cell: UpdateLocationCell)
}


class UpdateLocationCell: UITableViewCell {
    
    // MARK: - OUTLETS -
    @IBOutlet weak var mainView: UICustomView!
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var mainViewLeading: NSLayoutConstraint!
    
    // MARK: - PROPERTIES
    weak var delegate: SmilesUpdateLocationTableViewCellDelegate?
    
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
    func configureCell(with address: Address?) {
        if let address = address {
            self.headingLabel.text = address.nickname
            self.detailLabel.text = String(format: "%@ %@, %@, %@, %@ ", address.flatNo.asStringOrEmpty(), "".localizedString.lowercased(), address.building.asStringOrEmpty(), address.street.asStringOrEmpty(), " \(address.locationName.asStringOrEmpty())")
            self.addressIcon.setImageWithUrlString(address.nicknameIcon ?? "")
        
        }
        
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
