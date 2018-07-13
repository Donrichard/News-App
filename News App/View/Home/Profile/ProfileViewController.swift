//
//  ProfileViewController.swift
//  News App
//
//  Created by Richard Richard on 7/11/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import CoreData
import MobileCoreServices
import NotificationCenter

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var profileBackground: UIView!
    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var newsTable: UITableView!
    @IBOutlet weak var labelBackground: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    var users: [NSManagedObject] = []
    var videos: [NSManagedObject] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIGraphicsBeginImageContext(self.profileBackground.frame.size)
        UIImage(named: "profileBackground")?.draw(in: self.profileBackground.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.profileBackground.backgroundColor = UIColor(patternImage: image)
        profilePhoto.image = UIImage(named: "profilePicture")
        labelBackground.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
        profilePhoto.contentMode = .scaleToFill
        profilePhoto.image = UIImage(named: "profilePicture")
        labelBackground.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.5)
        nameLabel.textColor = UIColor.white
        nameLabel.backgroundColor = UIColor(white: 0/255.0, alpha: 0)
        usernameLabel.textColor = UIColor(red: 187.0/255.0, green: 23.0/255.0, blue: 25.0/255.0, alpha: 1.0)
        usernameLabel.backgroundColor = UIColor(white: 255.0/255.0, alpha: 0.3)
        newsTable.reloadData()
        newsTable.dataSource = self
        newsTable.delegate = self
        let pencet = UITapGestureRecognizer(target: self, action: #selector(self.openPhotoLibrary))
        profilePhoto.addGestureRecognizer(pencet)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.reloadTable))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view.addGestureRecognizer(swipeDown)
        profilePhoto.isUserInteractionEnabled = true
        self.profilePhoto.layer.cornerRadius = self.profilePhoto.frame.size.width / 2;
        self.profilePhoto.clipsToBounds = true
        self.profilePhoto.layer.borderWidth = 3.0
        self.profilePhoto.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = "Don Richard"
        let preference = Preferences()
        usernameLabel.text = "@\(preference.getPreferenceUsername())"
        let container = coreDataController.persistentContainer.viewContext
        let fetchUser = NSFetchRequest<NSManagedObject> (entityName: "User")
        let fetchVideos = NSFetchRequest<NSManagedObject> (entityName: "Video")
        do {
            users = try container.fetch(fetchUser)
            videos = try container.fetch(fetchVideos)
            videos.sort(by: {($0.value(forKeyPath: "timestamp") as! Date).compare($1.value(forKeyPath: "timestamp") as! Date) == ComparisonResult.orderedDescending })
        } catch let error as NSError {
            print("Error fetching data - \(error)")
        }
        newsTable.reloadData()
    }
    
    func reloadTable() {
        newsTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentsDirectory: URL = URL(fileURLWithPath: paths[0])
        let dataPath = videos[indexPath.row].value(forKeyPath: "dataPath") as! NSString
        let videoAsset = (AVAsset(url: URL(fileURLWithPath: dataPath as String)))
        let playerItem = AVPlayerItem(asset: videoAsset)
        let player = AVPlayer(playerItem: playerItem)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        self.present(playerViewController, animated: true) {
            playerViewController.player!.play()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsCell", for: indexPath) as! NewsTableViewCell
        let title = videos[indexPath.row].value(forKeyPath: "title") as! String
        let desc = videos[indexPath.row].value(forKeyPath: "descr") as! String
        let timestamp = videos[indexPath.row].value(forKeyPath: "timestamp") as! Date
        let location = videos[indexPath.row].value(forKeyPath: "location") as! String
        let category = videos[indexPath.row].value(forKeyPath: "category") as! String
        let dataPath = videos[indexPath.row].value(forKeyPath: "dataPath") as! String
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: dataPath as String) {
            cell.videoName.image = UIImage().getThumbnailFrom(url: URL(string: dataPath)!)
        }else {
            cell.videoName.image = UIImage(named: "videoUnavailableIcon")
        }
        cell.titleLabel.text = title
        cell.descriptionLabel.text = desc
        let newDate = Date()
        cell.timestampLabel.text = newDate.offset(from: timestamp)
        cell.locationCategoryLabel.text = "\(String(describing: location)) / \(String(describing: category))"
        return cell
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        profilePhoto.image = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    func openPhotoLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
