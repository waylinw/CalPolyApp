//
//  AddEventForClass.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 11/9/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

class AddEventForClassController : UITableViewController, UITextViewDelegate {
   
   @IBOutlet weak var EventTitle: UITextField!
   @IBOutlet weak var EventDueDate: UIDatePicker!
   @IBOutlet weak var EventNotes: UITextView!
   @IBOutlet weak var IsPublic: UISwitch!
   @IBOutlet weak var TagSelected: UILabel!
   @IBOutlet weak var CreateButton: UIButton!
   
   var note : Note?
   var tag : String = "Notes" {
      didSet {
         TagSelected.text = tag
      }
   }
   
   var editNoteItem : NoteItem?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.hideKeyboardWhenTappedAround()
      
      // if editNoteItem is not nil, we are in edit mode, must populate view
      if editNoteItem != nil {
         let oldNote:Note = (editNoteItem?.note)!
         self.EventTitle.text = oldNote.title
         self.EventDueDate.date = oldNote.dueDate
         self.EventNotes.text = oldNote.note
         self.IsPublic.isOn = oldNote.isPublic
         self.TagSelected.text = oldNote.tag
         self.CreateButton.isHidden = true
      }
      else {
         self.navigationItem.rightBarButtonItem = nil
      }
   }
   
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "AddEventForClass" {
         let title = EventTitle.text
         let eventNotes = EventNotes.text
         let isPublic = IsPublic.isOn
         let dueDate = EventDueDate.date
         let tag = TagSelected.text
         
         note = Note(isPublic: isPublic, title: title!, note: eventNotes!, dueDate: dueDate, tag: tag!)
      }
      else if segue.identifier == "FinishEditEvent" {
         editNoteItem?.note.title = EventTitle.text!
         editNoteItem?.note.note = EventNotes.text!
         editNoteItem?.note.isPublic = IsPublic.isOn
         editNoteItem?.note.dueDate = EventDueDate.date
         editNoteItem?.note.tag = TagSelected.text!
      }
   }
}

extension AddEventForClassController {
   @IBAction func unwindWithSelectedTag(segue: UIStoryboardSegue) {
      if let tagPickerViewController = segue.source as? TagPickerViewController,
         let selectedTag = tagPickerViewController.selectedTag {
         tag = selectedTag
      }
   }
}

