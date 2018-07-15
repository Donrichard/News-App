//
//  User.swift
//  News App
//
//  Created by Richard Richard on 14/07/18.
//  Copyright © 2018 Richard. All rights reserved.
//

import UIKit

class User {
    private var name: String
    private var username: String
    private var email: String
    private var dob: Date
    
    private var news: [News]
    
    init(name: String, username: String, email: String, dob: Date, news: [News]) {
        self.name = name
        self.username = username
        self.email = email
        self.dob = dob
        self.news = news
    }
    
    convenience init() {
        self.init()
    }
    
    public func setName(_ name: String) {
        self.name = name
    }
    
    public func getName() -> String {
        return name
    }
    
    public func setUsername(_ username: String) {
        self.username = username
    }
    
    public func getUsername() -> String {
        return username
    }
    
    public func setEmail(_ email: String) {
        self.email = email
    }
    
    public func getEmail() -> String {
        return email
    }
    
    public func setDob(_ dob: Date) {
        self.dob = dob
    }
    
    public func addNews(_ news: News) {
        self.news.append(news)
    }
    
    public func getNews() -> [News] {
        return news
    }
}
