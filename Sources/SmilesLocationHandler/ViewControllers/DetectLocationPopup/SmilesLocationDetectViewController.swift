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

class SmilesLocationDetectViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var mainContainerView: UIView!
    @IBOutlet weak var panDismissView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var detectButton: UIButton!
    @IBOutlet private weak var searchButton: UIButton!
    
    // MARK: - Properties
    private var detectLocationAction: (() -> Void)?
    private var searchLocationAction: (() -> Void)?
    private var dismissViewTranslation = CGPoint(x: 0, y: 0)
    private var viewModel: DetectLocationPopupViewModel?
    // MARK: - Methods
    init(_ viewModel: DetectLocationPopupViewModel?) {
        
        self.viewModel = viewModel
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
    }
    private  func configure(with viewModel: DetectLocationPopupViewModel?) {
        
        self.messageLabel.text = viewModel?.data?.message
        if let imageName = viewModel?.data?.iconImage {
            self.imageIcon.image = UIImage(named: imageName, in: .module, compatibleWith: nil)
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
        
        mainContainerView.clipsToBounds = true
        mainContainerView.layer.cornerRadius = 16
        mainContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.backgroundColor = .appRevampFilterTextColor.withAlphaComponent(0.6)
        panDismissView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismiss)))
        panDismissView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    // MARK: - IBActions
    @IBAction private func didTabDetectLocationButton(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.detectLocationAction?()
        }
    }
    
    @IBAction private func didTabSearchLocationButton(_ sender: UIButton) {
        dismiss(animated: true) { [weak self] in
            self?.searchLocationAction?()
        }
    }
    
    @IBAction private func didTabCrossButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    // MARK: - methods to set closure actions
    func setDetectLocationAction(_ action: (() -> Void)?) {
        detectLocationAction = action
    }
    
    func setSearchLocationAction(_ action: (() -> Void)?) {
        searchLocationAction = action
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
