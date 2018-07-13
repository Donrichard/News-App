//
//  News.swift
//  News App
//
//  Created by Richard Richard on 7/9/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit

class News {
    var title: String
    var description: String
    var category: String
    var author: String
    var time: Date
    var videoName: UIImageView

    init? (title: String, description: String, category: String, author: String, time: Date, videoName: UIImageView) {
        guard title.characters.count > 0 && title.characters.count < 100 else {
            return nil
        }
        self.title = title
        self.description = description
        self.category = category
        self.author = author
        self.time = time
        self.videoName = videoName
    }
}
