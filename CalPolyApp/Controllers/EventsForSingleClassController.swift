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
   let noteRef = FIRDatabase.database().reference(withPath: "Notes")
   let classForumRef = FIRDatabase.database().reference(withPath: "ClassNotes")
   let replyRef = FIRDatabase.database().reference(withPath: "Replies")
   var validNoteIds : [String] = []
   var validChildIds = [[String]]()
   var dueDates = [String]()
   var sectionData: [String: [NoteItem]] = [:]
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.title = className
      
      //first query classnotes
      //notice we use observe here instead of observesingleevent so it gets run at each change of firebase db
      classForumRef.child(className).observe(.value, with: { snapshot in
         //reset these arays each run to prevent dup values
         self.sectionData = [:]
         self.dueDates = []
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
               //first remove old indices and then add new ones
                if let oldIdx = self.validNoteIds.index(of: noteId) {
                    self.validNoteIds.remove(at: oldIdx)
                    self.validChildIds.remove(at: oldIdx)
                }
               
               self.validNoteIds.append(noteId)
               self.validChildIds.append(childs)
            }
         }
         //second query here is to get notes and is only run once, immediately
         //note that firebase queries make use of callbacks that get run in different threads that are guaranteed to run after data is fetched
         //so code after the callback may get run before code inside the callback (even if the callback is at an earlier point in the program)
         self.noteRef.observeSingleEvent(of: .value, with: { snapshot in
            
            for item in snapshot.children {
               //key returned from the note from Notes table we will need this throughout
               let noteId = (item as? FIRDataSnapshot)?.key as! String
               //we only want to display validposts which are ones that are either public or private and created by cur user
               if self.validNoteIds.contains(noteId) {
                  //another query here to get replies
                  self.replyRef.observeSingleEvent(of: .value, with: { snapshot in
                     var curNoteItem = NoteItem(note: Note(snapshot: item as! FIRDataSnapshot))
                     // we only want first 40 characters of title in order to make sure it fits on screen, cut off rest and save to latestText, which gets displayed
                     if curNoteItem.note.title.count <= 40 {
                        curNoteItem.latestText = curNoteItem.note.title
                     }
                     else {
                        curNoteItem.latestText = curNoteItem.note.title.substring(to: curNoteItem.note.title.index(curNoteItem.note.title.startIndex, offsetBy: 40))
                     }
                     //due dates is used by sortedData for displaying sections, and contains only unique values
                     let formatter = DateFormatter()
                     formatter.dateFormat = "yyyy-MM-dd"
                     let myDate = formatter.string(from: Note(snapshot: item as! FIRDataSnapshot).dueDate)
                     if !self.dueDates.contains(myDate) {
                        self.dueDates.append(myDate)
                     }
                     
                     //append all replies to currentNoteItem that it should have
                     for item1 in snapshot.children {
                        let replyId = (item1 as? FIRDataSnapshot)?.key as! String
                        for kid in self.validChildIds[self.validNoteIds.index(of: noteId)!] {
                           if replyId == kid {
                              curNoteItem.replies.append(Reply(snapshot: item1 as! FIRDataSnapshot))
                           }
                        }
                     }
                     //need replies sorted by creation date and due dates sorted as well
                     curNoteItem.replies = curNoteItem.replies.sorted(by: {$0.createDate.compare($1.createDate) == .orderedAscending})
                     self.dueDates.sort(by: {$0.compare($1) == .orderedAscending})
                     
                     //save current curNoteItem to sectionData
                     if self.sectionData[formatter.string(from: curNoteItem.note.dueDate)] == nil {
                        self.sectionData[formatter.string(from: curNoteItem.note.dueDate)] = [curNoteItem]
                     }
                     else {
                        self.sectionData[formatter.string(from: curNoteItem.note.dueDate)]?.append(curNoteItem)
                     }
                     self.tableView.reloadData()
                  })
               }
            }
         })
      })
   }
   
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return sectionData[dueDates[section]]!.count
   }

   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentEventCells")
      cell?.textLabel?.text = sectionData[dueDates[indexPath.section]]![indexPath.row].latestText
      return cell!
   }
   
   override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return dueDates[section]
   }
   
   override func numberOfSections(in tableView: UITableView) -> Int {
      return dueDates.count
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      performSegue(withIdentifier: "ViewDetailEvent", sender:[indexPath.section, indexPath.row])
   }
    
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "ViewDetailEvent" {
         let section = (sender as! [Int])[0]
         let row = (sender as! [Int])[1]
         let vc = segue.destination as? EventDetailsViewController
         vc?.currentNoteItem = sectionData[dueDates[section]]![row]
         vc?.className = self.className
      }
   }
   
   override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
         let noteItemTmp = sectionData[dueDates[indexPath.section]]![indexPath.row]
         //only delete if event belongs to you
         if FIRAuth.auth()!.currentUser!.uid == noteItemTmp.note.userID {
            
            //remove from all 3 tables
            classForumRef.child(className).child(noteItemTmp.note.noteID).removeValue()
            noteRef.child(noteItemTmp.note.noteID).removeValue()
            for kid in noteItemTmp.replies {
               replyRef.child(kid.replyID).removeValue()
            }
            
            //reload the view
            self.validNoteIds = []
            self.validChildIds = []
            self.dueDates = []
            self.sectionData = [:]
            self.tableView.reloadData()
         }
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
      let vals :[String: Any] = ["ChildID": ["None"],
                                 "IsPublic": newEvent.isPublic,
                                 "UserID": FIRAuth.auth()!.currentUser!.uid]
      classForumRef.child(className).child(id).setValue(vals)
   }
}
