//
//  SmilesManageAddressesViewController.swift
//
//
//  Created by Ghullam  Abbas on 17/11/2023.
//

import UIKit
import SmilesUtilities
import SmilesLanguageManager
import Combine
import SmilesLoader
import CoreLocation

final class UpdateLocationViewController: UIViewController, Toastable {
    
    // MARK: - IBOutlets
    @IBOutlet weak var addressesTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var currentLocationRadioButton: UIButton!
    @IBOutlet weak var savedAddressedLabel: UILabel!
    @IBOutlet weak var addNewAddressLabel: UILabel!
    @IBOutlet weak var useMycurrentLocationLabel: UILabel!
    @IBOutlet weak var currentLocationLabel: UILabel!
    @IBOutlet weak var currentLocationContainer: UIView!
    @IBOutlet weak var confirmLocationButton: UIButton!
    
    // MARK: - Properties
    var selectedIndex = -1
    var isEditingEnabled: Bool = false
    var addressDataSource = [Address]()
    var selectedAddress: Address?
    private var  input: PassthroughSubject<ManageAddressViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private lazy var viewModel: ManageAddressViewModel = {
        return ManageAddressViewModel()
    }()
    private weak var delegate: UpdateUserLocationDelegate?
    // MARK: - Methods
    init(delegate: UpdateUserLocationDelegate? = nil) {
        super.init(nibName: "UpdateLocationViewController", bundle: .module)
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setUpNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let appearance = UINavigationBarAppearance()
        appearance.shadowColor = .clear
        appearance.backgroundColor = .white
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        
        
        let locationNavBarTitle = UILabel()
        locationNavBarTitle.text = "UpdateYourLocationText".localizedString
        locationNavBarTitle.textColor = .black
        locationNavBarTitle.fontTextStyle = .smilesHeadline4
        
        locationNavBarTitle.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        
        self.navigationItem.titleView = locationNavBarTitle
        /// Back Button Show
        let backButton: UIButton = UIButton(type: .custom)
        // btnBack.backgroundColor = UIColor(red: 226.0 / 255.0, green: 226.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        let image = UIImage(named: "back_circle", in: .module, compatibleWith: nil)
        
        
        backButton.setImage(image, for: .normal)
        backButton.addTarget(self, action: #selector(self.onClickBack), for: .touchUpInside)
        backButton.frame = CGRect(x: 0, y: 0, width: 32, height: 32)
        backButton.layer.cornerRadius = backButton.frame.height / 2
        backButton.clipsToBounds = true
        
        let barButton = UIBarButtonItem(customView: backButton)
        self.navigationItem.leftBarButtonItem = barButton
        self.navigationController?.navigationBar.tintColor = .black
    }
    private func styleFontAndTextColor() {
        
        self.savedAddressedLabel.fontTextStyle = .smilesHeadline3
        self.confirmLocationButton.fontTextStyle = .smilesHeadline4
        self.editButton.fontTextStyle = .smilesHeadline4
        self.addNewAddressLabel.fontTextStyle = .smilesHeadline4
        self.useMycurrentLocationLabel.fontTextStyle = .smilesHeadline4
        self.currentLocationLabel.fontTextStyle = .smilesBody3
        self.savedAddressedLabel.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        
    }
    private func updateUI() {
        self.confirmLocationButton.setTitle("confirm_address".localizedString, for: .normal)
        self.useMycurrentLocationLabel.text = "UseCurrentLocationTitle".localizedString
        self.addNewAddressLabel.text = "add_new_address".localizedString
        self.savedAddressedLabel.text = "SavedAddresses".localizedString
        self.editButton.setTitle("btn_edit".localizedString.capitalizingFirstLetter(), for: .normal)
        self.confirmLocationButton.isUserInteractionEnabled = false
        self.confirmLocationButton.backgroundColor = .appRevampPurpleMainColor.withAlphaComponent(0.5)
        if SmilesLocationHandler.isLocationEnabled {
            self.currentLocationContainer.isHidden = false
            if let userInfo = LocationStateSaver.getLocationInfo() {
                self.useMycurrentLocationLabel.text = userInfo.nickName
                self.currentLocationLabel.text = userInfo.location
            }
        }
        
    }
    func setupTableViewCells() {
        addressesTableView.registerCellFromNib(UpdateLocationCell.self, withIdentifier: String(describing: UpdateLocationCell.self), bundle: .module)
    }
    @objc func onClickBack() {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        setupTableViewCells()
        styleFontAndTextColor()
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpNavigationBar()
        updateUI()
        SmilesLoader.show(on: self.view)
        self.input.send(.getAllAddress)
    }
    // MARK: - IBActions
    @IBAction func didTabEditButton(_ sender: UIButton) {
        if (isEditingEnabled) {
            self.isEditingEnabled = false
            self.editButton.setTitle("btn_edit".localizedString.capitalizingFirstLetter(), for: .normal)
        } else {
            self.isEditingEnabled = true
            self.editButton.setTitle("Done".localizedString, for: .normal)
        }
        self.addressesTableView.reloadData()
    }
    @IBAction func didTabSearchButton(_ sender: UIButton) {
        SmilesLocationRouter.shared.pushSearchLocationVC(locationSelected: { [weak self] selectedLocation in
            //            self?.latitude = "\(selectedLocation.latitude)"
            //            self?.longitude = "\(selectedLocation.longitude)"
            //            self?.showLocationMarkerOnMap(latitude: selectedLocation.latitude, longitude: selectedLocation.longitude, formattedAddress: selectedLocation.formattedAddress)
        })
    }
    @IBAction func didTabAddAddressButton(_ sender: UIButton) {
        if let navigationController = navigationController {
            SmilesLocationRouter.shared.pushConfirmUserLocationVC(selectedCity: nil) { location in
                
            }
            
        }
        
    }
    @IBAction func didTabCurrentLocationButton(_ sender: UIButton) {
        SmilesLocationRouter.shared.pushConfirmUserLocationVC(selectedCity: nil) { location in
            
        }
    }
    @IBAction func didTabConfirmLocation(_ sender: UIButton) {
        if let address = selectedAddress, let lat = Double(address.latitude ?? ""), let long = Double(address.longitude ?? "") {
            SmilesLoader.show(on: self.view)
            self.input.send(.getUserLocation(location: CLLocation(latitude:lat , longitude: long)))
        }
    }
}


// MARK: - UITableView Delegate & DataSource -
extension UpdateLocationViewController: UITableViewDelegate, UITableViewDataSource, SmilesUpdateLocationTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UpdateLocationCell", for: indexPath) as? UpdateLocationCell else { return UITableViewCell() }
        cell.editButton.isHidden = !isEditingEnabled
        cell.mainViewLeading.constant = isEditingEnabled ? 48 : 16
        cell.delegate = self
        cell.configureCell(with: addressDataSource[indexPath.row])
        cell.selectionStyle = .none
        if (selectedIndex == indexPath.row) {
            cell.mainView.borderColor = .appRevampPurpleMainColor
            cell.forwardButton.setImage(UIImage(named: "checked_address_radio", in: .module, with: nil), for: .normal)
        } else {
            cell.forwardButton.setImage(UIImage(named: "unchecked_address_radio", in: .module, with: nil), for: .normal)
            cell.mainView.borderColor = UIColor(red: 66/255, green: 76/255, blue: 152/255, alpha: 0.2)
        }
        return cell
    }
    
    func didTapDeleteButtonInCell(_ cell: UpdateLocationCell) {
        // Handle the action here based on the cell's action
        if let indexPath = self.addressesTableView.indexPath(for: cell) {
            let item = self.addressDataSource[indexPath.row]
            let message = "\("btn_delete".localizedString) \(item.nickname ?? "") \("ResturantAddress".localizedString)"
            if let vc =  SmilesLocationConfigurator.create(type: .createDetectLocationPopup(DetectLocationPopupViewModelFactory.createViewModel(for: .deleteWorkAddress(message: message)))) as? SmilesLocationDetectViewController {
                vc.setDetectLocationAction {
                    self.addressDataSource.remove(at: indexPath.row)
                    SmilesLoader.show(on: self.view)
                    self.input.send(.removeAddress(address_id: (item.addressId ?? "")))
                }
                self.present(vc, animated: true)
            }
            // Perform actions based on indexPath
        }
    }
    func didTapDetailButtonInCell(_ cell: UpdateLocationCell) {
        if let indexPath = self.addressesTableView.indexPath(for: cell) {
            self.currentLocationRadioButton.setImage(UIImage(named: "unchecked_address_radio", in: .module, compatibleWith: nil), for: .normal)
            self.confirmLocationButton.isUserInteractionEnabled = true
            self.confirmLocationButton.backgroundColor = .appRevampPurpleMainColor.withAlphaComponent(1.0)
            self.selectedAddress = self.addressDataSource[indexPath.row]
            self.selectedIndex = indexPath.row
            self.addressesTableView.reloadData()
        }
    }
    
}

// MARK: - ViewModel Binding
extension UpdateLocationViewController {
    
    func bind(to viewModel: ManageAddressViewModel) {
        input = PassthroughSubject<ManageAddressViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .fetchAllAddressDidSucceed(let response):
                    SmilesLoader.dismiss(from: self?.view ?? UIView())
                    debugPrint(response)
                    if let address = response.addresses {
                        self?.addressDataSource = address
                        self?.addressesTableView.reloadData()
                    }
                case .fetchAllAddressDidFail(error: let error):
                    SmilesLoader.dismiss(from: self?.view ?? UIView())
                    debugPrint(error?.localizedDescription ?? "")
                case .removeAddressDidSucceed(response: let response):
                    debugPrint(response)
                    let model = ToastModel()
                    model.title = "address_has_been_deleted".localizedString
                    model.imageIcon = UIImage(named: "green_tic_icon", in: .module, with: nil)
                    self?.showToast(model: model)
                    self?.input.send(.getAllAddress)
                case .removeAddressDidFail(error: _):
                    self?.input.send(.getAllAddress)
                    break
                case .saveDefaultAddressDidSucceed(response: let response):
                    SmilesLoader.dismiss(from: self?.view ?? UIView())
                    debugPrint(response)
                case .saveDefaultAddressDidFail(error: let error):
                    SmilesLoader.dismiss(from: self?.view ?? UIView())
                    debugPrint(error?.localizedDescription ?? "")
                case .getUserLocationDidSucceed(response: let response, location: _):
                    SmilesLoader.dismiss(from: self?.view ?? UIView())
                    if let userInfo = response.userInfo {
                        LocationStateSaver.saveLocationInfo(userInfo, isFromMamba: false)
                        self?.delegate?.locationUpdatedSuccessfully()
                    }
                case .getUserLocationDidFail(error: let error):
                    SmilesLoader.dismiss(from: self?.view ?? UIView())
                    debugPrint(error)
                }
            }.store(in: &cancellables)
    }
}
