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

final class AddOrEditAddressViewController: UIViewController {
    
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
    @IBOutlet var deliveryToLabel: UILabel!{
        didSet {
            deliveryToLabel.textColor = .black.withAlphaComponent(0.7)
            deliveryToLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var villaFlatNoLabel: UILabel! {
        didSet {
            villaFlatNoLabel.textColor = .black.withAlphaComponent(0.7)
            villaFlatNoLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var buildingNameLabel: UILabel!{
        didSet {
            buildingNameLabel.textColor = .black.withAlphaComponent(0.7)
            buildingNameLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var areaStreetLabel: UILabel!{
        didSet {
            areaStreetLabel.textColor = .black.withAlphaComponent(0.7)
            areaStreetLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var landmarkLabel: UILabel!{
        didSet {
            landmarkLabel.textColor = .black.withAlphaComponent(0.7)
            landmarkLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var nickNameLabel: UILabel!{
        didSet {
            nickNameLabel.textColor = .black.withAlphaComponent(0.7)
            nickNameLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var enterNicknameLabel: UILabel!{
        didSet {
            enterNicknameLabel.textColor = .black.withAlphaComponent(0.7)
            enterNicknameLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var addressScrollView: UIScrollView!
    @IBOutlet var nickNameTextFieldContainer: UIView!
    @IBOutlet var invalidFlatNumberLabel: UILabel!{
        didSet {
            invalidFlatNumberLabel.textColor = .appRedColor3
            invalidFlatNumberLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var invalidBuildingNameLabel: UILabel!{
        didSet {
            invalidBuildingNameLabel.textColor = .appRedColor3
            invalidBuildingNameLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var invalidStreetLabel: UILabel!{
        didSet {
            invalidStreetLabel.textColor = .appRedColor3
            invalidStreetLabel.fontTextStyle = .smilesTitle2
        }
    }
    @IBOutlet var invalidLandmarkLabel: UILabel!{
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
    
    // MARK: - Methods
    init() {
        super.init(nibName: "AddOrEditAddressViewController", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setUpNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        let appearance = UINavigationBarAppearance()
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
        setupCollectionView()
        setUpViewUI()
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
        nickNameCollectionView.delegate = self
        nickNameCollectionView.dataSource = self
        
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
        //        landmarkTextFieldContainer.layer.borderWidth = 0
        
        btnChange.isHidden = isChangeButtonHidden
        btnChange.setTitle("change".localizedString.capitalizingFirstLetter(), for: .normal)
        
        nickNameView.isHidden = true
        for txtField in textFieldCollection {
            txtField.font = .montserratMediumFont(size: 15)
            txtField.textColor = .appDarkGrayColor
            txtField.placeHolderTextColor = .placeholderTextFiedColor
            txtField.delegate = self
            txtField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
            if let clearButton = txtField.value(forKeyPath: "_clearButton") as? UIButton {
                clearButton.setImage(UIImage(named:"button_icon_only_dismiss_gray"), for: .normal)
                clearButton.setImage(UIImage(named:"button_icon_only_dismiss_gray"), for: .highlighted)
            }
        }
        
       // presenter?.getLocationName(lat: String(selectedLocation?.lat ?? 0.0), long: String(selectedLocation?.long ?? 0.0))
       
        deliveryToLabel.text = "Delivering to".localizedString
        villaFlatNoLabel.text = "VillaFlatno".localizedString
        flatNoTextField.placeholder = "EnterFlatNoText".localizedString
        buildingNameLabel.text = "VillaBuildingName".localizedString
        buildingNameTextField.placeholder = "EnterFlatNameText".localizedString
        areaStreetLabel.text = "AreaStreetName".localizedString
        streetTextField.placeholder = "EnterStreetText".localizedString
        landmarkLabel.text = "Landmark".localizedString
        landmarkTextField.placeholder = "EnterLandmarkText".localizedString
        nickNameLabel.text = "Nickname".localizedString
        enterNicknameLabel.text = "EnterNickname".localizedString
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
        
        // setUpViewForEditAddress()
    }
    
    func setUpViewForEditAddress() {
        if let addressToEdit = addressObj {
          //  presenter?.getLocationName(lat: addressToEdit.latitude ?? "", long: addressToEdit.longitude ?? "")
            //            addressLabel.text = addressToEdit.locationName
            buildingNameTextField.text = addressToEdit.building
            flatNoTextField.text = addressToEdit.flatNo
            streetTextField.text = addressToEdit.street
            landmarkTextField.text = addressToEdit.landmark
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    
    
    func saveButtonApperence(isValid: Bool) {
        //saveButton.setEnabled(isValid)
    }
    
    func setTextFieldBorderColorGreen(view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appGreenSecondaryColor.cgColor
    }
    
    func setTextFieldBorderColorRed(view: UIView) {
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.appRedColor.cgColor
    }
    
    func setTextFieldBorderColorClear(view: UIView) {
        view.layer.borderWidth = 0
    }
    // MARK: - IBActions
    @IBAction func changeButtonClicked(_ sender : Any){
       // presenter?.changeButtonClicked()
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        saveButton.isUserInteractionEnabled = false
        
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
       // presenter?.saveAddress(address: address, withLocation: selectedLocation, openFrom: redirectTo)
    }
}
// MARK: - UICollectionView Delegate & DataSource
extension AddOrEditAddressViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nickNamesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AddressNicknameCollectionViewCell", for: indexPath as IndexPath) as! AddressNicknameCollectionViewCell
        
        let nickName = nickNamesArray[indexPath.row]
        
        cell.containerView.layer.borderWidth = 1
        if nickName.isSelected.asBoolOrFalse() {
            cell.containerView.backgroundColor = UIColor(hex: "8754a1")
            cell.titleLabel.textColor = UIColor(hex: "ffffff")
            cell.containerView.layer.borderColor = UIColor(hex: "8754a1").cgColor
            selectedNickName = nickName.nickname
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .right)
            nickNameView.isHidden = false
        } else {
            cell.containerView.backgroundColor = UIColor(hex: "ffffff")
            cell.titleLabel.textColor = UIColor(hex: "353738")
            cell.containerView.layer.borderColor = UIColor(hex: "d9d9d9").cgColor
            collectionView.deselectItem(at: indexPath, animated: true)
            nickNameView.isHidden = true
        }
        
        cell.configureCellWithData(nickName: nickName)
        isValid()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let text = nickNamesArray[indexPath.row].nickname ?? ""
        let width = estimatedFrame(text: text, font: .montserratSemiBoldFont(size: 15)).width + 52
        return CGSize(width: width, height: 36.0)
    }
    
    func estimatedFrame(text: String, font: UIFont) -> CGRect {
        let size = CGSize(width: 200, height: 1000) // temporary size
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size,
                                                   options: options,
                                                   attributes: [NSAttributedString.Key.font: font],
                                                   context: nil)
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
            setTextFieldBorderColorClear(view: flatNoTextFieldContainer)
        }
        
        if textField == buildingNameTextField {
            setTextFieldBorderColorClear(view: buildingTextFieldContainer)
        }
        
        if textField == streetTextField {
            setTextFieldBorderColorClear(view: streetTextFieldContainer)
        }
        
        if textField == landmarkTextField {
            setTextFieldBorderColorClear(view: landmarkTextFieldContainer)
        }
        
        if textField == nickNameTextField {
            setTextFieldBorderColorClear(view: nickNameTextFieldContainer)
            addressScrollView.scrollToPosition(extraScroll: 0, animated: true, position: .bottom)
        }
        
        isValid()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nickNameTextField {
            setTextFieldBorderColorGreen(view: nickNameTextFieldContainer)
            
        } else if textField == flatNoTextField {
            setTextFieldBorderColorGreen(view: flatNoTextFieldContainer)
            flatNumberValid = self.checkTextFieldValid(textField: textField, view: flatNoTextFieldContainer, label: invalidFlatNumberLabel)
            
        } else if textField == buildingNameTextField {
            setTextFieldBorderColorGreen(view: buildingTextFieldContainer)
            buildNameValid = self.checkTextFieldValid(textField: textField, view: buildingTextFieldContainer, label: invalidBuildingNameLabel)
            
            
        } else if textField == streetTextField {
            setTextFieldBorderColorGreen(view: streetTextFieldContainer)
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
        //            landMarkValid = presenter!.checkTextFieldValid(textField: textField, view: landmarkTextFieldContainer, label: invalidLandmarkLabel)
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
                self.setTextFieldBorderColorGreen(view: view)
                return true
            } else {
                self.setTextFieldBorderColorGreen(view: view)
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

//    extension EnterAddressDetailViewController: EnterAddressDetailView {
//        func addressSaved(withLocation location: CLLocation) {
//            if let toViewController = redirectTo {
//                if toViewController == .toHome || toViewController == .toEnterAddress {
//                    presenter?.moveToHome(opensFrom: toViewController)
//                } else {
//                    if let controllers = navigationController?.viewControllers {
//                        for controller in controllers {
//                            if toViewController == .toRestaurantDetail {
//                                if controller.isKind(of: RestaurantDetailRevampViewController.self) {
//                                    self.navigationController?.popToViewController(controller, animated: true)
//                                    break
//                                }
//                            } else if toViewController == .toRestaurantDetail {
//                                if controller.isKind(of: RestaurantHomeViewController.self) {
//                                    if let selectedVC = controller as? RestaurantHomeViewController {
//                                        selectedVC.selectedLocation = location
//                                    }
//                                    self.navigationController?.popToViewController(controller, animated: true)
//                                    break
//                                }
//                            } else if toViewController == .toFoodOrder {
//                                if controller.isKind(of: FoodOrderHomeViewController.self) {
//                                    self.navigationController?.popToViewController(controller, animated: true)
//                                    break
//                                }
//                            } else if toViewController == .toFoodCart {
//                                if controller.isKind(of: FoodCartViewController.self) {
//                                    //                        if let selectedVC = controller as? FoodCartViewController {
//                                    //                            //selectedVC.selectedLocation = location
//                                    //                        }
//                                    self.navigationController?.popToViewController(controller, animated: true)
//                                    break
//                                }
//                            }
//                        }
//                    }
//
//                }
//            }
//        }
//
//        func nickNamesResponse(nickNames: [Nicknames]) {
//            if let address = addressObj {
//                setViewForEdit(address: address)
//            } else {
//                nickNamesArray = nickNames
//            }
//
//            nickNameCollectionView.delegate = self
//            nickNameCollectionView.dataSource = self
//            saveButton.isUserInteractionEnabled = true
//        }
//
//        func setViewForEdit(address: Address) {
//            presenter?.getLocationName(lat: address.latitude ?? "", long: address.longitude ?? "")
//            flatNoTextField.text = address.flatNo
//            buildingNameTextField.text = address.building
//            streetTextField.text = address.street
//            landmarkTextField.text = address.landmark
//
//            flatNumberValid = !(flatNoTextField.text?.isEmpty ?? false)
//            buildNameValid = !(buildingNameTextField.text?.isEmpty ?? false)
//            streetNameValid = !(streetTextField.text?.isEmpty ?? false)
//
//            address.nicknames?.forEach { nickName in
//                if address.nickname?.lowercased() == nickName.nickname?.lowercased() {
//                    self.nickNameTextField.text = address.nickname
//                } else {
//                    self.nickNameTextField.text = nickName.otherNickname ?? ""
//                }
//            }
//            nickNamesArray = address.nicknames ?? []
//        }
//
//        func updateLocationName(place: String) {
//            addressLabel.text = place
//            addressObj?.locationName = place
//        }
//    }



//    extension AddOrEditAddressViewController : ConfirmUserLocationViewControllerProtocol {
//        func getNewAddressLocation(location: SearchLocationResponseModel?) {
//
//            if let addressloc = location?.title {
//                addressLabel.text = addressloc
//
//                let addressObj = Address()
//                addressObj.latitude =  "\(location?.lat ?? 0)"
//                addressObj.longitude = "\(location?.long ?? 0)"
//                self.addressObj = addressObj
//
//                presenter?.getUpdatedLocationName(lat: String(addressObj.latitude ?? ""), long: String(addressObj.longitude ?? ""))
//    //
//    //            addressObj?.locationName = addressloc
//            }
//        }
//
//
//        @IBAction func changeButtonClicked(_ sender : Any){
//            presenter?.changeButtonClicked()
//        }
//
//
//    }


