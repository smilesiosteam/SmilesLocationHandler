//
//  File.swift
//  
//
//  Created by Ghullam  Abbas on 15/11/2023.
//

import Foundation

// MARK: - ViewModel
 final class DetectLocationPopupViewModel {
    
    let data: DetectLocationPopupModel?
    
    init(data: DetectLocationPopupModel?) {
        self.data = data
        
    }
}



public enum LocationPopUpType {
    case detectLocation
    case deleteWorkAddress(message: String? = nil)
    // Add more cases as needed
}

final class DetectLocationPopupViewModelFactory {
    
    static func createViewModel(for controller: LocationPopUpType) -> DetectLocationPopupViewModel {
        switch controller {
        case .detectLocation:
            return createViewModelForDetectLocation()
        case .deleteWorkAddress(let message):
            return createViewModelForDeleteWorkAddress(message: message)
        }
    }
    
    private static func createViewModelForDetectLocation() -> DetectLocationPopupViewModel {
        let model = DetectLocationPopupModel(message: "detect_location_message".localizedString, iconImage: "detectLocationIcon", detectButtonTitle: "DetectLocation".localizedString, searchButtonTitle: "Search here".localizedString)
        return DetectLocationPopupViewModel(data: model)
    }
    
    private static func createViewModelForAutomaticallyDetectLocation() -> DetectLocationPopupViewModel {
        let model = DetectLocationPopupModel(message: "unable_to_detect_location".localizedString, iconImage: "detectLocationIcon", detectButtonTitle: "automatically_detect".localizedString, searchButtonTitle: "choose_from_saved_address".localizedString)
        return DetectLocationPopupViewModel(data: model)
    }
    
    private static func createViewModelForDeleteWorkAddress(message: String?) -> DetectLocationPopupViewModel {
        var messageText = "Delete Work address?"
        if let message = message {
            messageText = message
        }
        let model = DetectLocationPopupModel(message: messageText, iconImage: "delete_work_icon", detectButtonTitle: "yes_delete".localizedString, searchButtonTitle: "no_keep_it".localizedString)
        return DetectLocationPopupViewModel(data: model)
    }
}
