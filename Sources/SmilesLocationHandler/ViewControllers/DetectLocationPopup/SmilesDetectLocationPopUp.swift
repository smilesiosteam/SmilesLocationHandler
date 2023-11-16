//
//  SmilesExplorerPickTicketPopUp.swift
//
//
//  Created by Ghullam  Abbas on 15/11/2023.
//

import UIKit
import SmilesLanguageManager
import SmilesFontsManager
import SmilesUtilities


final class SmilesDetectLocationPopUp: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var mainContainerView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var detectButton: UIButton!
    @IBOutlet private weak var searchButton: UIButton!
    
    // MARK: - Properties
    private var detectLocationAction: (() -> Void)?
    private var searchLocationAction: (() -> Void)?
    
    // MARK: - View Controller Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        styleFontAndTextColor()
    }
    
    // MARK: - Methods
    init() {
        super.init(nibName: "SmilesDetectLocationPopUp", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with viewModel: DetectLocationPopupViewModel?) {
        self.messageLabel.text = viewModel?.data?.message
        self.imageIcon.image = UIImage(named: viewModel?.data?.iconImage ?? "")
        self.detectButton.setTitle(viewModel?.data?.detectButtonTitle, for: .normal)
        self.searchButton.setTitle(viewModel?.data?.searchButtonTitle, for: .normal)
    }
    
    private func styleFontAndTextColor() {
        self.messageLabel.fontTextStyle = .smilesHeadline4
        self.detectButton.fontTextStyle = .smilesHeadline4
        self.searchButton.fontTextStyle = .smilesBody4
        
        self.messageLabel.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        self.detectButton.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        self.searchButton.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
    }
    
    private func setupUI() {
        mainContainerView.clipsToBounds = true
        mainContainerView.layer.cornerRadius = 16
        mainContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.backgroundColor = .appRevampFilterTextColor.withAlphaComponent(0.6)
    }
    
    // MARK: - IBActions
    @IBAction private func didTabDetectLocationButton(_ sender: UIButton) {
        detectLocationAction?()
        self.dismiss(animated: true)
    }
    
    @IBAction private func didTabSearchLocationButton(_ sender: UIButton) {
        searchLocationAction?()
        self.dismiss(animated: true)
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
