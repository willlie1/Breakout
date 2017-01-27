//
//  BreakOutBall.swift
//  BreakOut
//
//  Created by Wilko Zonnenberg on 20-12-16.
//  Copyright © 2016 Wilko Zonnenberg. All rights reserved.
//

import UIKit

class BreakOutBall: UIView {

    var linearVelocity: CGPoint
    
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
    
    override init(frame: CGRect) {
        linearVelocity = CGPoint(x: 0,y: 0)
        super.init(frame: frame)
        layer.cornerRadius = frame.width / 2.0
        backgroundColor = UIColor.red
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
