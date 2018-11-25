//
//  LoginViewController.swift
//  HomeDrive
//
//  Created by Matthew on 11/13/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        //googleSignInButton.colorScheme = GIDSignInButtonColorScheme.dark
        //GIDSignIn.sharedInstance().signIn()
    }
}
