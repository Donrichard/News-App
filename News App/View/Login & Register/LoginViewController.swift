//
//  LoginViewController.swift
//  News App
//
//  Created by Richard Richard on 7/7/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {
    @IBOutlet weak var warning: UILabel!
    @IBOutlet weak var UsernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBackground: UIImageView!
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    @IBAction func forgetPasswordButton(_ sender: Any) {
        self.view.endEditing(true)
    }
    @IBAction func unwindToLogin(sender: UIStoryboardSegue) {}
    @IBAction func loginButton(_ sender: Any) {
        self.view.endEditing(true)
        verification()
    }
    
    let preference = Preferences()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        UIGraphicsBeginImageContext(self.view.frame.size)
        UIImage(named: "loginBackground4")?.draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        warning.textColor = .black
        self.view.endEditing(true)
        UsernameTF.delegate = self
        passwordTF.delegate = self
        passwordTF.isSecureTextEntry = true
        loginBtn.layer.borderWidth = 1
        loginBtn.layer.cornerRadius = 5.0
        loginBtn.layer.borderColor = UIColor.red.cgColor
        UsernameTF.layer.cornerRadius = 10.0
        passwordTF.layer.cornerRadius = 10.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let statusBar : UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor(red: 187.0/255.0, green: 23.0/255.0, blue: 25.0/255.0, alpha: 0)
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tap)
        self.navigationController?.isNavigationBarHidden = true
        if UsernameTF.text != "" && passwordTF.text != "" {
            if validateID() == true {
                UsernameTF.text = ""
                passwordTF.text = ""
                performSegue(withIdentifier: "loginSuccess", sender: nil)
            } else {
                UsernameTF.text = ""
                passwordTF.text = ""
            }
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            // ...
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        // ...
        Auth.auth().signIn(with: credential) { (user, error) in
            if let error = error {
                // ...
                return
            }
            // User is signed in
            // ...
        }
    }
    
    

    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == UsernameTF {
            passwordTF.becomeFirstResponder()
        }
        if textField == passwordTF {
            self.view.endEditing(true)
            verification()
        }
        return false
    }
    
    func checkID() -> Bool {
        if preference.getPreferenceUsername() != nil && preference.getPreferencePassword() != nil {
            return true
        } else {
            return false
        }
    }
    
    func validateID() -> Bool {
        if checkID() == true {
            if preference.getPreferenceUsername() == UsernameTF.text && preference.getPreferencePassword() == passwordTF.text{
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func verification() {
        if UsernameTF.text == "" && passwordTF.text == "" {
            warning.text = "Please input your Username and Password"
        } else if UsernameTF.text == "" {
            warning.text = "Please input your Username"
        } else if passwordTF.text == "" {
            warning.text = "Please input your Password"
        } else {
            if validateID() == true {
                UsernameTF.text = ""
                passwordTF.text = ""
                performSegue(withIdentifier: "loginSuccess", sender: nil)
            } else {
                passwordTF.text = ""
                warning.text = "Username / password is wrong"
            }
        }
    }
}

