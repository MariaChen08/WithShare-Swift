//
//  CustomTabBar.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/11/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation
import UIKit

//TabBar with customized height

extension UITabBar {
    
    override public func sizeThatFits(size: CGSize) -> CGSize {
        super.sizeThatFits(size)
        var sizeThatFits = super.sizeThatFits(size)
        sizeThatFits.height = 30
//        print(sizeThatFits.height)
        return sizeThatFits
    }
}
