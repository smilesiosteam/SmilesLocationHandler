//
//  SmilesLocationDetectViewController.swift
//
//
//  Created by Ghullam  Abbas on 16/11/2023.
//

import UIKit
import SmilesLanguageManager
import SmilesFontsManager
import SmilesUtilities
import Combine
import SmilesLoader

class SmilesLocationDetectViewController: UIViewController, SmilesPresentableMessage {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var mainContainerView: UIView!
    @IBOutlet weak var panDismissView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var detectButton: UIButton!
    @IBOutlet private weak var searchButton: UIButton!
    
    // MARK: - Properties
    private var dismissViewTranslation = CGPoint(x: 0, y: 0)
    private var viewModel: DetectLocationPopupViewModel?
    private var controllerType: LocationPopUpType
    private var setLocationViewModel = SetLocationViewModel()
    private var setLocationInput: PassthroughSubject<SetLocationViewModel.Input, Never> = .init()
    private var cancellables = Set<AnyCancellable>()
    var deletePressed: (() -> Void)?
    private var dismissed: (() -> Void)?
    
    // MARK: - IBActions
    @IBAction private func didTabDetectLocationButton(_ sender: UIButton) {
        handleDetectLocationAction()
    }
    
    @IBAction private func didTabSearchLocationButton(_ sender: UIButton) {
        handleSearchLocationAction()
    }
    
    @IBAction private func didTabCrossButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Methods
    init(controllerType: LocationPopUpType, dismissed: (() -> Void)?) {
        self.viewModel = DetectLocationPopupViewModelFactory.createViewModel(for: controllerType)
        self.controllerType = controllerType
        self.dismissed = dismissed
        super.init(nibName: "SmilesLocationDetectViewController", bundle: .module)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - View Controller Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        styleFontAndTextColor()
        if let viewModel = viewModel {
            self.configure(with: viewModel)
        }
        bind(to: setLocationViewModel)
    }
    private  func configure(with viewModel: DetectLocationPopupViewModel?) {
        
        self.messageLabel.text = viewModel?.data?.message
        if let imageName = viewModel?.data?.iconImage {
            self.imageIcon.image = UIImage(named: imageName, in: .module, compatibleWith: nil)
            self.imageIcon.backgroundColor = .white
            
        }
        self.detectButton.setTitle(viewModel?.data?.detectButtonTitle, for: .normal)
        self.searchButton.setTitle(viewModel?.data?.searchButtonTitle, for: .normal)
    }
    
    private func styleFontAndTextColor() {
        
        self.messageLabel.fontTextStyle = .smilesHeadline4
        self.detectButton.fontTextStyle = .smilesHeadline4
        self.searchButton.fontTextStyle = .smilesHeadline4
        
        self.messageLabel.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        self.detectButton.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        self.searchButton.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
    }
    
    private func setupUI() {
        mainContainerView.backgroundColor = .white
        mainContainerView.clipsToBounds = true
        mainContainerView.layer.cornerRadius = 16
        mainContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
//        view.backgroundColor = .appRevampFilterTextColor.withAlphaComponent(0.6)
        panDismissView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        panDismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    private func handleDetectLocationAction() {
        switch controllerType {
        case .detectLocation:
            if SmilesLocationHandler.isLocationEnabled {
                detectUserLocation()
            } else {
                dismiss(animated: true) {
                    LocationManager.shared.showPopupForSettings()
                }
            }
        case .deleteWorkAddress:
            dismiss(animated: true) {
                self.deletePressed?()
            }
        case .automaticallyDetectLocation:
            dismiss(animated: true) {
                LocationManager.shared.showPopupForSettings()
            }
        }
    }
    
    private func handleSearchLocationAction() {
        switch controllerType {
        case .detectLocation:
            dismiss(animated: true) {
                SmilesLocationRouter.shared.presentSetLocationPopUp()
            }
        case .deleteWorkAddress:
            dismiss(animated: true)
        case .automaticallyDetectLocation:
            dismiss(animated: true) {
                self.dismissed?()
            }
        }
    }
    
    private func detectUserLocation() {
        
        LocationManager.shared.getLocation { [weak self] location, error in
            guard let self else { return }
            if let location {
                SmilesLoader.show()
                self.setLocationInput.send(.getUserLocation(location: location))
            }
        }
        
    }
    
}

// MARK: - GESTURES ACTION HANDLING -
extension SmilesLocationDetectViewController {
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            dismissViewTranslation = sender.translation(in: view)
            if dismissViewTranslation.y > 0 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.dismissViewTranslation.y)
                })
            }
        case .ended:
            if dismissViewTranslation.y < 150 {
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.view.transform = .identity
                })
            }
            else {
                dismiss(animated: true)
            }
        default:
            break
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        dismiss(animated: true)
    }
    
}

// MARK: - VIEMODEL BINDING -
extension SmilesLocationDetectViewController {
    
    func bind(to setLocationViewModel: SetLocationViewModel) {
        setLocationInput = PassthroughSubject<SetLocationViewModel.Input, Never>()
        let output = setLocationViewModel.transform(input: setLocationInput.eraseToAnyPublisher())
        output
            .sink { [weak self] event in
                guard let self else { return }
                SmilesLoader.dismiss()
                switch event {
                case .getUserLocationDidSucceed(let response, _):
                    self.handleUserLocationResponse(response: response)
                case .getUserLocationDidFail(let error):
                    if !error.localizedDescription.isEmpty {
                        self.showMessage(model: SmilesMessageModel(description: error.localizedDescription))
                    }
                default: break
                }
            }.store(in: &cancellables)
    }
    
}

// MARK: - RESPONSE HANDLING -
extension SmilesLocationDetectViewController {
    
    private func handleUserLocationResponse(response: RegisterLocationResponse) {
        
        if let errorMessage = response.responseMsg, !errorMessage.isEmpty {
            self.showMessage(model: SmilesMessageModel(title: response.errorTitle, description: errorMessage))
        } else if let userInfo = response.userInfo {
            self.dismiss(animated: true, completion: {
                LocationStateSaver.saveLocationInfo(userInfo, isFromMamba: false)
                NotificationCenter.default.post(name: .LocationUpdated, object: nil, userInfo: [Constants.Keys.shouldUpdateMamba : true])
            })
        }
        
    }
    
}
