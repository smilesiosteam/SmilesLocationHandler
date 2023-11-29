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

final class SmilesManageAddressesViewController: UIViewController, Toastable {
    
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
    // MARK: - Methods
    init() {
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
        locationNavBarTitle.text = "SavedAddresses".localizedString
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
        self.savedAddressedLabel.text = "SavedAddresses".localizedString
        self.editButton.setTitle("btn_edit".localizedString.capitalizingFirstLetter(), for: .normal)
    }
    func setupTableViewCells() {
        addressesTableView.registerCellFromNib(SmilesManageAddressTableViewCell.self, withIdentifier: String(describing: SmilesManageAddressTableViewCell.self), bundle: .module)
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
extension SmilesManageAddressesViewController: UITableViewDelegate, UITableViewDataSource, SmilesManageAddressTableViewCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addressDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SmilesManageAddressTableViewCell", for: indexPath) as? SmilesManageAddressTableViewCell else { return UITableViewCell() }
        cell.editButton.isHidden = !isEditingEnabled
        cell.mainViewLeading.constant = isEditingEnabled ? 48 : 16
        cell.delegate = self
        let address = addressDataSource [indexPath.row]
        cell.headingLabel.text = address.nickname
        cell.detailLabel.text = String(format: "%@ %@, %@, %@, %@ ", address.flatNo.asStringOrEmpty(), "".localizedString.lowercased(), address.building.asStringOrEmpty(), address.street.asStringOrEmpty(), " \(address.locationName.asStringOrEmpty())")
        cell.addressIcon.setImageWithUrlString(address.nicknameIcon ?? "")
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func didTapDeleteButtonInCell(_ cell: SmilesManageAddressTableViewCell) {
        // Handle the action here based on the cell's action
        if let indexPath = self.addressesTableView.indexPath(for: cell) {
             let item = self.addressDataSource[indexPath.row]
            let message = "\("btn_delete".localizedString) \(item.nickname ?? "") \("ResturantAddress".localizedString)"
            if let vc =  SmilesLocationConfigurator.create(type: .createDetectLocationPopup(DetectLocationPopupViewModelFactory.createViewModel(for: .deleteWorkAddress(message: message)))) as? SmilesLocationDetectViewController {
                vc.setDetectLocationAction {
                    self.addressDataSource.remove(at: indexPath.row)
                    SmilesLoader.show(on: self.view)
                    self.input.send(.removeAddress(address_id: Int(item.addressId ?? "")))
                }
                self.present(vc, animated: true)
            }
            // Perform actions based on indexPath
        }
    }
    func didTapDetailButtonInCell(_ cell: SmilesManageAddressTableViewCell) {
        if let indexPath = self.addressesTableView.indexPath(for: cell) {
             let item = self.addressDataSource[indexPath.row]
            // Perform actions based on indexPath
            if let navigationController = self.navigationController {
                SmilesLocationRouter.shared.pushAddOrEditAddressViewController(with: navigationController, addressObject: item)
            }
        }
    }
    
}

// MARK: - ViewModel Binding
extension SmilesManageAddressesViewController {
    
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
                    var model = ToastModel()
                    model.title = "address_has_been_deleted".localizedString
                    model.imageIcon = UIImage(named: "green_tic_icon", in: .module, with: nil)
                    self?.showToast(model: model)
                    self?.input.send(.getAllAddress)
                case .removeAddressDidFail(error: _):
                    self?.input.send(.getAllAddress)
                    break
                case .saveDefaultAddressDidSucceed(response: _):
                    break
                case .saveDefaultAddressDidFail(error: _):
                    break
                }
            }.store(in: &cancellables)
    }
}
