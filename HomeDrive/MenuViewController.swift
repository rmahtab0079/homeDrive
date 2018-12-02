//
//  MenuViewController.swift
//  HomeDrive
//
//  Created by Matthew on 12/1/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class MenuViewController: UIViewController {

    
    @IBOutlet weak var signOutBtn: UIButton!
    @IBOutlet weak var homeownerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // configure button appearance
        signOutBtn.layer.cornerRadius = 5
        signOutBtn.clipsToBounds = true
        homeownerBtn.layer.cornerRadius = 5
        homeownerBtn.clipsToBounds = true
    }
    
    /* Sign out event */
    @IBAction func onSignOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance()?.signOut()
            
            // Set view to login screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            dismiss(animated: true) { () -> Void in
                //Perform segue or push some view with your code
                let window = UIApplication.shared.keyWindow//?.rootViewController = loginViewController
                UIView.transition(with: window!, duration: 0.7, options: .transitionCrossDissolve, animations: {
                    window!.rootViewController = loginViewController
                }, completion: { completed in
                    print("Logged in")
                })
            }
            
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}
