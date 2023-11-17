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

protocol SmilesManageAddressTableViewCellDelegate: AnyObject {
    func didTapDeleteButtonInCell(_ cell: SmilesManageAddressTableViewCell)
}


class SmilesManageAddressTableViewCell: UITableViewCell {
    
    // MARK: - OUTLETS -
    @IBOutlet weak var mainView: UICustomView!
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var headingLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var mainViewLeading: NSLayoutConstraint!
    
    // MARK: - PROPERTIES
    weak var delegate: SmilesManageAddressTableViewCellDelegate?
    
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
    // MARK: - IBActions
    @IBAction func didTabDeleteButton(_ sender: UIButton) {
        if let delegate = delegate {
            delegate.didTapDeleteButtonInCell(self)
        }
    }
}
