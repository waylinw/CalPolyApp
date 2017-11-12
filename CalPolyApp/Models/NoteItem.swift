//
//  NoteItem.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 11/10/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

struct NoteItem {
   let note: Note
   let latestText: String
   let replies: [Reply]
   
   init(note: Note) {
      self.note = note
      latestText = ""
      replies = []
   }
}
