//
//  ControllerExtensions.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 11/9/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

extension UIViewController {
   func hideKeyboardWhenTappedAround() {
      let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
      tap.cancelsTouchesInView = false
      view.addGestureRecognizer(tap)
   }
   
   @objc func dismissKeyboard() {
      view.endEditing(true)
   }
}

extension String {
   func toBool() -> Bool? {
      switch self {
      case "Yes","True", "true":
         return true
      case "No", "False", "false":
         return false
      default:
         return nil
      }
   }
}
