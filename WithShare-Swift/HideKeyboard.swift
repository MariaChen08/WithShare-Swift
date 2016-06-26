//
//  HideKeyboard.swift
//  WithShare-iOS
//
//  Created by Jiawei Chen on 6/21/16.
//  Copyright © 2016 Jiawei Chen. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}