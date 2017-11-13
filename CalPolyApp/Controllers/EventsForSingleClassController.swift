//
//  EventsForSingleClassController.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 11/5/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

class EventsForSingleClassController : UITableViewController {
   var className : String = ""
   var Note1 : [Note] = []
   var noteItems : [NoteItem] = []
   let noteRef = FIRDatabase.database().reference(withPath: "Notes")
   let classForumRef = FIRDatabase.database().reference(withPath: "ClassNotes")
   var validNoteIds : [String] = []
   var validChildIds = [[String]]()
   override func viewDidLoad() {
      super.viewDidLoad()
      self.title = className
      classForumRef.child(className).observe(.value, with: { snapshot in
         // 3
         for item in snapshot.children {
            var classNote = (item as? FIRDataSnapshot)?.value as! [String:Any]
            var noteId = (item as? FIRDataSnapshot)?.key as! String
            var id = classNote["UserID"]! as! String
            var childs = classNote["ChildID"] as! [String]
            var pub = classNote["IsPublic"] as! Bool
            
            if pub == true || id == FIRAuth.auth()!.currentUser!.uid {
               self.validNoteIds.append(noteId)
               self.validChildIds.append(childs)
            }
         }
         
         for noteId in self.validNoteIds {
            self.noteRef.observe(.value, with: { snapshot in
               for item in snapshot.children {
                  var noteId = (item as? FIRDataSnapshot)?.key as! String
                  if self.validNoteIds.contains(noteId) {
                     let noteObj = Note(snapshot: item as! FIRDataSnapshot)
                     
                  }
               }
               
            })
         }
      })
//      for noteId in self.validNoteIds {
//         noteRef.observe(.value, with: { snapshot in
//            print(self.validNoteIds)
//            print(self.validChildIds)
//            for item in snapshot.children {
//               var noteId = (item as? FIRDataSnapshot)?.key as! String
//               print(noteId)
//            }
//
//         })
//      }
   }
   
   struct ClassNote {
      let note: Note
      let latestText: String
      let replies: [Reply]
      
      init(note: Note) {
         self.note = note
         latestText = ""
         replies = []
      }
   }
}

extension EventsForSingleClassController {
   @IBAction func cancelToSingleClassController(_ segue: UIStoryboardSegue) {}
   
   @IBAction func addEventToSingleClass(_ segue: UIStoryboardSegue) {
      guard let addEventController = segue.source as? AddEventForClassController,
         let newEvent = addEventController.note else {
            return
      }
      
      // Insert the event into Notes table.
      let id = noteRef.childByAutoId().key
      noteRef.child(id).setValue(newEvent.toAnyObject())
      
      // Insert an entry into the ClassNotes Table
      let vals :[String: Any] = ["ChildID": "None",
                                 "IsPublic": newEvent.isPublic,
                                 "UserID": FIRAuth.auth()!.currentUser!.uid]
      classForumRef.child(className).child(id).setValue(vals)
      
      //
   }
}
