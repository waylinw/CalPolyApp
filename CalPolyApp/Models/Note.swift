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
   let classID: String
   let isPublic: Bool
   let title: String
   let note: String
   let dueDate: Date
   let createDate: Date
   let userID: String
   
   init(isPublic: Bool, title: String, note: String, dueDate: Date) {
      self.isPublic = isPublic
      self.title = title
      self.note = note
      self.dueDate = dueDate
      self.noteID = ""
      self.classID = ""
      self.userID = ""
      self.createDate = Date()
   }
   
//   init(snapshot: FIRDataSnapshot) {
//      noteID = snapshot.key
//      let snapshotValue = snapshot.value as! [String: AnyObject]
//      isPublic = (snapshotValue["IsPublic"] as! String).toBool()!
//
//   }
   
   func toAnyObject() -> Any {
      return [
         "NoteID": noteID,
         "IsPublic": isPublic,
         "Title": title,
         "Note": note,
         "DueDate": dueDate,
         "CreateDate": createDate
      ]
   }
}
