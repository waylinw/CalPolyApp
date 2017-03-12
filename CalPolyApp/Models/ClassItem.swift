//
//  ClassItem.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 2/26/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

struct ClassItem {
   
   let key: String
   let instructor: String
   let time: String
   let Class : String
   let dept : String
   let section : String
   let ref: FIRDatabaseReference?
   
   init(instructor: String, time: String, key: String = " ",
        Class: String, dept: String, section: String) {
      self.key = key
      self.instructor = instructor
      self.time = time
      self.Class = Class
      self.dept = dept
      self.section = section
      self.ref = nil
   }
   
   init(snapshot: FIRDataSnapshot) {
      key = snapshot.key
      let snapshotValue = snapshot.value as! [String: AnyObject]
      instructor = snapshotValue["INSTRUCTOR"] as! String
      time = snapshotValue["TIME"] as! String
      Class = snapshotValue["COURSE"] as! String
      dept = snapshotValue["DEPARTMENT"] as! String
      section = snapshotValue["SECTION"] as! String
      ref = snapshot.ref
   }
   
   func toAnyObject() -> Any {
      return [
         "INSTRUCTOR": instructor,
         "TIME": time,
         "CLASS" : Class,
         "SECTION" : section,
         "DEPT": dept
      ]
   }
}
