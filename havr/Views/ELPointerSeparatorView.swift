//
//  ELPointerSeparatorView.swift
//  TestApp
//
//  Created by Yevhenii Lytvinenko on 1/16/18.
//  Copyright © 2018 Yevhenii Lytvinenko. All rights reserved.
//

import UIKit

class ELPointerSeparatorView: UIView {

    //MARK: Public vars
    
    var pointerTargetX: CGFloat = 0 {
        didSet {
            updateUI()
        }
    }
    
    var lineWidth: CGFloat = 1 {
        didSet {
            pathLayer?.lineWidth = lineWidth
        }
    }
    
    var lineColor = UIColor.blue {
        didSet {
            pathLayer?.strokeColor = lineColor.cgColor
        }
    }
    
    //MARK: Private vars
    
    private var pathLayer: CAShapeLayer!
    
    //MARK: Overriding
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    //MARK: Private methods
    
    private func setupUI() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = formBezierPath(pointerTargetX: pointerTargetX).cgPath
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.position = CGPoint.zero
        layer.addSublayer(shapeLayer)
        pathLayer = shapeLayer
    }
    
    private func updateUI() {
        pathLayer?.path = formBezierPath(pointerTargetX: pointerTargetX).cgPath
    }
    
    private func formBezierPath(pointerTargetX x: CGFloat = 0) -> UIBezierPath {
        
        let h = frame.height
        let path = UIBezierPath()
        
        path.move(to: CGPoint.zero)
        
        if x > 0 {
            path.addLine(to: CGPoint(x: (x - h), y: 0))
            path.addLine(to: CGPoint(x: x, y: h))
            path.addLine(to: CGPoint(x: (x + h), y: 0))
        }
        
        path.addLine(to: CGPoint(x: frame.width, y: 0))
       
        return path
    }
}
