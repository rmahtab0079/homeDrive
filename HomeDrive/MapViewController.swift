//
//  MapViewController.swift
//  HomeDrive
//
//  Created by Matthew on 11/25/18.
//  Copyright © 2018 Matthew. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleMaps
import FloatingPanel

class MapViewController: UIViewController, FloatingPanelControllerDelegate {

    var fpc: FloatingPanelController!
    var listingsVC: ListingsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize a `FloatingPanelController` object.
        fpc = FloatingPanelController()
        
        // Assign self as the delegate of the controller.
        fpc.delegate = self // Optional
        
        // Set a content view controller.
        let listingsVC = storyboard?.instantiateViewController(withIdentifier: "ListingsVC") as! ListingsViewController
        fpc.set(contentViewController: listingsVC)
        
        // Track a scroll view(or the siblings) in the listings view controller.
        fpc.track(scrollView: listingsVC.tableView)
        
        // Add and show the views managed by the `FloatingPanelController` object to self.view.
        fpc.addPanel(toParent: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove the views managed by the `FloatingPanelController` object from self.view.
        fpc.removeFromParent()
    }
    
    /* Initialize initial position of floating panel to bottom */
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return MyFloatingPanelLayout()
    }
    
    /* Sign out event */
    @IBAction func onTapSignOut(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance()?.signOut()
            
            // Set view to login screen
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginVC")
            self.present(loginViewController, animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
}

/* Class to configure floating panel positioning */
class MyFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return 216.0 // A bottom inset from the safe area
        case .tip: return 68.0 // A bottom inset from the safe area
        }
    }
}
