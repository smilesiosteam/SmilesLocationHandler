//
//  File.swift
//
//
//  Created by Abdul Rehman Amjad on 30/05/2023.
//

import UIKit
import MapKit
import SmilesLanguageManager
import SmilesUtilities

public protocol LocationUpdateProtocol: AnyObject {
    func locationDidUpdateToLocation(location: CLLocation?, placemark: CLPlacemark?)
    func locationIsAllowedByUser(isAllowed:Bool)
}

public final class LocationManager: NSObject {
    
    enum LocationErrors: String {
        case denied = "Locations are turned off. Please turn it on in Settings"
        case restricted = "Locations are restricted"
        case notDetermined = "Locations are not determined yet"
        case notFetched = "Unable to fetch location"
        case invalidLocation = "Invalid Location"
        case reverseGeocodingFailed = "Reverse Geocoding Failed"
        case unknown = "Some Unknown Error occurred"
    }
    
    public typealias LocationClosure = ((_ location:CLLocation?,_ error: NSError?)->Void)
    private var locationCompletionHandler: LocationClosure?
    
    public typealias ReverseGeoLocationClosure = ((_ location:CLLocation?, _ placemark:CLPlacemark?,_ error: NSError?)->Void)
    private var geoLocationCompletionHandler: ReverseGeoLocationClosure?
    
    private var locationManager:CLLocationManager?
    var locationAccuracy = kCLLocationAccuracyBest
    
    private var lastLocation:CLLocation?
    public weak var delegate: LocationUpdateProtocol?
    
    public var reverseGeocoding = false
    //Singleton Instance
    public static let shared: LocationManager = {
        let instance = LocationManager()
        // setup code
        return instance
    }()
    public var isLocationEnabled = false
    
    private override init() {}
    
    //MARK:- Destroy the LocationManager
    deinit {
        destroyLocationManager()
    }
    
    //MARK:- Private Methods
    private func setupLocationManager() {
        
        //Setting of location manager
        locationManager = nil
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = locationAccuracy
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        
    }
    
    public func destroyLocationManager() {
        self.delegate = nil
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
        lastLocation = nil
    }
    
    @objc private func sendPlacemark() {
        guard let _ = lastLocation else {
            
            self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
            
            lastLocation = nil
            return
        }
        
        self.reverseGeoCoding(location: lastLocation)
        lastLocation = nil
    }
    
    @objc private func sendLocation() {
        guard let _ = lastLocation else {
            self.didComplete(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.notFetched.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.notFetched.rawValue]))
            lastLocation = nil
            return
        }
        self.didComplete(location: lastLocation,error: nil)
        lastLocation = nil
    }
    
    public func startUpdatingLocation() {
        getLocation { (_, _) in }
    }
    
    //MARK:- Public Methods
    
    /// Check if location is enabled on device or not
    ///
    /// - Parameter completionHandler: nil
    /// - Returns: Bool
    public func isLocationEnabled(completion: @escaping ((Bool) -> Void)) {
        DispatchQueue.global().async {
            if CLLocationManager.locationServicesEnabled() {
                switch CLLocationManager.authorizationStatus() {
                    case .notDetermined, .restricted, .denied:
                        completion(false)
                    case .authorizedAlways, .authorizedWhenInUse:
                    completion(true)
                    @unknown default:
                    completion(false)
                }
            } else {
                completion(false)
            }
        }
    }
    
    /// Get current location
    ///
    /// - Parameter completionHandler: will return CLLocation object which is the current location of the user and NSError in case of error
    public func getLocation(completionHandler:@escaping LocationClosure) {
        
        //Resetting last location
        lastLocation = nil
        
        self.locationCompletionHandler = completionHandler
        
        setupLocationManager()
    }
    
    
    /// Get Reverse Geocoded Placemark address by passing CLLocation
    ///
    /// - Parameters:
    ///   - location: location Passed which is a CLLocation object
    ///   - completionHandler: will return CLLocation object and CLPlacemark of the CLLocation and NSError in case of error
    public func getReverseGeoCodedLocation(location:CLLocation,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        self.geoLocationCompletionHandler = nil
        self.geoLocationCompletionHandler = completionHandler
        if !reverseGeocoding {
            reverseGeocoding = true
            self.reverseGeoCoding(location: location)
        }
        
    }
    
    /// Get Latitude and Longitude of the address as CLLocation object
    ///
    /// - Parameters:
    ///   - address: address given by the user in String
    ///   - completionHandler: will return CLLocation object and CLPlacemark of the address entered and NSError in case of error
    func getReverseGeoCodedLocation(address:String,completionHandler:@escaping ReverseGeoLocationClosure) {
        
        self.geoLocationCompletionHandler = nil
        self.geoLocationCompletionHandler = completionHandler
        if !reverseGeocoding {
            reverseGeocoding = true
            self.reverseGeoCoding(address: address)
        }
    }
    
    /// Get current location with placemark
    ///
    /// - Parameter completionHandler: will return Location,Placemark and error
    public func getCurrentReverseGeoCodedLocation(completionHandler:@escaping ReverseGeoLocationClosure) {
        
        if !reverseGeocoding {
            
            reverseGeocoding = true
            
            //Resetting last location
            lastLocation = nil
            
            self.geoLocationCompletionHandler = completionHandler
            
            setupLocationManager()
        }
    }
    
    //MARK:- Reverse GeoCoding
    private func reverseGeoCoding(location:CLLocation?) {
        CLGeocoder().reverseGeocodeLocation(location!, preferredLocale: SmilesLanguageManager.shared.currentLanguage == .ar ? Locale(identifier: "ar_SA") : Locale(identifier: "en_US") , completionHandler: {(placemarks, error)->Void in
            
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                let placemark = placemarks![0]
                LocationStateSaver.getLocationInfo()?.cityName = placemark.locality.asStringOrEmpty()
                
                if let _ = location {
                    self.didCompleteGeocoding(location: location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    private func reverseGeoCoding(address:String) {
        CLGeocoder().geocodeAddressString(address, completionHandler: {(placemarks, error)->Void in
            if (error != nil) {
                //Reverse geocoding failed
                self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.denied.rawValue),
                    userInfo:
                    [NSLocalizedDescriptionKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedFailureReasonErrorKey:LocationErrors.reverseGeocodingFailed.rawValue,
                     NSLocalizedRecoverySuggestionErrorKey:LocationErrors.reverseGeocodingFailed.rawValue]))
                return
            }
            if placemarks!.count > 0 {
                if let placemark = placemarks?[0] {
                    self.didCompleteGeocoding(location: placemark.location, placemark: placemark, error: nil)
                } else {
                    self.didCompleteGeocoding(location: nil, placemark: nil, error: NSError(
                        domain: self.classForCoder.description(),
                        code:Int(CLAuthorizationStatus.denied.rawValue),
                        userInfo:
                        [NSLocalizedDescriptionKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedFailureReasonErrorKey:LocationErrors.invalidLocation.rawValue,
                         NSLocalizedRecoverySuggestionErrorKey:LocationErrors.invalidLocation.rawValue]))
                }
                if(!CLGeocoder().isGeocoding){
                    CLGeocoder().cancelGeocode()
                }
            }else{
                print("Problem with the data received from geocoder")
            }
        })
    }
    
    //MARK:- Final closure/callback
    private func didComplete(location: CLLocation?,error: NSError?) {
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
        locationCompletionHandler?(location,error)
    }
    
    private func didCompleteGeocoding(location:CLLocation?,placemark: CLPlacemark?,error: NSError?) {
        locationManager?.stopUpdatingLocation()
        locationManager?.delegate = nil
        locationManager = nil
        reverseGeocoding = false
        geoLocationCompletionHandler?(location,placemark,error)
    }
    
    
    public func showPopupForSettings(title: String = "DisabledLocationTitle".localizedString, message: String = "TurnOnLocationTitle".localizedString) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(0.2))) {
//            CommonMethods.showPrompetPopUpTitle(title, message: message, confirmTitle: "SettingTitle".localizedString, cancelTitle: "btn_Cancel".localizedString, confirmationHandler: {
//
//                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
//                    return
//                }
//                if UIApplication.shared.canOpenURL(settingsUrl) {
//                    UIApplication.shared.open(settingsUrl, completionHandler: { success in
//                        print("Settings opened: \(success)") // Prints true
//                    })
//                }
//
//            }) {
//
//            }
            
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "SettingTitle".localizedString, style: .default) { (alert) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { success in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(OKAction)
            let cancelAction = UIAlertAction(title: "btn_Cancel".localizedString.capitalizingFirstLetter(), style: .cancel) { (action) in

            }

            alertController.addAction(cancelAction)
            
            UIViewController().findLastPresentedViewController()?.present(alertController, animated: true, completion: nil)
//            UIViepresent(alertController, animated: true, completion: nil)
            
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    
    //MARK:- CLLocationManager Delegates
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastLocation = locations.last
        if let location = locations.last {
            let locationAge = -(location.timestamp.timeIntervalSinceNow)
            if (locationAge > 5.0) {
                print("old location \(location)")
                return
            }
            if location.horizontalAccuracy < 0 {
                self.locationManager?.stopUpdatingLocation()
//                self.locationManager?.startUpdatingLocation()
                return
            }
            if self.reverseGeocoding {
                self.sendPlacemark()
            } else {
                self.sendLocation()
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        LocationManager.shared.isLocationEnabled = false
        switch status {
            
        case .authorizedWhenInUse,.authorizedAlways:
            self.locationManager?.startUpdatingLocation()
            self.delegate?.locationIsAllowedByUser(isAllowed: true)
            LocationManager.shared.isLocationEnabled = true
            
        case .denied:
            let deniedError = NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.denied.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.denied.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.denied.rawValue])
            
            if reverseGeocoding {
                didCompleteGeocoding(location: nil, placemark: nil, error: deniedError)
            } else {
                didComplete(location: nil,error: deniedError)
            }
            
            self.delegate?.locationIsAllowedByUser(isAllowed: false)
            
        case .restricted:
            if reverseGeocoding {
                didComplete(location: nil,error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.restricted.rawValue),
                    userInfo: nil))
            } else {
                didComplete(location: nil,error: NSError(
                    domain: self.classForCoder.description(),
                    code:Int(CLAuthorizationStatus.restricted.rawValue),
                    userInfo: nil))
            }
            
            self.delegate?.locationIsAllowedByUser(isAllowed: false)
        case .notDetermined:
            self.locationManager?.requestWhenInUseAuthorization()
            
        @unknown default:
            didComplete(location: nil,error: NSError(
                domain: self.classForCoder.description(),
                code:Int(CLAuthorizationStatus.denied.rawValue),
                userInfo:
                [NSLocalizedDescriptionKey:LocationErrors.unknown.rawValue,
                 NSLocalizedFailureReasonErrorKey:LocationErrors.unknown.rawValue,
                 NSLocalizedRecoverySuggestionErrorKey:LocationErrors.unknown.rawValue]))
            self.delegate?.locationIsAllowedByUser(isAllowed: false)
        }
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if #available(iOS 14.0, *) {
            switch manager.authorizationStatus {
            case .authorizedAlways, .authorizedWhenInUse:
                self.locationManager?.startUpdatingLocation()
                self.delegate?.locationIsAllowedByUser(isAllowed: true)
            case .denied, .restricted:
                self.delegate?.locationIsAllowedByUser(isAllowed: false)
            case .notDetermined:
                self.locationManager?.requestWhenInUseAuthorization()
            @unknown default:
                break
            }
        } else {
            // Fallback on earlier versions
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        self.didComplete(location: nil, error: error as NSError?)
    }
    
}


class DebugCheatSheet {

    private var window: UIWindow?

    func present(title: String, message: String) {
        let vc = UIViewController()
        vc.view.backgroundColor = .clear

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = vc
        window?.windowLevel = UIWindow.Level.alert + 1
        window?.makeKeyAndVisible()

        vc.present(sheet(title: title, message: message), animated: true, completion: nil)
    }

    private func sheet(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController.init(title: title, message: message, preferredStyle: .actionSheet)
        addAction(title: "SettingTitle".localizedString, style: .default, to: alert) {
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { success in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }
        addAction(title: "btn_Cancel".localizedString, style: .cancel, to: alert) {
            print("Cancel")
        }
        return alert
    }

    private func addAction(title: String?, style: UIAlertAction.Style, to alert: UIAlertController, action: @escaping () -> ()) {
        let action = UIAlertAction.init(title: title, style: style) { [weak self] _ in
            action()
            alert.dismiss(animated: true, completion: nil)
            self?.window = nil
        }
        alert.addAction(action)
    }
}
