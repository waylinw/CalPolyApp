//
//  User.swift
//  CalPolyApp
//
//  Created by Waylin Wang on 3/12/17.
//  Copyright © 2017 Waylin Wang. All rights reserved.
//

import Foundation

struct User {
    
    let uid: String
    let email: String
    
    init(authData: FIRUser) {
        uid = authData.uid
        email = authData.email!
    }
    
    init(uid: String, email: String) {
        self.uid = uid
        self.email = email
    }
    
}
