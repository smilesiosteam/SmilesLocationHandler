//
//  SearchLocationViewController.swift
//  
//
//  Created by Abdul Rehman Amjad on 20/11/2023.
//

import UIKit
import SmilesFontsManager
import SmilesUtilities
import Combine
import SmilesLoader
import SmilesLanguageManager

class SearchLocationViewController: UIViewController {

    // MARK: - OUTLETS -
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchView: UICustomView!
    @IBOutlet weak var closeButton: UIButton!
    
    // MARK: - PROPERTIES -
    private var input: PassthroughSubject<SetLocationViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    private lazy var viewModel: SetLocationViewModel = {
        return SetLocationViewModel()
    }()
    private var searchTask: DispatchWorkItem?
    private var switchToOpenStreetMap = false
    private var locationSelected: ((SearchedLocationDetails) -> Void)?
    private var searchResults = [SearchedLocationDetails]() {
        didSet {
            searchResultsTableView.reloadData()
        }
    }
    private var selectedResult: SearchedLocationDetails?
    private var numberOfSearchLocationsToSave = 10
    private var showRecents = true {
        didSet {
            if showRecents {
                setupRecentSearches()
            }
        }
    }
    
    // MARK: - ACTIONS -
    @IBAction func clearPressed(_ sender: Any) {
        
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        closeButton.isHidden = true
        searchResults.removeAll()
        showRecents = true
        
    }
    
    // MARK: - INITIALIZERS -
    init(locationSelected: @escaping((SearchedLocationDetails) -> Void)) {
        self.locationSelected = locationSelected
        super.init(nibName: "SearchLocationViewController", bundle: .module)
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
        setupTableView()
        setupSearchBar()
        setupRecentSearches()
        
    }
    
    private func setupTableView() {
        
        searchResultsTableView.registerCellFromNib(LocationSearchResultTableViewCell.self, withIdentifier: "LocationSearchResultTableViewCell", bundle: .module)
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        searchResultsTableView.contentInsetAdjustmentBehavior = .never
        searchResultsTableView.estimatedSectionHeaderHeight = 40
        searchResultsTableView.sectionHeaderHeight = UITableView.automaticDimension
        
    }
    
    private func setupSearchBar() {
        
        searchTextField.delegate = self
        searchTextField.placeholder = SmilesLanguageManager.shared.getLocalizedString(for: "Search") + "..."
        searchTextField.placeHolderTextColor = .black.withAlphaComponent(0.2)
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        searchTextField.textAlignment = AppCommonMethods.languageIsArabic() ? .right : .left
        
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

}

// MARK: - VIEWMODEL BINDING -
extension SearchLocationViewController {
    
    func bind(to viewModel: SetLocationViewModel) {
        input = PassthroughSubject<SetLocationViewModel.Input, Never>()
        let output = viewModel.transform(input: input.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                switch event {
                case .searchLocationDidSucceed(let results):
                    self?.showRecents = false
                    self?.searchResults = results
                case .searchLocationDidFail(let error):
                    print(error.localizedDescription)
                case .fetchLocationDetailsDidSucceed(let locationDetails):
                    SmilesLoader.dismiss()
                    self?.setupSearchedLocationData(locationDetails: locationDetails)
                    break
                case .fetchLocationDetailsDidFail(let error):
                    SmilesLoader.dismiss()
                    debugPrint(error?.localizedDescription ?? "")
                default: break
                }
            }.store(in: &cancellables)
    }
    
}

// MARK: - UISEARCHBAR DELEGATE -
extension SearchLocationViewController: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        guard let text = textField.text else { return }
        if !text.isEmpty {
            closeButton.isHidden = false
            self.searchTask?.cancel()
            guard text.count >= 3 else {
                showRecents = false
                searchResults.removeAll()
                return
            }
            let task = DispatchWorkItem { [weak self] in
                DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                    guard let self else { return }
                    //Use search text and perform the query
                    self.input.send(.searchLocation(location: text, isFromGoogle: !self.switchToOpenStreetMap))
                }
            }
            self.searchTask = task
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task)
        } else {
            closeButton.isHidden = true
            searchResults.removeAll()
            showRecents = true
        }
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        searchView.layer.borderWidth = 2
        searchView.layer.borderColor = UIColor(hex: "75428e", alpha: 0.8).cgColor
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        searchView.layer.borderWidth = 1
        searchView.layer.borderColor = UIColor.black.withAlphaComponent(0.2).cgColor
        
    }
    
}

// MARK: - UITABLEVIEW DELEGATE & DATASOURCE -
extension SearchLocationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueCell(withClass: LocationSearchResultTableViewCell.self, for: indexPath)
        cell.setValues(location: searchResults[indexPath.row])
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let result = searchResults[indexPath.row]
        if !result.addressId.isEmpty {
            selectedResult = result
            SmilesLoader.show()
            input.send(.getLocationDetails(locationId: result.addressId, isFromGoogle: !switchToOpenStreetMap))
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return showRecents ? RecentLocationHeader() : nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return showRecents ? UITableView.automaticDimension : 0
    }
    
}

// MARK: - DATA CONFIGURATIONS -
extension SearchLocationViewController {
    
    private func setupSearchedLocationData(locationDetails: SearchedLocationDetails) {
        
        selectedResult?.latitude = locationDetails.latitude
        selectedResult?.longitude = locationDetails.longitude
        selectedResult?.formattedAddress = locationDetails.formattedAddress
        saveLocationData()
        if let selectedResult {
            locationSelected?(selectedResult)
            SmilesLocationRouter.shared.popVC()
        }
        
    }
    
    private func saveLocationData() {
        
        guard let selectedResult else { return }
        if var recentLocations = UserDefaults.standard.object([SearchedLocationDetails].self, with: Constants.Keys.recentLocation) {
            if recentLocations.count >= numberOfSearchLocationsToSave {
                recentLocations.removeFirst()
            }
            recentLocations.append(selectedResult)
            UserDefaults.standard.set(object: recentLocations, forKey: Constants.Keys.recentLocation)
        } else {
            UserDefaults.standard.set(object: [selectedResult], forKey: Constants.Keys.recentLocation)
        }
        
    }
    
    private func setupRecentSearches() {
        
        if let recentLocations = UserDefaults.standard.object([SearchedLocationDetails].self, with: Constants.Keys.recentLocation) {
            searchResults = recentLocations.reversed()
        }
        
    }
    
}
