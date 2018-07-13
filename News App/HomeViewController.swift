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

class HomeViewController: UIViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ModalViewControllerDelegate {
    
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
    
    func getThumbnail(sourceURL: NSString) -> UIImage
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

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
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
        let dataPath = videos[indexPath.row].value(forKeyPath: "dataPath") as! String

        var thumbnail: UIImage!
        
        if let thumb = imgsChache[indexPath.row] {
            thumbnail = thumb
        } else {
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: dataPath){
                thumbnail = UIImage().getThumbnailFrom(url: URL(string: dataPath)!)
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
}


