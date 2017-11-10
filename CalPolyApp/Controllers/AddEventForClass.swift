//
//  AddEventForClass.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 11/9/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

class AddEventForClass : UITableViewController, UITextViewDelegate {
   
   @IBOutlet weak var EventTitle: UITextField!
   @IBOutlet weak var EventDueDate: UIDatePicker!
   @IBOutlet weak var EventNotes: UITextView!
   @IBOutlet weak var IsPublic: UISwitch!
   
   var note : Note?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.hideKeyboardWhenTappedAround()
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "AddEventForClass"
      {
         let title = EventTitle.text
         let eventNotes = EventNotes.text
         let isPublic = IsPublic.isOn
         let dueDate = EventDueDate.date
         
         note = Note(isPublic: isPublic, title: title!, note: eventNotes!, dueDate: dueDate)
      }
   }

}

