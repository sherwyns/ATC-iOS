//
//  Rectangle.swift
//  test
//
//  Created by Rathinavel, Dhandapani on 05/04/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

@IBDesignable
class LeftRectangle: UIView {
    
    var view: UIView!
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        let screenHeight: Double = Double(rect.size.height)
        let screenWidth: Double = Double(rect.size.width)

        let sixtyPercent = (screenHeight * 0.6)
        let seventyPercent = (screenHeight * 0.67)
        let eightyPercent = (screenHeight * 0.8)
        let ninetyPercent = (screenHeight * 0.9)
        let fiftyPercent = (screenHeight * 0.49)
        let secondXpoint = screenWidth * 0.95
        let thirdXpoint  = (screenWidth)

        let initialPoint = CGPoint.init(x: 0, y: seventyPercent)
        let secondPoint = CGPoint.init(x: secondXpoint, y: fiftyPercent)
        let thirdPoint = CGPoint.init(x: thirdXpoint, y: ninetyPercent)
        let fourthPoint = CGPoint.init(x: screenWidth, y: screenHeight)
        let fifthPoint = CGPoint.init(x: 0, y: screenHeight)
        let sixthPoint = CGPoint.init(x: 0, y: sixtyPercent)

        
        path.move(to: initialPoint)
        path.addLine(to: secondPoint)
        path.addLine(to: thirdPoint)
        path.addLine(to: fourthPoint)
        path.addLine(to: fifthPoint)
        path.addLine(to: initialPoint)
        
        UIColor.init(red: 84.0/255.0, green: 136.0/255.0, blue: 246.0/255.0, alpha: 0.97).setFill()
        path.fill()
    }
}
