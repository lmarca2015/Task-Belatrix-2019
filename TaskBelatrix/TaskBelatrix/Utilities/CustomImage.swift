//
//  CustomImage.swift
//  TaskBelatrix
//
//  Created by APPLE on 5/03/19.
//  Copyright © 2019 Oxicode. All rights reserved.
//

import UIKit

class CustomImage: NSObject {

    // MARK: - Other Methods
    /* This method cut/clip diagonally imageView */
    public func setClippingImageView(imgView : UIImageView)
    {
        
        let startPoint = CGPoint(x:121, y:0)
        let endPoint = CGPoint(x:0, y:188)
        let thirdPoint = CGPoint(x:121, y:188)
        
        let triangle = UIBezierPath(cgPath: CGPath(rect: CGRect(x: 0, y: 0, width: 121, height: 188), transform: nil))
        triangle.move(to: startPoint)
        triangle.addLine(to: endPoint)
        triangle.addLine(to: thirdPoint)
        triangle.close()
        
        //print("Mask Paths \(startPoint), \(endPoint), \(thirdPoint)");
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = imgView.frame;
        maskLayer.path = triangle.cgPath
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.backgroundColor = UIColor.clear.cgColor
        
        imgView.layer.mask = maskLayer;
        
    }
    
}

