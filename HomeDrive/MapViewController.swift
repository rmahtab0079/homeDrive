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
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var fpc: FloatingPanelController!
    var listingsVC: ListingsViewController!
    
    var backdropTapGesture = UITapGestureRecognizer()
    var surfaceTapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpGoogleMaps()
        setUpFloatingPanel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove the views managed by the `FloatingPanelController` object from self.view.
        fpc.removeFromParent()
    }
    
    /***********************************/
    /****** MY CREATED FUNCTIONS *******/
    /***********************************/
    
    /* Configure google maps initial view settings */
    func setUpGoogleMaps() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86, 151.20 at zoom level 6.
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 15)
        mapView.camera = camera
        
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
    }
    
    /* function to set up floating panel above google maps view */
    func setUpFloatingPanel() {
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
        
        
        /* set up tap gestures for surface and backdrop */
        surfaceTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSurface(tapGesture:)))
        fpc.surfaceView.addGestureRecognizer(surfaceTapGesture)
        surfaceTapGesture.isEnabled = (fpc.position == .tip)
        
        backdropTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackdrop(_:)))
        fpc.backdropView.addGestureRecognizer(backdropTapGesture)
    }
    
    /* move floating panel to .full on surface tap */
    @objc func handleSurface(tapGesture recognizer: UIGestureRecognizer) {
        fpc.move(to: .full, animated: true)
    }
    
    /* move floating panel to .tip on backdrop tap */
    @objc func handleBackdrop(_ recognizer: UIGestureRecognizer) {
        fpc.move(to: .tip, animated: true)
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
    
    /***********************************/
    /****** BOILERPLATE FUNCTIONS ******/
    /***********************************/
    
    /* Initialize initial position of floating panel to bottom */
    func floatingPanel(_ vc: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout? {
        return MyFloatingPanelLayout()
    }
    
    // Enable `surfaceTapGesture` only at `tip` position
    func floatingPanelDidChangePosition(_ vc: FloatingPanelController) {
        surfaceTapGesture.isEnabled = (vc.position == .tip)
    }
}

/* Class to configure floating panel positioning */
class MyFloatingPanelLayout: FloatingPanelLayout {
    public var initialPosition: FloatingPanelPosition {
        return .tip
    }
    
    public var supportedPositions: Set<FloatingPanelPosition> {
        return [.full, .tip]
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 300 // A top inset from safe area
        case .half: return 216.0 // A bottom inset from the safe area
        case .tip: return 68.0 // A bottom inset from the safe area
        }
    }
}
