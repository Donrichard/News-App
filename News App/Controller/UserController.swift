//
//  UserController.swift
//  News App
//
//  Created by Richard Richard on 14/07/18.
//  Copyright © 2018 Richard. All rights reserved.
//

import UIKit

class UserController {
    struct Status {
        static var status: String = "Status"
        static var loggedIn: String = "Logged In"
        static var loggedOut: String = "Logged Out"
    }
    
    func loginWithCredentials(username: String, password: String, onSuccess: ((_ isDataCorrect: Bool)->())) {
        onSuccess(username == password)
    }
    
    func isUserEverLoggedIn() -> Bool {
        if let status = UserDefaults.standard.string(forKey: Status.status) {
            return !status.isEmpty
        }
        return false
    }
    
    func isUserLoggedIn() -> Bool {
        return isUserEverLoggedIn() ? UserDefaults.standard.string(forKey: Status.status) == Status.loggedIn : false
    }
}
