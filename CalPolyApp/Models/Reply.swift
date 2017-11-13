//
//  Reply.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 11/10/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

struct Reply {
   let createDate: Date
   let note: String
   let parentID: String
   let userID: String
   let replyID: String
   let dateFormatter: DateFormatter
   
   init(note: String, parentID: String, sequenceID: String) {
      self.createDate = Date()
      self.note = note
      self.parentID = parentID
      self.userID = FIRAuth.auth()!.currentUser!.uid
      self.replyID = ""
      
      dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
   }
   
   init(snapshot: FIRDataSnapshot) {
      replyID = snapshot.key
      let sv = snapshot.value as! [String: AnyObject]
      dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss"
      createDate = dateFormatter.date(from: sv["CreateDate"] as! String)!
      note = sv["Note"] as! String
      parentID = sv["ParentID"] as! String
      userID = sv["UserID"] as! String
   }
   
   func toAnyObject() -> Any {
      return [
         "CreateDate": dateFormatter.string(from: createDate),
         "Note": note,
         "ParentID": parentID,
         "UserID": userID,
      ]
   }
}
