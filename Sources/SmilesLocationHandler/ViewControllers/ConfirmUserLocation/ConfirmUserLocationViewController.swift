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
import SmilesLoader

enum ConfirmLocationSourceScreen {
    case addAddressViewController
    case editAddressViewController
    case searchLocation
    case updateUserLocation(isFromFoodCart: Bool)
    case setLocation
}

class ConfirmUserLocationViewController: UIViewController, SmilesPresentableMessage {

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
    private var latitude: Double = 25.20
    private var longitude: Double = 55.27
    private var mapGesture = false
    private var selectedCity: GetCitiesModel?
    private var selectedLocation: CLLocationCoordinate2D? = CLLocationCoordinate2DMake(25.20, 55.27)
    private weak var delegate: ConfirmLocationDelegate?
    private var sourceScreen: ConfirmLocationSourceScreen = .addAddressViewController
    private var pinView: LocationPinView!
    private var pinViewHeight: CGFloat = 113
    
    // MARK: - ACTIONS -
    @IBAction func searchPressed(_ sender: Any) {
        
        switch sourceScreen {
        case .searchLocation:
            SmilesLocationRouter.shared.popVC()
        default:
            SmilesLocationRouter.shared.pushSearchLocationVC(locationSelected: { [weak self] selectedLocation in
                self?.latitude = selectedLocation.latitude
                self?.longitude = selectedLocation.longitude
                self?.showLocationOnMap(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude, formattedAddress: selectedLocation.formattedAddress)
            })
        }
    }
    
    @IBAction func currentLocationPressed(_ sender: Any) {
        
        LocationManager.shared.isLocationEnabled() { [weak self] isEnabled in
            guard let self else { return }
            if isEnabled {
                if let lat = self.mapView.myLocation?.coordinate.latitude, let long = self.mapView.myLocation?.coordinate.longitude {
                    latitude = lat
                    longitude = long
                    showLocationOnMap(latitude: latitude, longitude: longitude)
                    if !Constants.switchToOpenStreetMap {
                        input.send(.reverseGeocodeLatitudeAndLongitudeForAddress(latitude: "\(self.latitude)", longitude: "\(self.longitude)"))
                    } else {
                        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        input.send(.locationReverseGeocodingFromOSMCoordinates(coordinates: coordinates, format: .json))
                    }
                }
            } else {
                LocationManager.shared.showPopupForSettings()
            }
        }
        
    }
    
    @IBAction func confirmPressed(_ sender: Any) {
        
        let location = SearchLocationResponseModel()
        location.title = locationLabel.text
        location.lat = Double(latitude)
        location.long = Double(longitude)
        if let city = selectedCity {
            location.selectCityName = city.cityName.asStringOrEmpty()
        }
        switch sourceScreen {
        case .addAddressViewController:
            moveToAddAddress(with: location)
        case .editAddressViewController:
            delegate?.locationPicked(location: location)
            SmilesLocationRouter.shared.popVC()
        case .searchLocation:
            if let controllers = navigationController?.viewControllers, let updateLocationVC = controllers[safe: controllers.count - 3] as? UpdateLocationViewController {
                self.navigationController?.popToViewController(updateLocationVC, animated: true)
                delegate?.locationPicked(location: location)
            }
        case .setLocation:
            SmilesLoader.show()
            input.send(.getUserLocation(location: CLLocation(latitude: latitude, longitude: longitude)))
        case .updateUserLocation(let isFromFoodCart):
            if isFromFoodCart {
                moveToAddAddress(with: location)
            } else {
                delegate?.locationPicked(location: location)
                SmilesLocationRouter.shared.popVC()
            }
        }
        
    }
    
    // MARK: - INITIALIZERS -
    init(selectedCity: GetCitiesModel?, sourceScreen: ConfirmLocationSourceScreen, delegate: ConfirmLocationDelegate?) {
        self.selectedCity = selectedCity
        self.sourceScreen = sourceScreen
        self.delegate = delegate
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pinView.center = CGPoint(x: mapView.center.x, y: mapView.center.y - (pinViewHeight / 2))
    }
    
    private func setupViews() {
        
        bind(to: viewModel)
        currentLocationButton.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceLeftToRight : .forceRightToLeft
        currentLocationButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: AppCommonMethods.languageIsArabic() ? 0 : 5,
                                                             bottom: 0, right: AppCommonMethods.languageIsArabic() ? 5 : 0)
        setupMap()
        setupLocationOnMap()
        
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
        setupMapPin()
        
    }
    
    private func setupMapPin() {
        
        pinView = LocationPinView(frame: CGRect(x: 0, y: 0, width: mapView.frame.width, height: pinViewHeight))
        pinView.isUserInteractionEnabled = false
        self.view.addSubview(pinView)
        
    }
    
    private func moveToAddAddress(with selectedLocation: SearchLocationResponseModel) {
        if let navigationController = navigationController {
            SmilesLocationRouter.shared.pushAddOrEditAddressViewController(with: navigationController, addressObject: nil, selectedLocation: selectedLocation, delegate: delegate)
        }
    }
    
    private func showLocationOnMap(latitude: Double, longitude: Double, formattedAddress: String? = nil) {
        
        DispatchQueue.main.async {
            self.mapView.clear()
            let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 15)
            self.mapView.camera = camera
            if let formatAddress = formattedAddress {
                self.locationLabel.text = formatAddress
            }
        }
        
    }
    
    private func setupLocationOnMap() {
        
        if let latitude = selectedCity?.cityLatitude, let longitude = selectedCity?.cityLongitude {
            self.latitude = latitude
            self.longitude = longitude
        } else if let location = selectedLocation {
            latitude = location.latitude
            longitude = location.longitude
        }
        
        showLocationOnMap(latitude: latitude, longitude: longitude)
        if !Constants.switchToOpenStreetMap {
            input.send(.reverseGeocodeLatitudeAndLongitudeForAddress(latitude: "\(latitude)", longitude: "\(longitude)"))
        } else {
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            input.send(.locationReverseGeocodingFromOSMCoordinates(coordinates: coordinates, format: .json))
        }

    }
    
}

// MARK: - VIEWMODEL BINDING -
extension ConfirmUserLocationViewController {
    
    func bind(to viewModel: SetLocationViewModel) {
        input = PassthroughSubject<SetLocationViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .fetchAddressFromCoordinatesDidSucceed(let response):
                    self.configureAddressString(response: response)
                case .fetchAddressFromCoordinatesDidFail(let error):
                    debugPrint(error?.localizedDescription ?? "")
                case .fetchAddressFromCoordinatesOSMDidSucceed(let response):
                    self.configureAddressString(response: response)
                case .fetchAddressFromCoordinatesOSMDidFail(let error):
                    debugPrint(error?.localizedDescription ?? "")
                case .getUserLocationDidSucceed(let response, _):
                    self.handleUserLocationResponse(response: response)
                case .getUserLocationDidFail(error: let error):
                    SmilesLoader.dismiss()
                    if !error.localizedDescription.isEmpty {
                        self.showMessage(model: SmilesMessageModel(description: error.localizedDescription))
                    }
                default: break
                }
            }.store(in: &cancellables)
    }
    
}

// MARK: - RESPONSE HANDLING -
extension ConfirmUserLocationViewController {
    
    private func handleUserLocationResponse(response: RegisterLocationResponse) {
        
        SmilesLoader.dismiss()
        if let errorMessage = response.responseMsg, !errorMessage.isEmpty {
            self.showMessage(model: SmilesMessageModel(title: response.errorTitle, description: errorMessage))
        } else if let userInfo = response.userInfo {
            LocationStateSaver.saveLocationInfo(userInfo, isFromMamba: false)
            self.navigationController?.popToRootViewController()
            NotificationCenter.default.post(name: .LocationUpdated, object: nil)
        }
        
    }
    
}

// MARK: - GOOGLE MAPS DELEGATE -
extension ConfirmUserLocationViewController: GMSMapViewDelegate {
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        
        latitude = position.target.latitude
        longitude = position.target.longitude
        
        if !Constants.switchToOpenStreetMap {
            input.send(.reverseGeocodeLatitudeAndLongitudeForAddress(latitude: "\(self.latitude)", longitude: "\(self.longitude)"))
        } else {
            let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            input.send(.locationReverseGeocodingFromOSMCoordinates(coordinates: coordinates, format: .json))
        }
        
    }
    
}

// MARK: - API RESPONSE CONFIGURATION -
extension ConfirmUserLocationViewController {
    
    private func configureAddressString(response: SWGoogleAddressResponse) {
        
        if let results = response.results {
            guard let formatAddress = results.first?.formattedAddress else {
                return
            }
            self.locationLabel.text = formatAddress
        }
        
    }
    
    private func configureAddressString(response: OSMLocationResponse) {
        
        guard let address = response.displayName else { return }
        self.locationLabel.text = address
        
    }
    
}
