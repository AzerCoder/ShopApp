//
//  GradientView.swift
//  ShopApp
//
//  Created by A'zamjon Abdumuxtorov on 22/03/24.
//

import UIKit

final class GradientView: UIView{
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = UIColor.clear
    }
    
    override func draw(_ rect: CGRect) {
        let traits = UITraitCollection.current
        let color = traits.userInterfaceStyle == .light ? 0.314 : 1
        
        let componets: [CGFloat] = [
            color,color,color, 0.2,
            color,color,color, 0.4,
            color,color,color, 0.6,
            color,color,color, 1,
        ]
        
        let locations: [CGFloat] = [0,0.5,0.75,1]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: componets, locations: locations, count: 4)
        
        let x = bounds.midX
        let y = bounds.midY
        
        let centerPoint = CGPoint(x: x, y: y)
        
        let radius = max(x, y)
        
        let context = UIGraphicsGetCurrentContext()
        
        context?.drawRadialGradient(gradient!, startCenter: centerPoint, startRadius: 0, endCenter: centerPoint, endRadius: radius, options: .drawsAfterEndLocation)
        
    }
}
