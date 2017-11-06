//
//  OverviewController.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 3/13/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

class OverviewController : UITableViewController {
   var user: User!
   let classListRef = FIRDatabase.database().reference(withPath: "User_Courses")
   var classes = [String]()

   
   override func viewDidLoad() {
      super.viewDidLoad()
      classListRef.child(FIRAuth.auth()!.currentUser!.uid)
         .child("Courses")
         .observe(.value, with: {
            snapshot in
            let enumerator = snapshot.children
            while let rest = enumerator.nextObject() as? FIRDataSnapshot {
               self.classes.append((rest.value as? String)!)
            }
            self.tableView.reloadData()
      })
   }
   
   override func tableView(_ tableView: UITableView,
                           numberOfRowsInSection section: Int) -> Int {
      return classes.count
   }
   
   override func tableView(_ tableView: UITableView,
                           cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentClassList")
      
      cell?.textLabel?.text = classes[indexPath.row]
      
      return cell!
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      performSegue(withIdentifier: "ClassSelectedSegue", sender:indexPath.row)
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "ClassSelectedSegue" {
         let navC = segue.destination as? UINavigationController
         let vc = navC?.viewControllers.first as? EventsForSingleClassController
         vc?.className = classes[sender as! Int]
      }
   }
   
   @IBAction func signoutTouched(_ sender: UIBarButtonItem) {
      try! FIRAuth.auth()!.signOut()
      if let storyboard = self.storyboard {
         let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! CalPolyApp.LoginViewController
         self.present(vc, animated: true, completion: nil)
      }
   }
   
}

extension OverviewController {
   @IBAction func cancelToOverViewController(_ segue: UIStoryboardSegue) {}
   
}
