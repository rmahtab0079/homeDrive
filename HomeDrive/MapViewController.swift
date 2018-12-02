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
import SideMenu

class MapViewController: UIViewController, FloatingPanelControllerDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    //var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    
    var fpc: FloatingPanelController!
    var listingsVC: ListingsViewController!
    var backdropTapGesture = UITapGestureRecognizer()
    var surfaceTapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpGoogleMaps()
        setUpFloatingPanel()
        setUpSideMenu()
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
        // Create a GMSCameraPosition
        let camera = GMSCameraPosition.camera(withLatitude: 40.7372003,
                                              longitude: -73.8245359,
                                              zoom: 15.0)
        mapView.camera = camera
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        // hide map until we got a location update
        //mapView.isHidden = true
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = (self as CLLocationManagerDelegate)
        
        /*
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        */
        
        // overlay button on top of Map
        let btn: UIButton = UIButton(type: UIButton.ButtonType.roundedRect)
        btn.frame = CGRect(x: 16, y: 16, width: 48, height: 48)
        let btnIcon = UIImage(named: "menu-128.png")
        btn.setBackgroundImage(btnIcon, for: .normal)
        btn.addTarget(self, action: #selector(onTapMenu(_:)), for: .touchUpInside)
        self.view.addSubview(btn)
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
        fpc.move(to: .half, animated: true)
    }
    
    /* move floating panel to .tip on backdrop tap */
    @objc func handleBackdrop(_ recognizer: UIGestureRecognizer) {
        fpc.move(to: .tip, animated: true)
    }
    
    
    /* Menu tapped event */
    @objc func onTapMenu(_ button: UIButton) {
        performSegue(withIdentifier: "SideMenuNavSegue", sender: UIButton.self)
        /*
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let destinationViewController = storyboard.instantiateViewController(withIdentifier: "MenuNav") as! UISideMenuNavigationController
        present(destinationViewController, animated: true, completion: nil)
        */
    }
    
    func setUpSideMenu() {
        SideMenuManager.default.menuPushStyle = .replace
        SideMenuManager.default.menuPresentMode = .menuSlideIn
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuAlwaysAnimate = true
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
        return [.full, .half, .tip]
    }
    
    public func insetFor(position: FloatingPanelPosition) -> CGFloat? {
        switch position {
        case .full: return 16.0 // A top inset from safe area
        case .half: return 216.0 // A bottom inset from the safe area
        case .tip: return 68.0 // A bottom inset from the safe area
        }
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
            mapView.isMyLocationEnabled = true
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
