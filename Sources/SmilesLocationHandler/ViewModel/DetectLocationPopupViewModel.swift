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



enum ControllerType {
    case detectLocation
    case automaticallyDetectLocation
    case deleteWorkAddress
    // Add more cases as needed
}

final class DetectLocationPopupViewModelFactory {
    
    static func createViewModel(for controller: ControllerType) -> DetectLocationPopupViewModel {
        switch controller {
        case .detectLocation:
            return createViewModelForDetectLocation()
        case .automaticallyDetectLocation:
            return createViewModelForAutomaticallyDetectLocation()
        case .deleteWorkAddress:
            return createViewModelForDeleteWorkAddress()
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
    
    private static func createViewModelForDeleteWorkAddress() -> DetectLocationPopupViewModel {
        let model = DetectLocationPopupModel(message: "Delete Work address?", iconImage: "delete_work_icon", detectButtonTitle: "yes_delete".localizedString, searchButtonTitle: "no_keep_it".localizedString)
        return DetectLocationPopupViewModel(data: model)
    }
}
