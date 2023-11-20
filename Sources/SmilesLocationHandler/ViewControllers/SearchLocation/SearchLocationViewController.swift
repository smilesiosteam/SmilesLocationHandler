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
    private var searchResults = [SearchLocationResponseModel]() {
        didSet {
            searchResultsTableView.reloadData()
        }
    }
    
    // MARK: - ACTIONS -
    @IBAction func clearPressed(_ sender: Any) {
        
        searchTextField.text = ""
        searchTextField.resignFirstResponder()
        closeButton.isHidden = true
        searchResults.removeAll()
        
    }
    
    // MARK: - INITIALIZERS -
    init() {
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
        
    }
    
    private func setupTableView() {
        
        searchResultsTableView.registerCellFromNib(LocationSearchResultTableViewCell.self, withIdentifier: "LocationSearchResultTableViewCell", bundle: .module)
        searchResultsTableView.delegate = self
        searchResultsTableView.dataSource = self
        
    }
    
    private func setupSearchBar() {
        
        searchTextField.delegate = self
        searchTextField.placeholder = SmilesLanguageManager.shared.getLocalizedString(for: "Search") + "..."
        searchTextField.placeHolderTextColor = .black.withAlphaComponent(0.2)
        
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
                    self?.searchResults = results
                case .searchLocationDidFail(let error):
                    print(error.localizedDescription)
                case .fetchLocationDetailsDidSucceed(let locationDetails):
                    SmilesLoader.dismiss()
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
extension SearchLocationViewController: UISearchBarDelegate, UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text,
           let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            if !updatedText.isEmpty {
                closeButton.isHidden = false
                guard updatedText.count >= 3 else { return true }
                self.searchTask?.cancel()
                let task = DispatchWorkItem { [weak self] in
                    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                        guard let self else { return }
                        //Use search text and perform the query
                        self.input.send(.searchLocation(location: updatedText, isFromGoogle: !self.switchToOpenStreetMap))
                    }
                }
                self.searchTask = task
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: task)
            } else {
                closeButton.isHidden = true
                searchResults.removeAll()
            }
        }
        return true
        
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        searchResults.removeAll()
        return true
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
        
        if let addressId = searchResults[indexPath.row].addressId {
            SmilesLoader.show()
            input.send(.getLocationDetails(locationId: addressId, isFromGoogle: !switchToOpenStreetMap))
        }
        
    }
    
}
