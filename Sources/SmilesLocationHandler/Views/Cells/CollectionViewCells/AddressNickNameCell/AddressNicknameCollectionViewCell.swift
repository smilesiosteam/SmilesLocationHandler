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

class AddressNicknameCollectionViewCell: UICollectionViewCell {
    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .montserratSemiBoldFont(size: 15)
            titleLabel.textColor = .appDarkGrayColor
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
        titleLabel.text = nickName.nickname
    }
}
