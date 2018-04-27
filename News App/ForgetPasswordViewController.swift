//
//  ForgetPasswordViewController.swift
//  News App
//
//  Created by Richard Richard on 7/12/17.
//  Copyright © 2017 Richard. All rights reserved.
//

import UIKit

class ForgetPasswordViewController: UIViewController {

    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBAction func forgetPasswordButton(_ sender: Any) {
        createAlert(title: "Email Sent!", message: "Please check your email to reset your password")
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
        sendBtn.layer.borderWidth = 1
        sendBtn.layer.borderColor = UIColor.red.cgColor
        sendBtn.layer.cornerRadius = 5.0
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func dismissView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
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
