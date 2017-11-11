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
UIPickerViewDelegate, UITableViewDataSource, UITableViewDelegate {

   @IBOutlet weak var classSelector: UIPickerView!
   @IBOutlet weak var SectionSelector: UITableView!

   let ref = FIRDatabase.database().reference(withPath: "Schedules")
    
   var myDB = [[],
               ["-"]]
   var AllClassList : [String : [ClassItem]] = [:]
   var deptSelected = ""
   var curCourseSelected = ""
   var AllSectionsForClass : [ClassItem] = []
   
   var toAddFB = [String]()
   var oldClasses = [String]()
   
   let overview = "overview"
   
    override func viewDidLoad() {
        super.viewDidLoad()
      self.classSelector.delegate = self
      self.classSelector.dataSource = self
      self.SectionSelector.dataSource = self
      self.SectionSelector.delegate = self
      
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

      let classRef = FIRDatabase.database().reference(withPath: "User_Courses").child(FIRAuth.auth()!.currentUser!.uid)
      classRef.observeSingleEvent(of: .value, with: {(snapshot) in
         if let getData = snapshot.value as? [String:Any] {
            (getData["Courses"]! as? [String])!.forEach{course in self.oldClasses.append(course)}
         }
      })
   }
   
   @IBAction func signoutTouched(_ sender: UIButton) {
      try! FIRAuth.auth()!.signOut()
      if let storyboard = self.storyboard {
         let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! CalPolyApp.LoginViewController
         self.present(vc, animated: true, completion: nil)
      }
   }
   
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return myDB.count
   }
   
   func pickerView(_ pickerView: UIPickerView,
                   numberOfRowsInComponent component: Int) -> Int {
      return myDB[component].count
   }
   
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return myDB[component][row]
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      if (component == 0) {
         var courseList : Set<String> = []
         let AllCourseForMajor : [ClassItem] = AllClassList[myDB[component][row]]!
         for course in AllCourseForMajor {
            courseList.insert(course.Class)
         }
         myDB[1] = Array(courseList.sorted())
         deptSelected = myDB[component][row] as String
         deptSelected = deptSelected.replacingOccurrences(of: "\"", with: "")
         self.classSelector.reloadAllComponents()
      }
      else {
         let AllClassesForMajor : [ClassItem] = AllClassList[deptSelected]!
         let courseSelected : String = myDB[component][row]
         curCourseSelected = courseSelected
         AllSectionsForClass = []
         for temp_class in AllClassesForMajor {
            if temp_class.Class == courseSelected {
               AllSectionsForClass.append(temp_class)
            }
         }
         SectionSelector.reloadData()
      }
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return AllSectionsForClass.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = UITableViewCell(style: .value1, reuseIdentifier: "td")
      let classItem = AllSectionsForClass[indexPath.row]
      
      let checkdup = deptSelected + " " + curCourseSelected + " " + classItem.section
      if toAddFB.contains(checkdup) {
         cell.backgroundColor = UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1.0)
      }
      
      cell.textLabel?.font = UIFont(name: (cell.textLabel?.font.fontName)!, size: 11)
      cell.textLabel?.text = "Section: " + classItem.section + "     " + classItem.instructor + "     " + classItem.time
      
      return cell
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let cell = tableView.cellForRow(at: indexPath) else { return }
      let sectionItem = cell.textLabel?.text?.components(separatedBy: " ")[1]
      let toInsert = deptSelected + " " + curCourseSelected + " " + sectionItem!
      
      if cell.backgroundColor  == UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1.0) {
         cell.backgroundColor = .white
         toAddFB = toAddFB.filter(){$0 != toInsert}
      }
      else {
         cell.backgroundColor = UIColor(red: 218/255.0, green: 218/255.0, blue: 218/255.0, alpha: 1.0)
         toAddFB.append(toInsert)
      }
   }
   
   @IBAction func addAction() {
      let ref = FIRDatabase.database().reference(withPath: "User_Courses")
      let classRef = ref.child(FIRAuth.auth()!.currentUser!.uid)
      
      classRef.setValue(toAnyObject())
      
      self.performSegue(withIdentifier: self.overview, sender: nil)
   }
   
   func toAnyObject() -> Any {
      toAddFB.append(contentsOf: oldClasses)
         return [
            "Courses": toAddFB
         ]
   }
}
