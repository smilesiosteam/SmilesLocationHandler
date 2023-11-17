//
//  LocationPinView.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import UIKit
import SmilesUtilities

class LocationPinView: UIView {

    // MARK: - OUTLETS -
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    // MARK: - PROPERTIES -
    private var arrowView: UIView!
    
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
        Bundle.module.loadNibNamed(String(describing: LocationPinView.self), owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = bounds
        mainView.bindFrameToSuperviewBounds()
        drawPointingView()
        
    }
    
    private func drawPointingView() {
        
        let arrowWidth: CGFloat = 24
        let arrowHeight: CGFloat = 15
        let halfWidth = arrowWidth / 2
        arrowView = UIView(frame: CGRect(x: 0, y: 0, width: arrowWidth, height: arrowHeight))
        arrowView.backgroundColor = .clear
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: halfWidth, y: arrowHeight))
        path.addLine(to: CGPoint(x: arrowWidth, y: 0))
        path.close()
        
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        shape.path = path.cgPath
        arrowView.layer.addSublayer(shape)
        self.addSubview(arrowView)
        arrowView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arrowView.centerXAnchor.constraint(equalTo: mainStackView.centerXAnchor, constant: -(halfWidth)),
            arrowView.topAnchor.constraint(equalTo: mainStackView.bottomAnchor)
        ])
        
     }

}
