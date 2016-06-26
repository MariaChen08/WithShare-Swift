//
//  GenderEnum.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/18/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation

enum GenderEnum: String {
    case Blank = " "
    case Male = "Male"
    case Female = "Female"
    
    var description: String { return rawValue }
    
    static var count: Int { return GenderEnum.Female.hashValue + 1 }
    
    static func getItem(n: Int) -> GenderEnum {
        switch n {
        case 0:
            return GenderEnum.Blank
        case 1:
            return GenderEnum.Male
        case 2:
            return GenderEnum.Female
        default:
            return GenderEnum.Blank
        }
    }
}