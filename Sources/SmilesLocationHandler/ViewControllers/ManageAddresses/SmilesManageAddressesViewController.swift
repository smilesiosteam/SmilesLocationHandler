//
//  SmilesManageAddressesViewController.swift
//
//
//  Created by Ghullam  Abbas on 17/11/2023.
//

import UIKit
import SmilesUtilities
import SmilesLanguageManager

final class SmilesManageAddressesViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var addressesTableView: UITableView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var savedAddressedLabel: UILabel!
    
    // MARK: - Properties
    var isEditingEnabled: Bool = false
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
        setupTableViewCells()
        styleFontAndTextColor()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        setUpNavigationBar()
        updateUI()
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SmilesManageAddressTableViewCell", for: indexPath) as? SmilesManageAddressTableViewCell else { return UITableViewCell() }
        cell.editButton.isHidden = !isEditingEnabled
        cell.mainViewLeading.constant = isEditingEnabled ? 48 : 16
        cell.delegate = self
        return cell
    }
    func didTapDeleteButtonInCell(_ cell: SmilesManageAddressTableViewCell) {
        // Handle the action here based on the cell's action
        if let indexPath = self.addressesTableView.indexPath(for: cell) {
            SmilesLocationRouter.shared.showDetectLocationPopup(from: self, controllerType: .deleteWorkAddress())
            // Perform actions based on indexPath
        }
    }
    
}
