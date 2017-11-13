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
   let replyRef = FIRDatabase.database().reference(withPath: "Replies")
   var validNoteIds : [String] = []
   var validChildIds = [[String]]()
   var dueDates = [String]()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.title = className
      //first query classnotes
      classForumRef.child(className).observe(.value, with: { snapshot in
         for item in snapshot.children {
            //get every attribute from json from db for use here
            var classNote = (item as? FIRDataSnapshot)?.value as! [String:Any]
            let noteId = (item as? FIRDataSnapshot)?.key as! String
            let id = classNote["UserID"]! as! String
            var childs = classNote["ChildID"] as! [String]
            
            //dummy "None" value put into every empty childIds array since fb doesnt support having empty arrays
            //remove dummy value for this function as we are looking for actual childIds
            childs = childs.filter(){$0 != "None"}
            let pub = classNote["IsPublic"] as! Bool
            
            //only want messages that are public or that the logged in user created
            if pub || id == FIRAuth.auth()!.currentUser!.uid {
               //keeping 2 arrays here; one is for all valid noteIds that are public or belong to logged in user
               //the other array is a 2d array with each sub-array being the list of children (replies) for all posts visible to logged in user
               self.validNoteIds.append(noteId)
               self.validChildIds.append(childs)
            }
         }
         //second query here is to get notes
         self.noteRef.observe(.value, with: { snapshot in
            for item in snapshot.children {
               let noteId = (item as? FIRDataSnapshot)?.key as! String
               
               //append a new noteItem with note we just grabbed from db if it is in the list of validNoteIds
               if self.validNoteIds.contains(noteId) {
                  self.noteItems.append(NoteItem(note: Note(snapshot: item as! FIRDataSnapshot)))
                  
                  //we need unique for the sectionViewer so grab it from the note and only add to array if it does not already contain that date
                  let formatter = DateFormatter()
                  formatter.dateFormat = "yyyy-MM-dd"
                  let myDate = formatter.string(from: Note(snapshot: item as! FIRDataSnapshot).dueDate)
                  
                  if !self.dueDates.contains(myDate) {
                     self.dueDates.append(myDate)
                  }
                  
                  //third sub query is for replies table of db
                  //we have access to noteId so get corresponding list of children (replies) for that note and loop through them to add to our noteItems
                  for kid in self.validChildIds[self.validNoteIds.index(of: noteId)!] {
                     self.replyRef.observe(.value, with: { snapshot in
                        for item in snapshot.children {
                           let replyId = (item as? FIRDataSnapshot)?.key as! String
                           
                           //so look at every single reply and if one matches the one we are currently looking for add it to replies array
                           if replyId == kid {
                              for i in 0 ... self.noteItems.count - 1 {
                                 if self.noteItems[i].note.noteID == Reply(snapshot: item as! FIRDataSnapshot).parentID {
                                    (self.noteItems[i]).replies.append(Reply(snapshot: item as! FIRDataSnapshot))
                                    break
                                 }
                              }
                              //(self.noteItems[self.noteItems.count - 1]).replies.append(Reply(snapshot: item as! FIRDataSnapshot))
                           }
                           self.tableView.reloadData()
                        }
                        
                        // 3 arrays to sort here, the due dates array for section viewing, replies for each note, and the notes themselves
                        self.noteItems.sort(by: {$0.note.dueDate.compare($1.note.dueDate) == .orderedAscending})
                        for i in 0 ... self.noteItems.count - 1 {
                           self.noteItems[i].replies = self.noteItems[i].replies.sorted(by: {$0.createDate.compare($1.createDate) == .orderedAscending})
                        }
                        self.dueDates.sort(by: {$0.compare($1) == .orderedAscending})

                        self.tableView.reloadData()
                     })
                  }
                  self.tableView.reloadData()
               }
            }
         })
      })
   }
   
   override func tableView(_ tableView: UITableView,
                           numberOfRowsInSection section: Int) -> Int {
      return noteItems.count
   }

   override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentEventCells")
      cell?.textLabel?.text = noteItems[indexPath.row].note.title
      return cell!
   }
   
//   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//      // Waylin: i think you probably have to make an identifier for this segue in storyboard like you did for currenteventcells
//      performSegue(withIdentifier: "EventSelectedSegue", sender:indexPath.row)
//   }
//
//   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//      if segue.identifier == "EventSelectedSegue" {
//         let navC = segue.destination as? UINavigationController
//         // Waylin: Need to change the controller name here to for where you want to navigate to
//         let vc = navC?.viewControllers.first as? RepliesForSingleClassController
//         vc?.noteItem = noteItems[sender as! Int]
//      }
//   }
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
      let vals :[String: Any] = ["ChildID": ["None"],
                                 "IsPublic": newEvent.isPublic,
                                 "UserID": FIRAuth.auth()!.currentUser!.uid]
      classForumRef.child(className).child(id).setValue(vals)
      
   }
}
