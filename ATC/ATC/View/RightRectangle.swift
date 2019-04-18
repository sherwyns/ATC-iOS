//
//  RightRectangle.swift
//  test
//
//  Created by Rathinavel, Dhandapani on 05/04/19.
//  Copyright © 2019 Rathinavel, Dhandapani. All rights reserved.
//

import UIKit

class RightRectangle: UIView {
    
    var view: UIView!
    
    override func draw(_ rect: CGRect) {
        //        let path = UIBezierPath.init(ovalIn: rect)
        let path = UIBezierPath()
        
        let screenHeight: Double = Double(rect.size.height)
        let screenWidth: Double = Double(rect.size.width)
        
        let sixtyFivePercent = (screenHeight * 0.65)
        let seventyPercent = (screenHeight * 0.7)
        let eightyPercent = (screenHeight * 0.8)
        let ninetyPercent = (screenHeight * 0.9)
        let fiftyPercent = (screenHeight * 0.48)
        let fiftyTwoPercent = (screenHeight * 0.52)
        let secondXpoint = screenWidth * 0.65
        let thirdXpoint  = (screenWidth)
        
        let initialPoint = CGPoint.init(x: screenWidth, y: fiftyPercent)
        let secondPoint = CGPoint.init(x: secondXpoint, y: sixtyFivePercent)
        let thirdPoint = CGPoint.init(x: thirdXpoint, y: ninetyPercent)
        let fourthPoint = CGPoint.init(x: screenWidth, y: screenHeight)
        
        path.move(to: initialPoint)
        path.addLine(to: secondPoint)
        path.addLine(to: thirdPoint)
        path.addLine(to: initialPoint)

//        42 73 84
        UIColor.init(red: 60.0/255.0, green: 102.0/255.0, blue: 246.0/255.0, alpha: 0.99).setFill()
//        UIColor.blue.setFill()
        path.fill()
    }
}
