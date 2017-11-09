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
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.title = className
   }
}

extension EventsForSingleClassController {
   @IBAction func cancelToSingleClassController(_ segue: UIStoryboardSegue) {}
   
   @IBAction func addEventToSingleClass(_ segue: UIStoryboardSegue) {
      guard let addEventController = segue.source as? AddEventForClass,
         let newEvent = addEventController.note else {
            return
      }
      
      // Insert class to newEvent
      
      // Insert today's date to newEvent.
      
      // Insert the event into database.
      
      // setup auto update for changes in database.
   }
}
