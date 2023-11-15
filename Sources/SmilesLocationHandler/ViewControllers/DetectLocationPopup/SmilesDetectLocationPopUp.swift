//
//  SmilesExplorerPickTicketPopUp.swift
//  
//
//  Created by Ghullam  Abbas on 15/11/2023.
//

import UIKit
import SmilesLanguageManager
import SmilesFontsManager


public class SmilesDetectLocationPopUp: UIViewController {
    
    //MARK: - IBOutlets -
    @IBOutlet weak var mainContainerView: UIView!
    @IBOutlet weak var messageLabel: UILabel!
    
    @IBOutlet weak var detectButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    //MARK: - Properties -
    
    //MARK: - View Controller Lifecycle -
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        styleFontAndTextColor()
        setupUI()
        
    }
    
    //MARK: - Methods -
    init() {
        super.init(nibName: "SmilesDetectLocationPopUp", bundle: .module)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func styleFontAndTextColor() {
        self.messageLabel.fontTextStyle = .smilesHeadline4
        self.detectButton.fontTextStyle =  .smilesHeadline4
        self.searchButton.fontTextStyle = .smilesBody4
    }
    private func setupUI() {
        
        mainContainerView.clipsToBounds = true
        mainContainerView.layer.cornerRadius = 16
        mainContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.backgroundColor = .appRevampFilterTextColor.withAlphaComponent(0.6)
    }
    
    
    //MARK: - IBActions -
    @IBAction func didTabDetectLocationButton(_ sender: UIButton) {
        
        self.dismiss(animated: true)
    }
    @IBAction func didTabSearchLocationButton(_ sender: UIButton) {
        
        self.dismiss(animated: true)
    }
    @IBAction func didTabCrossButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

