//
//  LoginViewController.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 2/25/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

   //Outlets
   @IBOutlet weak var textFieldLoginEmail: UITextField!
   @IBOutlet weak var textFieldLoginPassword: UITextField!
   
   let firstTimeLogin = "firstTimeSetup"
   let overview = "overview"
   
    override func viewDidLoad() {
        super.viewDidLoad()
      FIRAuth.auth()!.addStateDidChangeListener() { auth, user in
         if user != nil {
            self.performSegue(withIdentifier: self.firstTimeLogin, sender: nil)
         }
      }
        // Do any additional setup after loading the view.
    }
   
   @IBAction func loginTouched(_ sender: UIButton) {
      FIRAuth.auth()!.signIn(withEmail: textFieldLoginEmail.text!, password: textFieldLoginPassword.text!)
   }
   
   
   @IBAction func registerTouched(_ sender: UIButton) {
      let alert = UIAlertController(title: "Register",
                                    message: "Register",
                                    preferredStyle: .alert)
      
      let saveAction = UIAlertAction(title: "Register",
                                     style: .default) {
                                       action in
                                       let emailField = alert.textFields![0]
                                       let passwordField = alert.textFields![1]
                                       
                                       FIRAuth.auth()!.createUser(withEmail: emailField.text!, password: passwordField.text!) {
                                          user, error in
                                          if error == nil {
                                             FIRAuth.auth()!.signIn(withEmail: self.textFieldLoginEmail.text!, password: self.textFieldLoginPassword.text!)
                                          }
                                       }
      }
      
      let cancelAction = UIAlertAction(title: "Cancel",
                                       style: .default)
      
      alert.addTextField { textEmail in
         textEmail.placeholder = "Enter your email"
      }
      
      alert.addTextField { textPassword in
         textPassword.isSecureTextEntry = true
         textPassword.placeholder = "Enter your password"
      }
      
      alert.addAction(saveAction)
      alert.addAction(cancelAction)
      
      present(alert, animated: true, completion: nil)
   }

}
