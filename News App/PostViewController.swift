//
//  PostViewController.swift
//  News App
//
//  Created by Richard Richard on 7/20/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MobileCoreServices
import CoreData

class PostViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var dataPath: NSString = ""
    var videoData = NSData()
    var users: [NSManagedObject] = []
    var videos: [NSManagedObject] = []
    var infoDictionary: NSData?
    let location = ["Jakarta", "Tangerang", "Bogor", "Depok", "Bekasi", "Bandung"]
    let categories = ["Traffic", "Crime", "Natural Disaster"]
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    var selectedCategories: String?
    var selectedLocation: String?
    let dropDown = UIPickerView()
    @IBOutlet weak var pickedImage: UIImageView!
    @IBOutlet weak var titleTF: UITextField!
    @IBOutlet weak var additionalDescriptionTF: UITextField!
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var categoriesTF: UITextField!
    @IBOutlet weak var savebtn: UIButton!
    @IBAction func saveNews(_ sender: Any) {
        if dataPath != "" && titleTF.text != "" && locationTF.text != nil && categoriesTF.text != nil {
            addVideo()
            pickedImage.image = UIImage(named: "recordIcon")
            dataPath = ""
            titleTF.text = ""
            additionalDescriptionTF.text = ""
            locationTF.text = ""
            categoriesTF.text = ""
            performSegue(withIdentifier: "backToHomeView", sender: self)
        }
    }
    @IBAction func cancelButton(_ sender: Any) {
        pickedImage.image = UIImage(named: "recordIcon")
        dataPath = ""
        titleTF.text = ""
        additionalDescriptionTF.text = ""
        locationTF.text = ""
        categoriesTF.text = ""
        tabBarController?.selectedIndex = 0
        //performSegue(withIdentifier: "backToHomeView", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        let pencet = UITapGestureRecognizer(target: self, action: #selector(self.openCamera))
        pickedImage.addGestureRecognizer(pencet)
        pickedImage.isUserInteractionEnabled = true
        titleTF.delegate = self
        additionalDescriptionTF.delegate = self
        locationTF.delegate = self
        locationTF.allowsEditingTextAttributes = false
        categoriesTF.delegate = self
        categoriesTF.allowsEditingTextAttributes = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        savebtn.layer.cornerRadius = 5.0
        let container = coreDataController.persistentContainer.viewContext
        let fetchUser = NSFetchRequest<NSManagedObject> (entityName: "User")
        let fetchVideos = NSFetchRequest<NSManagedObject> (entityName: "Video")
        do {
            users = try container.fetch(fetchUser)
            videos = try container.fetch(fetchVideos)
        } catch let error as NSError {
            print("Error fetching data - \(error)")
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.mediaTypes = [kUTTypeMovie as String]
            imagePicker.showsCameraControls = true
            self.show(imagePicker, sender: nil)
            imagePicker.videoMaximumDuration = 30
        } else {
            print("Camera Not available")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let author = Preferences().getPreferenceUsername()
        print(author)
        if let pickedVideo:NSURL = (info[UIImagePickerControllerMediaURL] as? NSURL) {
            let selectorToCall = #selector(PostViewController.videoWasSavedSuccessfully(_:didFinishSavingWithError:context:))
            UISaveVideoAtPathToSavedPhotosAlbum(pickedVideo.relativePath!, self, selectorToCall, nil)
            do {
            videoData = try NSData(contentsOf: pickedVideo as URL)
            print("info: \(info)")
            infoDictionary = NSKeyedArchiver.archivedData(withRootObject: info) as NSData
            } catch (_) {}
            let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
            let documentsDirectory: AnyObject = paths[0] as AnyObject
            let date = Date()
            let calendar = Calendar.current
            let year = calendar.component(.year, from: date)
            let month = calendar.component(.month, from: date)
            let day = calendar.component(.day, from: date)
            let hour = calendar.component(.hour, from: date)
            let minutes = calendar.component(.minute, from: date)
            let seconds = calendar.component(.second, from: date)
            let timestamp = "\(day)-\(month)-\(year)--\(hour):\(minutes):\(seconds)"
            dataPath = documentsDirectory.appendingPathComponent("\(author)-\(timestamp).mp4") as NSString
            videoData.write(toFile: (dataPath as NSString) as String, atomically: false)
            
            self.dismiss(animated: true, completion: nil)
            pickedImage.image = UIImage().getThumbnailFrom(url: URL(string: String(dataPath))!)
        }
    }
    
    func addVideo() {
        print("masuk")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let container = appDelegate.persistentContainer.viewContext
        let videoEntity = NSEntityDescription.entity(forEntityName: "Video", in: container)
        let newVideo = NSManagedObject(entity: videoEntity!, insertInto: container)
        let title = titleTF.text
        let additionalDescription = additionalDescriptionTF.text
        let location = locationTF.text
        let category = categoriesTF.text
        newVideo.setValue(dataPath as String, forKeyPath: "dataPath")
        newVideo.setValue(title, forKeyPath: "title")
        newVideo.setValue(additionalDescription, forKeyPath: "descr")
        newVideo.setValue(location, forKeyPath: "location")
        newVideo.setValue(category, forKeyPath: "category")
        let date = Date()
        newVideo.setValue(date, forKeyPath: "timestamp")
        let preference = Preferences()
        newVideo.setValue(preference.getPreferenceUsername(), forKeyPath: "author")
        do {
            try container.save()
            users.append(newVideo)
        } catch let error as NSError {
            print("Error saving user \(error)")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func videoWasSavedSuccessfully(_ video: String, didFinishSavingWithError error: NSError!, context: UnsafeMutableRawPointer){
        if let theError = error {
            print("An error happened while saving the video = \(theError)")
        } else {
            DispatchQueue.main.async(execute: { () -> Void in
                
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func createDropDownPicker() {
        dropDown.delegate = self
        locationTF.inputView = dropDown
        categoriesTF.inputView = dropDown
        dropDown.backgroundColor = .white
    }
    
    func createKeyboardToolbar() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.barTintColor = .black
        keyboardToolbar.tintColor = .white
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.dismissKeyboard))
        keyboardToolbar.setItems([doneButton], animated: true)
        keyboardToolbar.isUserInteractionEnabled = true
        locationTF.inputAccessoryView = keyboardToolbar
        categoriesTF.inputAccessoryView = keyboardToolbar
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        createDropDownPicker()
        createKeyboardToolbar()
        if textField.text == "" {
            dropDown.selectRow(0, inComponent: 0, animated: true)
        } else {
            if location.contains(textField.text!) {
                let a = location.index(of: textField.text!)
                dropDown.selectRow(a!, inComponent: 0, animated: true)
                print(textField.text!)
                print(a!)
            } else if categories.contains(textField.text!) {
                let b = categories.index(of: textField.text!)
                dropDown.selectRow(b!, inComponent: 0, animated: true)
                print(textField.text!)
                print(b!)
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == titleTF {
            additionalDescriptionTF.becomeFirstResponder()
        }
        if textField == additionalDescriptionTF {
            locationTF.becomeFirstResponder()
        }
        return false
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if locationTF.isFirstResponder {
            return location.count
        } else {
            return categories.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if locationTF.isFirstResponder {
            return location[row]
        } else {
            return categories[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if locationTF.isFirstResponder {
            selectedLocation = location[row]
            locationTF.text = selectedLocation
        } else {
            selectedCategories = categories[row]
            categoriesTF.text = selectedCategories
        }
    }
}
