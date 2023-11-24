//
//  ConfirmUserLocationViewController.swift
//  
//
//  Created by Abdul Rehman Amjad on 16/11/2023.
//

import UIKit
import SmilesUtilities
import SmilesFontsManager
import SmilesLanguageManager
import GoogleMaps
import Combine
import CoreLocation

class ConfirmUserLocationViewController: UIViewController {

    // MARK: - OUTLETS -
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var currentLocationButton: UICustomButton!
    
    // MARK: - PROPERTIES -
    private var input: PassthroughSubject<SetLocationViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private lazy var viewModel: SetLocationViewModel = {
        return SetLocationViewModel()
    }()
    private var latitude: String = "25.20"
    private var longitude: String = "55.27"
    private var mapGesture = false
    private var selectedCity: GetCitiesModel?
    private var selectedLocation: CLLocationCoordinate2D? = CLLocationCoordinate2DMake(25.20, 55.27)
    
    // MARK: - ACTIONS -
    @IBAction func searchPressed(_ sender: Any) {
        SmilesLocationRouter.shared.pushSearchLocationVC(locationSelected: { [weak self] selectedLocation in
            self?.latitude = "\(selectedLocation.latitude)"
            self?.longitude = "\(selectedLocation.longitude)"
            self?.showLocationMarkerOnMap(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude, formattedAddress: selectedLocation.formattedAddress)
        })
    }
    
    @IBAction func currentLocationPressed(_ sender: Any) {
        
        if LocationManager.shared.isEnabled() {
            let lat = self.mapView.myLocation?.coordinate.latitude
            let lng = self.mapView.myLocation?.coordinate.longitude
            
            if let lati = lat, let long = lng {
                showLocationMarkerOnMap(latitude: lati, longitude: long)
                latitude = String(format: "%f", lati)
                longitude = String(format: "%f", long)
                if !Constants.switchToOpenStreetMap {
                    input.send(.reverseGeocodeLatitudeAndLongitudeForAddress(latitude: self.latitude, longitude: self.longitude))
                } else {
                    let coordinates = CLLocationCoordinate2D(latitude: latitude.toDouble() ?? 0, longitude: longitude.toDouble() ?? 0)
                    input.send(.locationReverseGeocodingFromOSMCoordinates(coordinates: coordinates, format: .json))
                }
            }
        } else {
            LocationManager.shared.showPopupForSettings()
        }
        
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        
//        let location = SearchLocationResponseModel()
//        location.title = locationLabel.text
//        location.lat = Double(latitude)
//        location.long = Double(longitude)
//        if let cityName = selectedCity.cityName {
//            location.selectCityName = cityName
//        }
//        
//        if let delegate = delegate {
//            delegate.getNewAddressLocation(location:location)
//            presenter?.goBackToEditAddressView()
//        }else{
//            presenter?.confirmButtonTapped(location: location, isFromAddNewAddress: isFromAddNewAddress.asBoolOrFalse(), redirectTo: confirmLocationRedirection)
//        }
        
    }
    
    // MARK: - INITIALIZERS -
    init(selectedCity: GetCitiesModel?) {
        self.selectedCity = selectedCity
        super.init(nibName: "ConfirmUserLocationViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - METHODS -
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpNavigationBar()
    }
    
    private func setupViews() {
        
        bind(to: viewModel)
        currentLocationButton.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceLeftToRight : .forceRightToLeft
        currentLocationButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: AppCommonMethods.languageIsArabic() ? 0 : 5,
                                                             bottom: 0, right: AppCommonMethods.languageIsArabic() ? 5 : 0)
        setupMap()
        setupPinForLocation()
        
    }

    private func setUpNavigationBar() {
        
        title = SmilesLanguageManager.shared.getLocalizedString(for: "Set your location")
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black, .font: SmilesFonts.circular.getFont(style: .medium, size: 16)]
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        let btnBack: UIButton = UIButton(type: .custom)
        btnBack.setImage(UIImage(named: "back_circle", in: .module, compatibleWith: nil), for: .normal)
        btnBack.addTarget(self, action: #selector(self.onClickBack), for: .touchUpInside)
        btnBack.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        let barButton = UIBarButtonItem(customView: btnBack)
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    
    @objc func onClickBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func setupMap() {
        
        mapView.delegate = self
        mapView.settings.myLocationButton = false
        mapView.isMyLocationEnabled = true
        
    }
    
    private func showLocationMarkerOnMap(latitude: Double, longitude: Double, formattedAddress: String? = nil) {
        
        DispatchQueue.main.async {
            self.mapView.clear()
            let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let marker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
            
            /// Set the map style by passing the URL of the local file.
            do {
                if let styleURL = Bundle.main.url(forResource: "MapsStyling", withExtension: "json") {
                    self.mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    print("Unable to find style.json")
                }
            } catch {
                print("One or more of the map styles failed to load. \(error)")
            }
            
            if let formatAddress = formattedAddress {
                print(formatAddress)
                self.locationLabel.text = formatAddress
            }
            marker.icon = UIImage(named: "mapPinNew", in: .module, compatibleWith: nil)
            marker.setIconSize(scaledToSize: .init(width: 40, height: 40))
            self.mapView.camera = camera
            marker.map = self.mapView
            self.mapView.selectedMarker = marker
        }
        
    }
    
    private func setupPinForLocation() {
        
        if let latitude = selectedCity?.cityLatitude, let longitude = selectedCity?.cityLongitude {
            self.latitude = "\(latitude)"
            self.longitude = "\(longitude)"
            showLocationMarkerOnMap(latitude: latitude, longitude: longitude)
        } else if let location = selectedLocation {
            latitude = "\(location.latitude)"
            longitude = "\(location.longitude)"
            showLocationMarkerOnMap(latitude: location.latitude, longitude: location.longitude)
        }
        
        if !Constants.switchToOpenStreetMap {
            input.send(.reverseGeocodeLatitudeAndLongitudeForAddress(latitude: latitude, longitude: longitude))
        } else {
            let coordinates = CLLocationCoordinate2D(latitude: latitude.toDouble() ?? 0, longitude: longitude.toDouble() ?? 0)
            input.send(.locationReverseGeocodingFromOSMCoordinates(coordinates: coordinates, format: .json))
        }
        
//        if isFromAddNewAddress.asBoolOrFalse() == true {
//            CommonMethods.fireEvent(withTag: "\(FirebaseEventTags.NewAddressMap.rawValue)")
//        } else {
//            CommonMethods.fireEvent(withTag: "\(FirebaseEventTags.DetectLocationMapOpened.rawValue)")
//        }
    }
    
}

// MARK: - VIEWMODEL BINDING -
extension ConfirmUserLocationViewController {
    
    func bind(to viewModel: SetLocationViewModel) {
        input = PassthroughSubject<SetLocationViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchAddressFromCoordinatesDidSucceed(let response):
                    self?.configureAddressString(response: response)
                case .fetchAddressFromCoordinatesDidFail(let error):
                    debugPrint(error?.localizedDescription ?? "")
                case .fetchAddressFromCoordinatesOSMDidSucceed(let response):
                    self?.configureAddressString(response: response)
                case .fetchAddressFromCoordinatesOSMDidFail(let error):
                    debugPrint(error?.localizedDescription ?? "")
                default: break
                }
            }.store(in: &cancellables)
    }
    
}

// MARK: - GOOGLE MAPS DELEGATE -
extension ConfirmUserLocationViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
        mapView.selectedMarker?.position = position.target
        let lat = position.target.latitude
        let long = position.target.longitude
        latitude = String(format: "%f", lat)
        longitude = String(format: "%f", long)
        
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        
        if gesture {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if !Constants.switchToOpenStreetMap {
                    self.input.send(.reverseGeocodeLatitudeAndLongitudeForAddress(latitude: self.latitude, longitude: self.longitude))
                } else {
                    let coordinates = CLLocationCoordinate2D(latitude: self.latitude.toDouble() ?? 0, longitude: self.longitude.toDouble() ?? 0)
                    self.input.send(.locationReverseGeocodingFromOSMCoordinates(coordinates: coordinates, format: .json))
                }
            }
        }
        self.mapGesture = gesture
        
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        return LocationPinView(frame: CGRect(x: 0, y: 0, width: mapView.frame.width, height: 63))
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        
        let lat = marker.position.latitude
        let long = marker.position.longitude
        latitude = String(format: "%f", lat)
        longitude = String(format: "%f", long)
        
        if !Constants.switchToOpenStreetMap {
            input.send(.reverseGeocodeLatitudeAndLongitudeForAddress(latitude: self.latitude, longitude: self.longitude))
        } else {
            let coordinates = CLLocationCoordinate2D(latitude: latitude.toDouble() ?? 0, longitude: longitude.toDouble() ?? 0)
            input.send(.locationReverseGeocodingFromOSMCoordinates(coordinates: coordinates, format: .json))
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging didEndDraggingMarker: GMSMarker) {
        let lat = didEndDraggingMarker.position.latitude
        let long = didEndDraggingMarker.position.longitude
        latitude = String(format: "%f", lat)
        longitude = String(format: "%f", long)
        
        if !Constants.switchToOpenStreetMap {
            input.send(.reverseGeocodeLatitudeAndLongitudeForAddress(latitude: self.latitude, longitude: self.longitude))
        } else {
            let coordinates = CLLocationCoordinate2D(latitude: latitude.toDouble() ?? 0, longitude: longitude.toDouble() ?? 0)
            input.send(.locationReverseGeocodingFromOSMCoordinates(coordinates: coordinates, format: .json))
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        
        
        return true
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        if self.mapGesture {
            let lat = position.target.latitude
            let long = position.target.longitude
            
            latitude = String(format: "%f", lat)
            longitude = String(format: "%f", long)
            
            input.send(.reverseGeocodeLatitudeAndLongitudeForAddress(latitude: self.latitude, longitude: self.longitude))
        }
        
    }
}

// MARK: - API RESPONSE CONFIGURATION -
extension ConfirmUserLocationViewController {
    
    private func configureAddressString(response: SWGoogleAddressResponse) {
        
        mapView.isUserInteractionEnabled = true
        if let results = response.results {
            guard let formatAddress = results.first?.formattedAddress else {
                return
            }
            self.locationLabel.text = formatAddress
        }
        
    }
    
    private func configureAddressString(response: OSMLocationResponse) {
        
        mapView.isUserInteractionEnabled = true
        guard let address = response.displayName else { return }
        self.locationLabel.text = address
        
    }
    
}
