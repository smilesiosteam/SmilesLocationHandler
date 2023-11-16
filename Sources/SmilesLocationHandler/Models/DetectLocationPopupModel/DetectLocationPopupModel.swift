//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 15/11/2023.
//

import Foundation

// MARK: - Model

struct DetectLocationPopupModel {
    
    let message: String?
    let iconImage: String?
    let detectButtonTitle: String?
    let searchButtonTitle: String?
    
    init(message: String?, iconImage: String?, detectButtonTitle: String?, searchButtonTitle: String?) {
        
        self.message = message
        self.iconImage = iconImage
        self.detectButtonTitle = detectButtonTitle
        self.searchButtonTitle = searchButtonTitle
    }
}
