//
//  File.swift
//  
//
//  Created by Abdul Rehman Amjad on 21/11/2023.
//

import UIKit
import SmilesUtilities

class RecentLocationHeader: UIView {

    // MARK: - OUTLETS -
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var titleLabel: UILocalizableLabel!
    
    
    // MARK: - PROPERTIES -
    
    
    // MARK: - METHODS -
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        fatalError("init(coder:) has not been implemented")
    }
    
    private func commonInit() {
        
        //XibView Setup
        Bundle.module.loadNibNamed(String(describing: RecentLocationHeader.self), owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = bounds
        mainView.bindFrameToSuperviewBounds()
        titleLabel.semanticContentAttribute = AppCommonMethods.languageIsArabic() ? .forceRightToLeft : .forceLeftToRight
        
    }

}
