//
//  RegisterViewController.swift
//  News App
//
//  Created by Richard Richard on 7/7/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit
import MessageUI

class RegisterViewController: Parent, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var fullnameTF: UITextField!
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmpasswordTF: UITextField!
    @IBOutlet weak var warning: UILabel!
    @IBOutlet weak var registerBtn: UIButton!
    @IBAction func registerButton(_ sender: Any) {
        if fullnameTF.text == "" {
            warning.text = "Please input your fullname"
        } else if usernameTF.text == "" {
            warning.text = "Please input your username"
        } else if emailTF.text == "" {
            warning.text = "Please input your email"
        } else if passwordTF.text == "" {
            warning.text = "Please input your password"
        } else if confirmpasswordTF.text == "" {
            warning.text = "Please input the confirmation password"
        }else if passwordTF.text != confirmpasswordTF.text {
            warning.text = "Password doesn't match!"
        } else {
            warning.text = ""
            createAlert(title: "Registration Successful", message: "Please check your email to verify the email")
            preference.setPreferenceUsername(username: usernameTF.text!)
            preference.setPreferencePassword(username: passwordTF.text!)
            fullnameTF.text = ""
            usernameTF.text = ""
            emailTF.text = ""
            passwordTF.text = ""
            confirmpasswordTF.text = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.dismissView))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view.addGestureRecognizer(swipeRight)
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "loginBackground4")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        fullnameTF.delegate = self
        usernameTF.delegate = self
        emailTF.delegate = self
        passwordTF.delegate = self
        passwordTF.isSecureTextEntry = true
        confirmpasswordTF.delegate = self
        confirmpasswordTF.isSecureTextEntry = true
        registerBtn.layer.borderWidth = 1
        registerBtn.layer.borderColor = UIColor.red.cgColor
        registerBtn.layer.cornerRadius = 5.0
        self.navigationController?.navigationBar.tintColor = UIColor.red
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fullnameTF {
            usernameTF.becomeFirstResponder()
        }
        if textField == usernameTF {
            emailTF.becomeFirstResponder()
        }
        if textField == emailTF {
            passwordTF.becomeFirstResponder()
        }
        if textField == passwordTF {
            confirmpasswordTF.becomeFirstResponder()
        }
        if textField == confirmpasswordTF {
            self.view.endEditing(true)
            if confirmpasswordTF.text != passwordTF.text {
                warning.text = "Password doesn't match!"
            } else {
                warning.text = ""
            }
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == confirmpasswordTF {
            if confirmpasswordTF.text != passwordTF.text {
                warning.text = "Password doesn't match!"
            } else {
                warning.text = ""
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == confirmpasswordTF {
            if confirmpasswordTF.text != passwordTF.text {
                warning.text = "Password doesn't match!"
            } else {
                warning.text = ""
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    func createAlert (title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in self.performSegue(withIdentifier: "unwindToLogin", sender: self)}))
        self.present(alert, animated: true, completion: nil)
    }
}
