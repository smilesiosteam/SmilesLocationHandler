//
//  LocationPinView.swift
//  
//
//  Created by Abdul Rehman Amjad on 17/11/2023.
//

import UIKit

class LocationPinView: UIView {

    // MARK: - OUTLETS -
    @IBOutlet weak var arrowView: UIView!
    @IBOutlet var mainView: UIView!
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        drawPointingView()
    }
    
    private func commonInit() {
        
        //XibView Setup
        Bundle.module.loadNibNamed(String(describing: LocationPinView.self), owner: self, options: nil)
        addSubview(mainView)
        mainView.frame = bounds
        mainView.bindFrameToSuperviewBounds()
        
    }
    
    private func drawPointingView() {
        
        let path = UIBezierPath()
        let arrowWidth: CGFloat = 24
        let halfWidth = arrowWidth / 2
        let midX = arrowView.frame.width / 2
        path.move(to: CGPoint(x: midX - halfWidth, y: 0))
        path.addLine(to: CGPoint(x: midX, y: arrowView.frame.height))
        path.addLine(to: CGPoint(x: midX + halfWidth, y: 0))
        path.close()
        
        let shape = CAShapeLayer()
        shape.fillColor = UIColor.black.withAlphaComponent(0.6).cgColor
        shape.path = path.cgPath
        arrowView.layer.addSublayer(shape)
        
     }

}
