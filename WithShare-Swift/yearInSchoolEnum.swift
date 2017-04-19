//
//  yearInSchoolEnum.swift
//  WithShare-Swift
//
//  Created by Jiawei Chen on 11/10/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import UIKit

enum yearInSchoolEnum: String {
    case Blank = " "
    case FR = "Freshman"
    case SO = "Sophomore"
    case JR = "Junior"
    case SR = "Senior"
    case GR = "Graduate Student"
    case FT = "Faculty/Staff"
    
    var description: String { return rawValue }
    
    static var count: Int { return yearInSchoolEnum.FT.hashValue + 1 }
    
    static func getItem(_ n: Int) -> yearInSchoolEnum {
        switch n {
        case 0:
            return yearInSchoolEnum.Blank
        case 1:
            return yearInSchoolEnum.FR
        case 2:
            return yearInSchoolEnum.SO
        case 3:
            return yearInSchoolEnum.JR
        case 4:
            return yearInSchoolEnum.SR
        case 5:
            return yearInSchoolEnum.GR
        case 6:
            return yearInSchoolEnum.FT
        default:
            return yearInSchoolEnum.Blank
        }
    }
}
