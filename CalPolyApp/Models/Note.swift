//
//  Note.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 10/23/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

struct Note {
   let noteID: String
   let isPublic: Bool
   let title: String
   let note: String
   let dueDate: Date
   let createDate: Date
   let userID: String
   let dateFormatter: DateFormatter
   
   init(isPublic: Bool, title: String, note: String, dueDate: Date) {
      self.isPublic = isPublic
      self.title = title
      self.note = note
      self.dueDate = dueDate
      self.noteID = ""
      self.userID = FIRAuth.auth()!.currentUser!.uid
      self.createDate = Date()
      dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
   }
   
   init(snapshot: FIRDataSnapshot) {
      noteID = snapshot.key
      let sv = snapshot.value as! [String: AnyObject]
      isPublic = (sv["IsPublic"] as! String).toBool()!
      title = sv["Title"] as! String
      note = sv["Note"] as! String
      userID = sv["UserID"] as! String
      
      dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd"
      createDate = dateFormatter.date(from: sv["CreateDate"] as! String)!
      dueDate = dateFormatter.date(from: sv["DueDate"] as! String)!
   }
   
   func toAnyObject() -> Any {
      return [
         "IsPublic": isPublic,
         "Title": title,
         "Note": note,
         "UserID": userID,
         "DueDate": dateFormatter.string(from: dueDate),
         "CreateDate": dateFormatter.string(from: createDate)
      ]
   }
}
