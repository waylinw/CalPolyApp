//
//  TagPickerViewController.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 11/11/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

class TagPickerViewController : UITableViewController {
   var tags = ["Notes", "Assignment", "Lab", "Homework", "Exam"]
   var selectedTagIndex: Int?
   var selectedTag: String? {
      didSet {
         if let selectedTag = selectedTag,
            let index = tags.index(of: selectedTag) {
            selectedTagIndex = index
         }
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func tableView(_ tableView: UITableView,
                           numberOfRowsInSection section: Int) -> Int {
      return tags.count
   }
   
   override func tableView(_ tableView: UITableView,
                           cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath)
      cell.textLabel?.text = tags[indexPath.row]
      if indexPath.row == selectedTagIndex {
         cell.accessoryType = .checkmark
      } else {
         cell.accessoryType = .none
      }
      return cell
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      tableView.deselectRow(at: indexPath, animated: true)
      
      if let index = selectedTagIndex {
         let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
         cell?.accessoryType = .none
      }
      
      selectedTag = tags[indexPath.row]
      
      let cell = tableView.cellForRow(at: indexPath)
      cell?.accessoryType = .checkmark
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      
      guard segue.identifier == "SaveSelectedTag",
         let cell = sender as? UITableViewCell,
         let indexPath = tableView.indexPath(for: cell) else {
            return
      }
      
      let index = indexPath.row
      selectedTag = tags[index]
   }
}
