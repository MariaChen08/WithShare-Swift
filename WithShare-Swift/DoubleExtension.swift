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
        let y = Double(round(100000*self)/100000)
        return y
    }
}