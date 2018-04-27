//
//  HomeViewController.swift
//  News App
//
//  Created by Richard Richard on 7/7/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import AVKit
import AVFoundation
import MobileCoreServices
import NotificationCenter

class HomeViewController: Parent, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ModalViewControllerDelegate {
    
    var imgsChache: [UIImage?] = []
    
    @IBOutlet weak var newsTable: UITableView!
    let locationManager = CLLocationManager()
    var locValue = CLLocationCoordinate2D()
    var users: [NSManagedObject] = []
    var videos: [NSManagedObject] = [] {
        didSet {
            imgsChache = videos.map({ (_ ) -> UIImage? in
                return nil
            })
        }
    }
    var filterLocation = ""
    var filterCategory = ""
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "filtering") {
            
            let yourNextViewController = (segue.destination as! FilterViewController)
            yourNextViewController.delegateee = self
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        newsTable.reloadData()
        newsTable.dataSource = self
        newsTable.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startMonitoringSignificantLocationChanges()
        }
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.reloadTable))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.newsTable.addGestureRecognizer(swipeDown)
    }
    
    func reloadTable() {
        newsTable.reloadData()
    }

    func sendCategoryFilter(categoryFilter: String) {
        if categoryFilter != nil {
            filterCategory = categoryFilter
        }
    }
    
    func sendLocationFilter(locationFilter: String) {
        if locationFilter != nil {
            filterLocation = locationFilter
        }
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locValue = manager.location!.coordinate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        let container = coreDataController.persistentContainer.viewContext
        let fetchUser = NSFetchRequest<NSManagedObject> (entityName: "User")
        let fetchVideos = NSFetchRequest<NSManagedObject> (entityName: "Video")
        if filterLocation != "" && filterCategory != "" {
            let locationPredicate = NSPredicate(format: "location == %@", filterLocation)
            let categoryPredicate = NSPredicate(format: "category == %@", filterCategory)
            let andPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [locationPredicate, categoryPredicate])
            fetchVideos.predicate = andPredicate
        } else if filterLocation != "" && filterCategory == "" {
            fetchVideos.predicate = NSPredicate(format: "location == %@", filterLocation)
        } else if filterCategory != "" && filterLocation == "" {
            fetchVideos.predicate = NSPredicate(format: "category == %@", filterCategory)
        }
        filterCategory = ""
        filterLocation = ""
        do {
            users = try container.fetch(fetchUser)
            videos = try container.fetch(fetchVideos)
            videos.sort(by: {($0.value(forKeyPath: "timestamp") as! Date).compare($1.value(forKeyPath: "timestamp") as! Date) == ComparisonResult.orderedDescending })
        } catch let error as NSError {
            print("Error fetching data - \(error)")
        }
        newsTable.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //self.dataToBeSent = videos[indexPath.row] as? Video
        //performSegue(withIdentifier: "showDetail", sender: nil)
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
        let dataPath = videos[indexPath.row].value(forKeyPath: "dataPath") as! NSString
        //let videoData = videos[indexPath.row].value(forKeyPath: "newsVideo") as! NSData
        //let unarchivedDictionary = NSKeyedUnarchiver.unarchiveObject(with: infoDict as Data) as! [String : Any]
        /*if let pickedVid: NSURL = (unarchivedDictionary[UIImagePickerControllerMediaURL] as? NSURL) {
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: AnyObject = paths[0] as AnyObject
            let videoPathTemp = documentsDirectory.appendingPathComponent("temp.mp4") as NSString
        } else {
            print("found nil NSURL")
        }*/
        
        var thumbnail: UIImage!

        if let thumb = imgsChache[indexPath.row] {
            thumbnail = thumb
        } else {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: dataPath as String){
                thumbnail = Parent.getThumbnail(sourceURL: dataPath)
            }else {
                thumbnail = UIImage(named: "videoUnavailableIcon")
            }
        }
        cell.videoName.image = thumbnail

//        if fileManager.fileExists(atPath: dataPath as String){
//            cell.videoName.image = Parent.getThumbnail(sourceURL: dataPath)
//        }else {
//            cell.videoName.image = UIImage(named: "videoUnavailableIcon")
//        }
//        
        cell.titleLabel.text = title
        cell.descriptionLabel.text = desc
        let newDate = Date()
        cell.timestampLabel.text = newDate.offset(from: timestamp)
        cell.locationCategoryLabel.text = "\(String(describing: location)) / \(String(describing: category))"
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func deleteVideo() {
        let fetchRequest: NSFetchRequest<Video> = Video.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try getContext().execute(deleteRequest)
        } catch {
            print(error.localizedDescription)
        }
        videos.removeAll()
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
     func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
