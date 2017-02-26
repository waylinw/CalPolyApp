//
//  AddClassesViewController.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 2/25/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import UIKit

class AddClassesViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

   @IBOutlet weak var classSelector: UIPickerView!
   @IBOutlet weak var SectionSelector: UITableView!
   
   var myDB = [["CSC", "CPE", "EE"],
               ["123", "232", "333"]]
   
    override func viewDidLoad() {
        super.viewDidLoad()
      self.classSelector.delegate = self
      self.classSelector.dataSource = self
    }
   
   @IBAction func signoutTouched(_ sender: UIButton) {
      dismiss(animated: true, completion: nil)
   }
   
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return myDB.count
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return myDB[component].count
   }
   
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return myDB[component][row] as String
   }
   
   
}
