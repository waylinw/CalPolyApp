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
   let ref: FIRDatabaseReference?
   
   init(instructor: String, time: String, key: String = " ") {
      self.key = key
      self.instructor = instructor
      self.time = time
      self.ref = nil
   }
   
   init(snapshot: FIRDataSnapshot) {
      key = snapshot.key
      let snapshotValue = snapshot.value as! [String: AnyObject]
      instructor = snapshotValue["INSTRUCTOR"] as! String
      time = snapshotValue["TIME"] as! String
      ref = snapshot.ref
   }
   
   func toAnyObject() -> Any {
      return [
         "INSTRUCTOR": instructor,
         "TIME": time
      ]
   }
}
