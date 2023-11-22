//
//  NicknameCollectionViewCell.swift
//  House
//
//  Created by Faraz Haider on 01/09/2020.
//  Copyright © 2020 Ahmed samir ali. All rights reserved.
//

import Foundation
import UIKit
import SmilesUtilities
import SmilesFontsManager

class AddressNicknameCollectionViewCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var addressIconImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.fontTextStyle = .smilesHeadline4
            titleLabel.textColor = .black
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        contentView.transform = .identity
        if AppCommonMethods.languageIsArabic() {
            contentView.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configureCellWithData(nickName: Nicknames) {
        addressIconImageView.setImageWithUrlString(nickName.nickNameIcon ?? "")
        titleLabel.text = nickName.nickname
    }
}
