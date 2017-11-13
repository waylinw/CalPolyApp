//
//  EventDetailsViewController.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 11/13/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation
import UIKit
import JSQMessagesViewController

class EventDetailsViewController: JSQMessagesViewController {
    var currentNoteItem: NoteItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        senderId = "1234"
        senderDisplayName = "..."
    }
}
