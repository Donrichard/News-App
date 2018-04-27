//
//  Preferences.swift
//  News App
//
//  Created by Richard Richard on 7/11/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import Foundation

class Preferences {
    
    let preference = UserDefaults.standard
    
    enum NameKey: String {
        case username = "USERNAME"
        case password = "PASSWORD"
    }
    
    func setPreferenceUsername(username: String) {
        preference.setValue(username, forKey: NameKey.username.rawValue)
        preference.synchronize()
        Logging.show(msg: "Username is saved")
    }
    
    func setPreferencePassword(username: String) {
        preference.setValue(username, forKey: NameKey.password.rawValue)
        preference.synchronize()
        Logging.show(msg: "Password is saved")
    }
    
    func getPreferenceUsername() -> String {
        if let username = preference.object(forKey: NameKey.username.rawValue) {
            return username as! String
        }else {
            print("Username not exist")
            return ""
        }
    }
    
    func getPreferencePassword() -> String {
        if let password = preference.object(forKey: NameKey.password.rawValue) {
            return password as! String
        }else {
            print("Password not exist")
            return ""
        }
    }
}
