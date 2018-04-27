//
//  VideoViewController.swift
//  News App
//
//  Created by Richard Richard on 7/22/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import AVKit

class VideoViewController: UIViewController {
    var video: Video?
    @IBOutlet weak var posterImage: UIImageView!
    @IBOutlet weak var posterName: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        posterName.text = video?.author
        let pathData = video?.dataPath
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
        let dataPath = documentsDirectory.appendingPathComponent(pathData!)
        print(dataPath.absoluteString)
        let videoAsset = (AVAsset(url: dataPath))
        let playerItem = AVPlayerItem(asset: videoAsset)
        let player = AVPlayer(playerItem: playerItem)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
    }
    
    func playerDidFinishPlaying() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
