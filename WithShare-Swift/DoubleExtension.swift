//
//  DoubleExtension.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 8/15/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

extension Double {
    
    // Round to 5 digits precision
    func roundFiveDigits() -> Double {
        let divisor = 100000.0
        return (self * divisor).rounded() / divisor
    }
}
