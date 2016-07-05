//
//  DeviceTypeEnum.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 7/1/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

enum DeviceTypeEnum: String {
    case Blank = " "
    case Android = "Android"
    case iOS = "iOS"
    
    var description: String { return rawValue }
    
    static var count: Int { return DeviceTypeEnum.iOS.hashValue + 1 }
    
    static func getItem(n: Int) -> DeviceTypeEnum {
        switch n {
        case 0:
            return DeviceTypeEnum.Blank
        case 1:
            return DeviceTypeEnum.Android
        case 2:
            return DeviceTypeEnum.iOS
        default:
            return DeviceTypeEnum.Blank
        }
    }

}
