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
    var messages = [JSQMessage]()
    var className : String = ""
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    let replyRef = FIRDatabase.database().reference(withPath: "Replies")
    let classForumRef = FIRDatabase.database().reference(withPath: "ClassNotes")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = currentNoteItem?.note.title
        
        senderId = FIRAuth.auth()!.currentUser!.uid
        senderDisplayName = "Me"
        
        inputToolbar.contentView.leftBarButtonItem = nil
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        
        //initial note
        let firstMsgName = currentNoteItem?.note.userID == senderId ? "Me" : currentNoteItem?.note.userID
        messages.append(JSQMessage(senderId: currentNoteItem?.note.userID, senderDisplayName: firstMsgName, date: currentNoteItem?.note.createDate, text: currentNoteItem?.note.note))
        
        //rest of replies
        currentNoteItem?.replies.forEach({ (reply) in
            messages.append(JSQMessage(senderId: reply.userID, senderDisplayName: reply.userID, date: reply.createDate, text: reply.note))
        })
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath)
            as! JSQMessagesCollectionViewCell
        cell.textView!.font = UIFont.systemFont(ofSize: 18.0)
        cell.textView!.textColor = UIColor.black
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return messages[indexPath.item].senderId == senderId ? nil : NSAttributedString(string: messages[indexPath.item].senderDisplayName)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return messages[indexPath.item].senderId == senderId ? 0 : 15
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        //insert into Reply
        let replyID = replyRef.childByAutoId().key
        let replyInsert = Reply(note: text, parentID: (currentNoteItem?.note.noteID)!)
        replyRef.child(replyID).setValue(replyInsert.toAnyObject())

        
        //update Main Note Object
        var childIDs = currentNoteItem?.replies.map {$0.replyID}
        childIDs?.append(replyID)
        classForumRef.child(className).child((currentNoteItem?.note.noteID)!).child("ChildID").setValue(childIDs)
        
        currentNoteItem?.replies.append(replyInsert)
        messages.append(JSQMessage(senderId: FIRAuth.auth()!.currentUser!.uid, senderDisplayName: "Me", date: replyInsert.createDate, text: replyInsert.note))
        finishSendingMessage()
    }
}
