//
//  UIImage Extensions.swift
//  News App
//
//  Created by Richard Richard on 14/07/18.
//  Copyright © 2018 Richard. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    func getThumbnailFrom(url: URL) -> UIImage
    {
        let asset = AVURLAsset(url: url, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImg = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
            return UIImage(cgImage: cgImg)
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
            return UIImage(named: "Error")!
        }
    }
}
