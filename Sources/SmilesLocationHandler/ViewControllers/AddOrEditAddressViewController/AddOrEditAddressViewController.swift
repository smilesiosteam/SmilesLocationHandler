//
//  AddOrEditAddressViewController.swift
//
//
//  Created by Ghullam  Abbas on 20/11/2023.
//

import UIKit
import SmilesLanguageManager
import SmilesFontsManager
import SmilesUtilities
import Combine
import CoreLocation
import SmilesLoader

class AddOrEditAddressViewController: UIViewController, SmilesPresentableMessage {
    
    // MARK: - IBOutlets
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet var buildingTextFieldContainer: UIView!
    @IBOutlet var landmarkTextFieldContainer: UIView!
    @IBOutlet var streetTextFieldContainer: UIView!
    @IBOutlet var flatNoTextFieldContainer: UIView!
    @IBOutlet var textFieldCollection: [UITextField]!
    @IBOutlet var addressLabel: UILabel! {
        didSet {
            addressLabel.fontTextStyle = .smilesTitle2
            addressLabel.textColor = .black.withAlphaComponent(0.7)
        }
    }
    @IBOutlet var flatNoTextField: UITextField!
    @IBOutlet var nickNameCollectionView: UICollectionView!
    @IBOutlet var landmarkTextField: UITextField!
    @IBOutlet var streetTextField: UITextField!
    @IBOutlet var buildingNameTextField: UITextField!
    @IBOutlet var nickNameTextField: UITextField!
    @IBOutlet var nickNameView: UIView!
    @IBOutlet var saveButton: UICustomButton!
    @IBOutlet var deliveryToLabel: UILabel! {
        didSet {
            deliveryToLabel.textColor = .black.withAlphaComponent(0.8)
            deliveryToLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var villaFlatNoLabel: UILabel! {
        didSet {
            villaFlatNoLabel.textColor = .black.withAlphaComponent(0.7)
            villaFlatNoLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var buildingNameLabel: UILabel! {
        didSet {
            buildingNameLabel.textColor = .black.withAlphaComponent(0.7)
            buildingNameLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var areaStreetLabel: UILabel! {
        didSet {
            areaStreetLabel.textColor = .black.withAlphaComponent(0.7)
            areaStreetLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var landmarkLabel: UILabel! {
        didSet {
            landmarkLabel.textColor = .black.withAlphaComponent(0.7)
            landmarkLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var nickNameLabel: UILabel! {
        didSet {
            nickNameLabel.textColor = .black.withAlphaComponent(0.7)
            nickNameLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var enterNicknameLabel: UILabel! {
        didSet {
            enterNicknameLabel.textColor = .black.withAlphaComponent(0.7)
            enterNicknameLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var addressScrollView: UIScrollView!
    @IBOutlet var nickNameTextFieldContainer: UIView!
    @IBOutlet var invalidFlatNumberLabel: UILabel! {
        didSet {
            invalidFlatNumberLabel.textColor = .appRedColor3
            invalidFlatNumberLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var invalidBuildingNameLabel: UILabel! {
        didSet {
            invalidBuildingNameLabel.textColor = .appRedColor3
            invalidBuildingNameLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var invalidStreetLabel: UILabel! {
        didSet {
            invalidStreetLabel.textColor = .appRedColor3
            invalidStreetLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var invalidLandmarkLabel: UILabel! {
        didSet {
            invalidLandmarkLabel.textColor = .appRedColor3
            invalidLandmarkLabel.fontTextStyle = .smilesTitle2
        }
    }
    
    // MARK: - Properties
    var selectedLocation: SearchLocationResponseModel?
    var isShortFormEnabled = true
    var nickNamesArray = [Nicknames]()
    
    var selectedNickName: String?
    var otherNickNameSelected = false
    var addressObj: Address?
    var flatNumberValid: Bool = false
    var landMarkValid: Bool = false
    var streetNameValid: Bool = false
    var buildNameValid: Bool = false
    var isChangeButtonHidden = false
    
    private var  input: PassthroughSubject<AddOrEditAddressViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private lazy var viewModel: AddOrEditAddressViewModel = {
        return AddOrEditAddressViewModel()
    }()
    private weak var delegate: ConfirmLocationDelegate?
    private weak var updateLocationDelegate: UpdateUserLocationDelegate?
    
    // MARK: - Methods
    init(addressObj: Address?, selectedLocation: SearchLocationResponseModel?, delegate: ConfirmLocationDelegate?, updateLocationDelegate: UpdateUserLocationDelegate?) {
        self.addressObj = addressObj
        self.selectedLocation = selectedLocation
        self.delegate = delegate
        self.updateLocationDelegate = updateLocationDelegate
        super.init(nibName: "AddOrEditAddressViewController", bundle: .module)
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
        locationNavBarTitle.text = "Enter address details".localizedString
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
    
    @objc func onClickBack() {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bind(to: viewModel)
        setupCollectionView()
        setUpViewUI()
        SmilesLoader.show()
        self.input.send(.getLocationsNickName)
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpNavigationBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    // MARK: - helper methods
    private func setupCollectionView() {
        nickNameCollectionView.register(nib: UINib(nibName: "AddressNicknameCollectionViewCell", bundle: .module), forCellWithClass: AddressNicknameCollectionViewCell.self)
        self.nickNameCollectionView.delegate = self
        self.nickNameCollectionView.dataSource = self
    }
    func setUpViewUI() {
        invalidFlatNumberLabel.isHidden = true
        invalidBuildingNameLabel.isHidden = true
        invalidStreetLabel.isHidden = true
        invalidLandmarkLabel.isHidden = true
        saveButtonApperence(isValid: false)
        
        flatNoTextFieldContainer.layer.borderWidth = 0
        buildingTextFieldContainer.layer.borderWidth = 0
        streetTextFieldContainer.layer.borderWidth = 0
        landmarkTextFieldContainer.layer.borderWidth = 0
        
        btnChange.isHidden = isChangeButtonHidden
        btnChange.setTitle("change".localizedString.capitalizingFirstLetter(), for: .normal)
        btnChange.fontTextStyle = .smilesTitle2
        nickNameView.isHidden = true
        for txtField in textFieldCollection {
            txtField.fontTextStyle = .smilesHeadline4
            txtField.textColor = .black
            txtField.placeHolderTextColor = .placeholderTextFiedColor
            txtField.delegate = self
            txtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            if let clearButton = txtField.value(forKeyPath: "_clearButton") as? UIButton {
                clearButton.setImage(UIImage(named:"button_icon_only_dismiss_gray"), for: .normal)
                clearButton.setImage(UIImage(named:"button_icon_only_dismiss_gray"), for: .highlighted)
            }
            txtField.textAlignment  = AppCommonMethods.languageIsArabic() ? .right : .left
        }
        
        // self.input.send(.getLocationName(lat: String(selectedLocation?.lat ?? 0.0) , long: String(selectedLocation?.long ?? 0.0)))
        if let title = selectedLocation?.title {
            self.addressLabel.text = title
        }
        
        if updateLocationDelegate != nil {
            self.addressLabel.text = addressObj?.locationName
        }
        
        deliveryToLabel.text = "deliver_address".localizedString
        villaFlatNoLabel.text = "VillaFlatno".localizedString
        flatNoTextField.placeholder = "EnterTitle".localizedString.capitalizingFirstLetter()
        buildingNameLabel.text = "VillaBuildingName".localizedString
        buildingNameTextField.placeholder = "EnterTitle".localizedString.capitalizingFirstLetter()
        areaStreetLabel.text = "AreaStreetName".localizedString
        streetTextField.placeholder = "EnterTitle".localizedString.capitalizingFirstLetter()
        landmarkLabel.text = "nearby_landmark_optional".localizedString
        landmarkTextField.placeholder = "EnterTitle".localizedString.capitalizingFirstLetter()
        nickNameLabel.text = "save_address_as".localizedString
        enterNicknameLabel.text = "nick_name_define_others".localizedString
        nickNameTextField.placeholder = "EnterTitle".localizedString.capitalizingFirstLetter()
        saveButton.setTitle("Save address".localizedString, for: .normal)
        
        invalidFlatNumberLabel.text = "\("InvalidText".localizedString) \("VillaFlatno".localizedString)"
        invalidBuildingNameLabel.text = "\("InvalidText".localizedString) \("VillaBuildingName".localizedString)"
        invalidStreetLabel.text = "\("InvalidText".localizedString) \("AreaStreetName".localizedString)"
        
        nickNameCollectionView.transform = .identity
        if AppCommonMethods.languageIsArabic() {
            nickNameCollectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
            nickNameCollectionView.semanticContentAttribute = .forceRightToLeft
        } else {
            nickNameCollectionView.semanticContentAttribute = .forceLeftToRight
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    func saveButtonApperence(isValid: Bool) {
        
        saveButton.isEnabled = isValid
        if (isValid) {
            saveButton.backgroundColor = .appRevampPurpleMainColor
            saveButton.setTitleColor(.white, for: .normal)
        } else {
            saveButton.backgroundColor =  .black.withAlphaComponent(0.1)
            saveButton.setTitleColor(.black.withAlphaComponent(0.5), for: .normal)
        }
        
    }
    
    func setTextFieldActiveBorderColor(view: UIView) {
        view.layer.borderWidth = 1
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
    }
    
    func setTextFieldBorderColorRed(view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appRedColor.cgColor
    }
    
    func setTextFieldBorderColorClear(view: UIView) {
        
        view.layer.borderWidth = 0
        view.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
    }
    // MARK: - IBActions
    @IBAction func changeButtonClicked(_ sender : Any) {
        
        if let controllers = navigationController?.viewControllers, controllers[safe: controllers.count - 2] is ConfirmUserLocationViewController {
            SmilesLocationRouter.shared.popVC()
        } else {
            let model = GetCitiesModel()
            if let object = self.addressObj {
                model.cityLatitude = Double(object.latitude ?? "")
                model.cityLongitude = Double(object.longitude ?? "")
            } else if let lat = selectedLocation?.lat, let long = selectedLocation?.long {
                model.cityLatitude = lat
                model.cityLongitude = long
            }
            SmilesLocationRouter.shared.pushConfirmUserLocationVC(selectedCity: model,sourceScreen: .editAddressViewController, delegate: self)
        }
        
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let address = Address()
        if let id = self.addressObj?.addressId {
            address.addressId = id
        } else {
            address.addressId = nil
        }
        
        address.nickname = selectedNickName?.lowercased().contains("other".lowercased()) ?? false ? nickNameTextField.text : selectedNickName
        address.street = streetTextField.text
        address.building = buildingNameTextField.text
        address.flatNo = flatNoTextField.text
        address.landmark = landmarkTextField.text
        
        if let addressob = addressObj {
            address.latitude = addressob.latitude
            address.longitude = addressob.longitude
            address.locationName = addressob.locationName
        } else {
            address.latitude = String(selectedLocation?.lat ?? 0)
            address.longitude = String(selectedLocation?.long ?? 0)
            address.locationName = selectedLocation?.title
        }
        addressObj = address
        SmilesLoader.show()
        self.input.send(.saveAddress(address: address))
        
    }
    
}
// MARK: - ViewModel Binding
extension AddOrEditAddressViewController {
    
    func bind(to viewModel: AddOrEditAddressViewModel) {
        input = PassthroughSubject<AddOrEditAddressViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                guard let self else { return }
                SmilesLoader.dismiss()
                switch event {
                case .fetchLocationsNickNameDidSucceed(let response):
                    self.handleNickNamesResponse(response: response)
                case .fetchLocationsNickNameDidFail(error: let error):
                    if let errorMsg = error?.localizedDescription, !errorMsg.isEmpty {
                        self.showMessage(model: SmilesMessageModel(description: errorMsg))
                    }
                case .fetchLocationNameDidSucceed(response: let response):
                    self.updateLocationName(place: response)
                case .fetchLocationNameDidFail(let error):
                    if let errorMsg = error?.localizedDescription, !errorMsg.isEmpty {
                        self.showMessage(model: SmilesMessageModel(description: errorMsg))
                    }
                case .saveAddressDidSucceed(let response):
                    self.handleSaveAddressResponse(response: response)
                case .saveAddressDidFail(error: let error):
                    if let errorMsg = error?.localizedDescription, !errorMsg.isEmpty {
                        self.showMessage(model: SmilesMessageModel(description: errorMsg))
                    }
                case .getUserLocationDidSucceed(response: let response, location: _):
                    self.handleUserLocationResponse(response: response)
                case .getUserLocationDidFail(error: let error):
                    if !error.localizedDescription.isEmpty {
                        self.showMessage(model: SmilesMessageModel(description: error.localizedDescription))
                    }
                }
            }.store(in: &cancellables)
    }
}

// MARK: - RESPONSE HANDLING -
extension AddOrEditAddressViewController {
    
    private func handleNickNamesResponse(response: SaveAddressResponseModel) {
        
        if let errorMessage = response.responseMsg, !errorMessage.isEmpty {
            self.showMessage(model: SmilesMessageModel(title: response.errorTitle, description: errorMessage, showForRetry: true), delegate: self)
        } else if let nickNamesArray = response.addressDetail?.nicknames {
            self.nickNamesResponse(nickNames: nickNamesArray)
        }
        
    }
    
    private func handleSaveAddressResponse(response: SaveAddressResponseModel) {
        
        if let errorMessage = response.responseMsg, !errorMessage.isEmpty {
            self.showMessage(model: SmilesMessageModel(title: response.errorTitle, description: errorMessage))
        } else {
            if updateLocationDelegate != nil {
                if let latitudeString = self.addressObj?.latitude, let longitudeString = self.addressObj?.longitude,
                   let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
                    SmilesLoader.show()
                    self.input.send(.getUserLocation(location: CLLocation(latitude: latitude, longitude: longitude)))
                }
            } else {
                self.redirectUserAfterConfirmLocation()
            }
        }
        
    }
    
    private func handleUserLocationResponse(response: RegisterLocationResponse) {
        
        if let errorMessage = response.responseMsg, !errorMessage.isEmpty {
            self.showMessage(model: SmilesMessageModel(title: response.errorTitle, description: errorMessage))
        } else if let userInfo = response.userInfo {
            LocationStateSaver.saveLocationInfo(userInfo, isFromMamba: false)
            SmilesLocationRouter.shared.popVC()
            self.updateLocationDelegate?.userLocationUpdatedSuccessfully()
        }
        
    }
    
}

// MARK: - SMILES ERROR VIEW DELEGATE -
extension AddOrEditAddressViewController: SmilesMessageViewDelegate {
    
    func primaryButtonPressed() {
        SmilesLoader.show()
        self.input.send(.getLocationsNickName)
    }
    
}


// MARK: - UICollectionView Delegate & DataSource
extension AddOrEditAddressViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nickNamesArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withClass: AddressNicknameCollectionViewCell.self, for: indexPath)
        
        let nickNameObject = nickNamesArray[indexPath.item]
        cell.containerView.layer.borderWidth = 1
        if nickNameObject.isSelected.asBoolOrFalse() {
            
            cell.containerView.backgroundColor = UIColor(red: 66/255, green: 76/255, blue: 152/255, alpha: 0.2)
            selectedNickName = nickNameObject.nickname
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
            nickNameView.isHidden = false
        } else {
            cell.containerView.backgroundColor = UIColor(hex: "ffffff")
            collectionView.deselectItem(at: indexPath, animated: true)
            nickNameView.isHidden = true
        }
        cell.containerView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        cell.configureCellWithData(nickName: nickNameObject)
        isValid()
        
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 89.0, height: 40.0)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nickName = nickNamesArray[indexPath.row]
        selectedNickName = nickName.nickname
        for (index, element) in nickNamesArray.enumerated() {
            if index == indexPath.row {
                element.isSelected = true
            } else {
                element.isSelected = false
            }
        }
        
        if indexPath.row == nickNamesArray.count - 1 {
            nickNameView.isHidden = false
            otherNickNameSelected = true
            addressScrollView.scrollToPosition(animated: true, position: .bottom)
        } else {
            nickNameView.isHidden = true
            otherNickNameSelected = false
            addressScrollView.scrollToPosition(animated: true, position: .top)
        }
        nickNameCollectionView.reloadData {
            self.isValid()
        }
    }
}
// MARK: - UITextFiles Delegate & DataSource
extension AddOrEditAddressViewController:  UITextFieldDelegate {
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == flatNoTextField {
            if (textField.text?.isEmpty ?? false) {
                setTextFieldBorderColorClear(view: flatNoTextFieldContainer)
            }
            
        }
        
        if textField == buildingNameTextField {
            if (textField.text?.isEmpty ?? false) {
                setTextFieldBorderColorClear(view: buildingTextFieldContainer)
            }
            
        }
        
        if textField == streetTextField {
            if (textField.text?.isEmpty ?? false) {
                setTextFieldBorderColorClear(view: streetTextFieldContainer)
            }
            
        }
        
        if textField == landmarkTextField {
            if (textField.text?.isEmpty ?? false) {
                setTextFieldBorderColorClear(view: landmarkTextFieldContainer)
            }
            
        }
        
        if textField == nickNameTextField {
            if (textField.text?.isEmpty ?? false) {
                setTextFieldBorderColorClear(view: nickNameTextFieldContainer)
            }
            
            addressScrollView.scrollToPosition(extraScroll: 0, animated: true, position: .bottom)
        }
        
        isValid()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nickNameTextField {
            setTextFieldActiveBorderColor(view: nickNameTextFieldContainer)
            
        } else if textField == flatNoTextField {
            setTextFieldActiveBorderColor(view: flatNoTextFieldContainer)
            flatNumberValid = self.checkTextFieldValid(textField: textField, view: flatNoTextFieldContainer, label: invalidFlatNumberLabel)
            
        } else if textField == buildingNameTextField {
            setTextFieldActiveBorderColor(view: buildingTextFieldContainer)
            buildNameValid = self.checkTextFieldValid(textField: textField, view: buildingTextFieldContainer, label: invalidBuildingNameLabel)
            
            
        } else if textField == streetTextField {
            setTextFieldActiveBorderColor(view: streetTextFieldContainer)
            streetNameValid = self.checkTextFieldValid(textField: textField, view: streetTextFieldContainer, label: invalidStreetLabel)
            
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField == flatNoTextField {
            flatNumberValid = self.checkTextFieldValid(textField: textField, view: flatNoTextFieldContainer, label: invalidFlatNumberLabel)
            
        } else if textField == buildingNameTextField {
            buildNameValid = self.checkTextFieldValid(textField: textField, view: buildingTextFieldContainer, label: invalidBuildingNameLabel)
            
            
        } else if textField == streetTextField {
            streetNameValid = self.checkTextFieldValid(textField: textField, view: streetTextFieldContainer, label: invalidStreetLabel)
            
        }
        //        else if textField == landmarkTextField {
        //            landMarkValid = self.checkTextFieldValid(textField: textField, view: landmarkTextFieldContainer, label: invalidLandmarkLabel)
        //
        //        }
    }
    
    func isValid() {
        var isValid = false
        isValid = (flatNumberValid && buildNameValid && streetNameValid)
        
        if isValid {
            if otherNickNameSelected {
                if nickNameTextField.text?.count ?? 0 > 0 {
                    isValid = true
                    saveButtonApperence(isValid: isValid)
                } else {
                    isValid = false
                    saveButtonApperence(isValid: isValid)
                }
            } else {
                isValid = true
                saveButtonApperence(isValid: isValid)
            }
        } else {
            saveButtonApperence(isValid: isValid)
        }
    }
    func checkTextFieldValid(textField: UITextField, view: UIView, label: UILabel) -> Bool {
        if textField.text?.count ?? 0 > 0, !hasSpecialCharacters(firstLetter: textField.text ?? "@") {
            label.isHidden = true
            if !(textField.text?.isEmpty ?? false) {
                self.setTextFieldActiveBorderColor(view: view)
                return true
            } else {
                self.setTextFieldActiveBorderColor(view: view)
                return false
            }
            
        } else {
            if textField.text?.isEmpty ?? false {
                //                setTextFieldBorderColorGreen(view: flatNoTextFieldContainer)
                label.isHidden = true
                return false
            } else {
                self.setTextFieldBorderColorRed(view: view)
                label.isHidden = false
                return false
            }
        }
    }
    
    func hasSpecialCharacters(firstLetter: String) -> Bool {
        do {
            let regexText = ".*[^A-Za-z0-9ء-ي٠-٩].*"
            let regex = try NSRegularExpression(pattern: regexText, options: .caseInsensitive)
            if let _ = regex.firstMatch(in: firstLetter, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, 1)) {
                return true
            }
            
        } catch {
            debugPrint(error.localizedDescription)
            return false
        }
        
        return false
    }
}

extension AddOrEditAddressViewController {
    
    func redirectUserAfterConfirmLocation() {
        
        guard let controllers = navigationController?.viewControllers else { return }
        if controllers[safe: controllers.count - 2] is SmilesManageAddressesViewController {
            SmilesLocationRouter.shared.popVC()
        } else {
            if let updateLocationVC = controllers.last(where: { $0 is UpdateLocationViewController }) {
                if let latitudeString = addressObj?.latitude, let longitudeString = addressObj?.longitude, let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
                    delegate?.newAddressAdded(location: CLLocation(latitude: latitude, longitude: longitude))
                }
                self.navigationController?.popToViewController(updateLocationVC, animated: true)
            }
        }
        
    }
    
    func nickNamesResponse(nickNames: [Nicknames]) {
        
        if let address = addressObj, address.nicknames != nil {
            setViewForEdit(address: address)
        } else {
            nickNamesArray = nickNames
            self.nickNameCollectionView.reloadData()
        }
        saveButton.isUserInteractionEnabled = true
        
    }
    
    func setViewForEdit(address: Address) {
        
        flatNoTextField.text = address.flatNo
        buildingNameTextField.text = address.building
        streetTextField.text = address.street
        landmarkTextField.text = address.landmark
        
        let flatNo = address.flatNo.asStringOrEmpty()
        let building = address.building.asStringOrEmpty()
        let street = address.street.asStringOrEmpty()
        let locationName = address.locationName.asStringOrEmpty()
        
        self.addressLabel.text =  createAddressString(flatNo: flatNo, building: building, street: street, locationName: locationName)
        
        flatNumberValid = !(flatNoTextField.text?.isEmpty ?? false)
        buildNameValid = !(buildingNameTextField.text?.isEmpty ?? false)
        streetNameValid = !(streetTextField.text?.isEmpty ?? false)
        setTextFieldActiveBorderColor(view: flatNoTextFieldContainer)
        setTextFieldActiveBorderColor(view: buildingTextFieldContainer)
        setTextFieldActiveBorderColor(view: streetTextFieldContainer)
        setTextFieldActiveBorderColor(view: landmarkTextFieldContainer)
        
        address.nicknames?.forEach { nickName in
            if address.nickname?.lowercased() == nickName.nickname?.lowercased() {
                self.nickNameTextField.text = address.nickname
                setTextFieldActiveBorderColor(view: nickNameTextFieldContainer)
            } else {
                self.nickNameTextField.text = nickName.otherNickname ?? ""
                setTextFieldActiveBorderColor(view: nickNameTextFieldContainer)
            }
        }
        nickNamesArray = address.nicknames ?? []
        self.nickNameCollectionView.reloadData()
    }
    
    func updateLocationName(place: String) {
        addressLabel.text = place
        addressObj?.locationName = place
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
    
}


// MARK: - Call Back from confirm Location
extension AddOrEditAddressViewController {
    func getNewAddressLocation(location: SearchLocationResponseModel?) {
        
        if let addressloc = location?.title {
            addressLabel.text = addressloc
            
            //                let addressObj = Address()
            //                addressObj.latitude =  "\(location?.lat ?? 0)"
            //                addressObj.longitude = "\(location?.long ?? 0)"
            //                self.addressObj = addressObj
            //                self.input.send(.getLocationName(lat: String(addressObj.latitude ?? ""), long: String(addressObj.longitude ?? "")))
        }
    }
}


extension AddOrEditAddressViewController: ConfirmLocationDelegate {
    
    func locationPicked(location: SearchLocationResponseModel) {
        
        self.addressLabel.text = location.title
        if addressObj != nil {
            self.addressObj?.latitude =  "\(location.lat ?? 0)"
            self.addressObj?.longitude = "\(location.long ?? 0)"
        } else {
            let addressObj = Address()
            addressObj.latitude =  "\(location.lat ?? 0)"
            addressObj.longitude = "\(location.long ?? 0)"
            self.addressObj = addressObj
        }
        
    }
    
}
