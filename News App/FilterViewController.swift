//
//  FilterViewController.swift
//  News App
//
//  Created by Richard Richard on 7/11/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    let location = ["Jakarta", "Tangerang", "Bogor", "Depok", "Bekasi", "Bandung"]
    let categories = ["Traffic", "Crime", "Natural Disaster"]
    var selectedCategories: String?
    var selectedLocation: String?
    var filterLocation: String?
    var filterCategory: String?
    var delegateee: ModalViewControllerDelegate?
    let dropDown = UIPickerView()
    @IBOutlet weak var locationTF: UITextField!
    @IBOutlet weak var categoriesTF: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBAction func searchButton(_ sender: Any) {
        delegateee?.sendLocationFilter(locationFilter: locationTF.text!)
        delegateee?.sendCategoryFilter(categoryFilter: categoriesTF.text!)
        print(locationTF.text)
        print(categoriesTF.text)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationTF.delegate = self
        locationTF.allowsEditingTextAttributes = false
        categoriesTF.delegate = self
        categoriesTF.allowsEditingTextAttributes = false
        searchBtn.layer.cornerRadius = 5.0
        searchBtn.layer.borderWidth = 1
        searchBtn.layer.borderColor = UIColor.red.cgColor
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
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
            } else if categories.contains(textField.text!) {
                let b = categories.index(of: textField.text!)
                dropDown.selectRow(b!, inComponent: 0, animated: true)
            }
        }
        return true
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
