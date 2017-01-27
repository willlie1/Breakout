//
//  BezierPathsView.swift
//  BreakOut
//
//  Created by Wilko Zonnenberg on 20-12-16.
//  Copyright © 2016 Wilko Zonnenberg. All rights reserved.
//

import UIKit

class BezierPathsView: UIView {


        
    private var bezierPaths = [String:UIBezierPath]()
    
    func setPath(path: UIBezierPath?, named name: String){
        bezierPaths[name] = path
        setNeedsDisplay()
        
    }
    
    override func draw(_ rect: CGRect) {
        // Drawing code
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }


}
