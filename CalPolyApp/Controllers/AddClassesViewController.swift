//
//  AddClassesViewController.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 2/25/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import UIKit
import Firebase

class AddClassesViewController: UIViewController, UIPickerViewDataSource,
UIPickerViewDelegate {

   @IBOutlet weak var classSelector: UIPickerView!
   @IBOutlet weak var SectionSelector: UITableView!

   let ref = FIRDatabase.database().reference(withPath: "Schedules")
    
   var myDB = [[],
               ["-"]]
   var AllClassList : [String : [ClassItem]] = [:]
   var deptSelected = ""
   
    override func viewDidLoad() {
        super.viewDidLoad()
      self.classSelector.delegate = self
      self.classSelector.dataSource = self
      
      ref.queryOrdered(byChild: "Dept").observe(.value, with : {snapshot in
         for item in snapshot.children {
            let classItem = ClassItem(snapshot: item as! FIRDataSnapshot)
            var classList : [ClassItem] = []
            if self.AllClassList[classItem.dept] != nil {
               classList = self.AllClassList[classItem.dept]!
            }
            classList.append(classItem)
            self.AllClassList[classItem.dept] = classList
         }
         self.myDB[0] = Array(self.AllClassList.keys.sorted())
         self.classSelector.reloadAllComponents()
      })
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
      return myDB[component][row] as! String
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      if (component == 0) {
         var courseList : Set<String> = []
         let AllCourseForMajor : [ClassItem] = AllClassList[myDB[component][row]]!
         for course in AllCourseForMajor {
            courseList.insert(course.Class)
         }
         myDB[1] = Array(courseList.sorted())
         deptSelected = myDB[component][row]
         self.classSelector.reloadAllComponents()
      }
      else {
         
      }
   }
}
