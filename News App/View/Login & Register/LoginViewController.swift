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

class LoginViewController: UIViewController {
    @IBOutlet weak var warning: UILabel!
    @IBOutlet weak var UsernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBackground: UIImageView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signInButton: GIDSignInButton!
    
    @IBAction func forgetPasswordButton(_ sender: Any) {

    }
    @IBAction func loginButton(_ sender: UIButton) {
        login()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = UIColor.CustomColor.Red.baseRed
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupView() {
        UIGraphicsBeginImageContext(self.view.frame.size)
        #imageLiteral(resourceName: "loginBackground4").draw(in: self.view.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.view.backgroundColor = UIColor(patternImage: image)
        
        
        warning.textColor = .black
        
        UsernameTF.delegate = self
        passwordTF.delegate = self
        passwordTF.isSecureTextEntry = true
        loginBtn.layer.borderWidth = 1
        loginBtn.layer.cornerRadius = 5.0
        loginBtn.layer.borderColor = UIColor.red.cgColor
        UsernameTF.layer.cornerRadius = 10.0
        passwordTF.layer.cornerRadius = 10.0
    }
    
    private func login() {
        if isAllTextfieldFilled() {
            let userController: UserController = UserController()
            userController.loginWithCredentials(username: UsernameTF.text!, password: passwordTF.text!) { (isLoginSuccess) in
                if isLoginSuccess {
                    clearAllTextfield()
                } else {
                    passwordTF.text = nil
                    warning.text = Strings.Warning.loginWrongCredentials
                }
            }
        } else {
            warning.text = Strings.Warning.emptyTextfield
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == UsernameTF {
            passwordTF.becomeFirstResponder()
        }
        if textField == passwordTF {
            hideKeyboard()
        }
        return false
    }
}

extension LoginViewController: GIDSignInUIDelegate {
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
}
