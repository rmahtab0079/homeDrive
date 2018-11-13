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

    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
        //GIDSignIn.sharedInstance().signIn()
    }
}
