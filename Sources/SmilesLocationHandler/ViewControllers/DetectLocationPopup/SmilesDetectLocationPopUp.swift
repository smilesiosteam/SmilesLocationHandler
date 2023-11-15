//
//  SmilesExplorerPickTicketPopUp.swift
//  
//
//  Created by Ghullam  Abbas on 15/11/2023.
//

import UIKit
import SmilesLanguageManager
import SmilesFontsManager


 final class SmilesDetectLocationPopUp: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet private weak var mainContainerView: UIView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var imageIcon: UIImageView!
    @IBOutlet private weak var detectButton: UIButton!
    @IBOutlet private weak var searchButton: UIButton!

    // MARK: - View Controller Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        styleFontAndTextColor()
        setupUI()
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
    }

    private func setupUI() {
        mainContainerView.clipsToBounds = true
        mainContainerView.layer.cornerRadius = 16
        mainContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.backgroundColor = .appRevampFilterTextColor.withAlphaComponent(0.6)
    }

    // MARK: - IBActions
    @IBAction private func didTabDetectLocationButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction private func didTabSearchLocationButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    @IBAction private func didTabCrossButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}
