//
//  Parent.swift
//  News App
//
//  Created by Richard Richard on 7/11/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import CoreData

class Parent: UIViewController {
    let preference: Preferences = Preferences()
    
    static func getThumbnail(sourceURL: NSString) -> UIImage
    {
        print(sourceURL)
        let asset = AVURLAsset(url: NSURL(fileURLWithPath: sourceURL as String) as URL, options: nil)
        print("asset: \(asset)")
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        print("generator: \(imgGenerator)")
        do {
            let cgImg = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            print("cgImg: \(cgImg)")
            let uiImage = UIImage(cgImage: cgImg)
            return uiImage
        } catch let error as NSError {
            print("yang lain")
            print("error: \(error.localizedDescription)")
            return UIImage(named: "Error")!
        }
    }
}
