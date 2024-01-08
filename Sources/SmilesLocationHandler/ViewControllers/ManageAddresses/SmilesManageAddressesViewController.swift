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

final class SmilesManageAddressesViewController: UIViewController, Toastable, SmilesPresentableMessage {
    
    // MARK: - IBOutlets
    @IBOutlet weak var addressesTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var savedAddressedLabel: UILabel!
    
    // MARK: - Properties
    var isEditingEnabled: Bool = false
    var addressDataSource = [Address]()
    private var  input: PassthroughSubject<ManageAddressViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private lazy var viewModel: ManageAddressViewModel = {
        return ManageAddressViewModel()
    }()
    private var deletedAddress: Address?
    private weak var delegate: UpdateUserLocationDelegate?
    private var isLocationPermissionsEnabled = false
    
    // MARK: - Methods
    init(delegate: UpdateUserLocationDelegate? = nil) {
        self.delegate = delegate
        super.init(nibName: "SmilesManageAddressesViewController", bundle: .module)
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
        locationNavBarTitle.text = "Manage addresses".localizedString
        locationNavBarTitle.textColor = .black
        locationNavBarTitle.fontTextStyle = .smilesHeadline4
        
        locationNavBarTitle.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        
        self.navigationItem.titleView = locationNavBarTitle
        /// Back Button Show
        let backButton: UIButton = UIButton(type: .custom)
        // btnBack.backgroundColor = UIColor(red: 226.0 / 255.0, green: 226.0 / 255.0, blue: 226.0 / 255.0, alpha: 1.0)
        let image = UIImage(named: AppCommonMethods.languageIsArabic() ? "BackArrow_black_Ar" : "BackArrow_black")?.withRenderingMode(.alwaysTemplate).withTintColor(.black)
        
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
        self.editButton.fontTextStyle = .smilesHeadline4
        
        self.savedAddressedLabel.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        
    }
    private func updateUI() {
        self.editButton.isHidden = true
        self.savedAddressedLabel.text = "SavedAddresses".localizedString
        self.editButton.setTitle("btn_edit".localizedString.capitalizingFirstLetter(), for: .normal)
    }
    func setupTableViewCells() {
        addressesTableView.registerCellFromNib(AddressDetailsTableViewCell.self, withIdentifier: String(describing: AddressDetailsTableViewCell.self), bundle: .module)
    }
    @objc func onClickBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func showToastForDeletedAddress() {
        
        addressDataSource.removeAll { address in
            address.addressId == deletedAddress?.addressId
        }
        addressesTableView.reloadData()
        if addressDataSource.count == 1 {
            editButton.isHidden = !isDeleteFunctionalityRequired(for: addressDataSource.first!)
        }
        if addressDataSource.isEmpty {
            editButton.isHidden = true
            savedAddressedLabel.isHidden = true
        }
        let model = ToastModel()
        model.title = "address_has_been_deleted".localizedString
        model.imageIcon = UIImage(named: "green_tic_icon", in: .module, with: nil)
        self.showToast(model: model,atPosition: .bottom)
        
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
        LocationManager.shared.isLocationEnabled() { [weak self] isEnabled in
            self?.isLocationPermissionsEnabled = isEnabled
        }
        setUpNavigationBar()
        updateUI()
        SmilesLoader.show()
        self.input.send(.getAllAddress)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
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
}

// MARK: - UITableView Delegate & DataSource -
extension SmilesManageAddressesViewController: UITableViewDelegate, UITableViewDataSource, AddressDetailsTbaleViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddressDetailsTableViewCell", for: indexPath) as? AddressDetailsTableViewCell else { return UITableViewCell() }
        let address = addressDataSource[indexPath.row]
        cell.delegate = self
        cell.configureCell(with: address, isFromManageAddress: true, isEditingEnabled: isEditingEnabled, isDeleteEnabled: isDeleteFunctionalityRequired(for: address))
        return cell
    }
    func createAddressString(flatNo: String?, building: String?, street: String?, locationName: String?) -> String {
        let components = [flatNo, building, street, locationName]
        var addressString = ""

        for component in components {
            if let comp = component, !comp.isEmpty {
                addressString += "\(comp), "
            }
        }

        // Remove trailing comma and space if present
        if addressString.hasSuffix(", ") {
            addressString.removeLast(2)
        }

        return addressString
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func didTapDeleteButtonInCell(_ cell: AddressDetailsTableViewCell) {
        // Handle the action here based on the cell's action
        if let indexPath = self.addressesTableView.indexPath(for: cell) {
             let item = self.addressDataSource[indexPath.row]
            let message = "\("btn_delete".localizedString) \(item.nickname ?? "") \("ResturantAddress".localizedString)"
            if let vc =  SmilesLocationConfigurator.create(type: .createDetectLocationPopup(controllerType: .deleteWorkAddress(message: message))) as? SmilesLocationDetectViewController {
                vc.deletePressed = { [weak self] in
                    guard let self else { return }
                    SmilesLoader.show()
                    self.deletedAddress = item
                    self.input.send(.removeAddress(address_id: (item.addressId ?? "")))
                }
                self.present(vc, animated: true)
            }
            // Perform actions based on indexPath
        }
    }
    
    func didTapDetailButtonInCell(_ cell: AddressDetailsTableViewCell) {

        if !isEditingEnabled {
            if let indexPath = self.addressesTableView.indexPath(for: cell) {
                 let item = self.addressDataSource[indexPath.row]
                // Perform actions based on indexPath
                if let navigationController = self.navigationController {
                    SmilesLocationRouter.shared.pushAddOrEditAddressViewController(with: navigationController, addressObject: item, delegate: nil, updateLocationDelegate: isDefaultAddressSelected(address: item) ? delegate : nil)
                }
            }
        }
        
    }
    
    private func isDefaultAddressSelected(address: Address) -> Bool {
        
        if address.latitude == LocationStateSaver.getLocationInfo()?.latitude,
           address.longitude == LocationStateSaver.getLocationInfo()?.longitude {
           return true
        }
        return false
        
    }
    
}

// MARK: - ViewModel Binding
extension SmilesManageAddressesViewController {
    
    func bind(to viewModel: ManageAddressViewModel) {
        input = PassthroughSubject<ManageAddressViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                guard let self else { return }
                switch event {
                case .fetchAllAddressDidSucceed(let response):
                    self.handleAddressListResponse(response: response)
                case .fetchAllAddressDidFail(error: let error):
                    if let errorMsg = error?.localizedDescription, !errorMsg.isEmpty {
                        self.showMessage(model: SmilesMessageModel(description: errorMsg, showForRetry: true), delegate: self)
                    }
                case .removeAddressDidSucceed(let response):
                    self.handleRemoveAddressResponse(response: response)
                case .removeAddressDidFail(let error):
                    if let errorMsg = error?.localizedDescription, !errorMsg.isEmpty {
                        self.showMessage(model: SmilesMessageModel(description: errorMsg))
                    }
                case .getUserLocationDidSucceed(let response, _):
                    self.handleUserLocationResponse(response: response)
                case .getUserLocationDidFail(_):
                    self.handleUserLocationFailedResponse()
                default:
                   break
                }
            }.store(in: &cancellables)
    }
}

// MARK: - RESPONSE HANDLING -
extension SmilesManageAddressesViewController {
    
    private func handleAddressListResponse(response: GetAllAddressesResponse) {
        
        SmilesLoader.dismiss()
        if let errorMessage = response.responseMsg, !errorMessage.isEmpty {
            self.showMessage(model: SmilesMessageModel(title: response.errorTitle, description: errorMessage, showForRetry: true), delegate: self)
        } else if let address = response.addresses {
            if address.count == 1 {
                self.editButton.isHidden = !isDeleteFunctionalityRequired(for: address.first!)
            } else {
                self.editButton.isHidden = false
            }
            self.savedAddressedLabel.isHidden = false
            self.addressDataSource = address
            self.addressesTableView.reloadData()
        }
        
    }
    
    private func isDeleteFunctionalityRequired(for address: Address) -> Bool {
        
        if address.selection == 1, LocationStateSaver.getLocationInfo()?.latitude == address.latitude,
           LocationStateSaver.getLocationInfo()?.longitude == address.longitude, !isLocationPermissionsEnabled {
            return false
        }
        return true
        
    }
    
    private func handleRemoveAddressResponse(response: RemoveAddressResponseModel) {
        
        if let errorMessage = response.responseMsg, !errorMessage.isEmpty {
            SmilesLoader.dismiss()
            self.showMessage(model: SmilesMessageModel(title: response.errorTitle, description: errorMessage))
        } else {
            if let deletedAddress, deletedAddress.latitude == LocationStateSaver.getLocationInfo()?.latitude, deletedAddress.longitude == LocationStateSaver.getLocationInfo()?.longitude {
                if isLocationPermissionsEnabled {
                    LocationManager.shared.getLocation { [weak self] location, error in
                        self?.input.send(.getUserLocation(location: location))
                    }
                } else {
                    self.input.send(.getUserLocation(location: nil))
                }
            } else {
                SmilesLoader.dismiss()
                showToastForDeletedAddress()
            }
        }
        
    }
    
    private func handleUserLocationResponse(response: RegisterLocationResponse) {
        
        SmilesLoader.dismiss()
        if let userInfo = response.userInfo {
            LocationStateSaver.saveLocationInfo(userInfo, isFromMamba: false)
            showToastForDeletedAddress()
        } else {
            handleUserLocationFailedResponse()
        }
        delegate?.defaultAddressDeleted()
        
    }
    
    private func handleUserLocationFailedResponse() {
        
        SmilesLoader.dismiss()
        LocationStateSaver.removeLocation()
        showToastForDeletedAddress()
        
    }
    
}

// MARK: - SMILES ERROR VIEW DELEGATE -
extension SmilesManageAddressesViewController: SmilesMessageViewDelegate {
    
    func primaryButtonPressed(isForRetry: Bool) {
        if isForRetry {
            SmilesLoader.show()
            self.input.send(.getAllAddress)
        }
    }
    
}
