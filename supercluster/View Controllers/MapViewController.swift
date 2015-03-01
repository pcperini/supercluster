//
//  MapViewController.swift
//  supercluster
//
//  Created by Patrick Perini on 2/27/15.
//  Copyright (c) 2015 perini-hestin. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    // Maps
    @IBOutlet var mapView: MKMapView?
    var mapViewPinchGestureRecognizer: UIPinchGestureRecognizer? {
        get {
            for recognizer: UIGestureRecognizer in ((self.mapView?.subviews[0] as UIView).gestureRecognizers as [UIGestureRecognizer]) {
                if let pinchRecognizer = recognizer as? UIPinchGestureRecognizer {
                    return pinchRecognizer
                }
            }
            
            return nil
        }
    }
    
    var lastCameraDistance: CLLocationDistance?
    let searchableCameraAltitude: CLLocationDistance = 600_000.00
    var maxCameraAltitude: CLLocationDistance = -1
    
    // Cluster & Viewers
    @IBOutlet var outerRing: RingView?
    @IBOutlet var innerRing: RingView?
    @IBOutlet var innerRingWidthConstraint: NSLayoutConstraint?
    @IBOutlet var innerRingHeightConstraint: NSLayoutConstraint?
    @IBOutlet var outerRingWidthConstraint: NSLayoutConstraint?
    var innerRingInitialSize: CGSize = CGSizeZero
    
    var viewerManager: ViewerManager?
    
    // Shuttle Button
    @IBOutlet var shuttleButton: IconButton?
    @IBOutlet var shuttleButtonVerticalConstraint: NSLayoutConstraint?
    var shuttleButtonIsShowing: Bool = false
    
    // View Lifecycle
    override func viewDidLoad() {
        self.maxCameraAltitude = self.mapView!.camera.altitude
        self.innerRingInitialSize = CGSizeMake(self.innerRingWidthConstraint!.constant, self.innerRingHeightConstraint!.constant)
        
        self.viewerManager = ViewerManager(delegate: self)
        self.mapViewPinchGestureRecognizer?.addTarget(self, action: "mapViewPinchGestureWasRecognized:")
    }
    
    // Gestures
    func mapViewPinchGestureWasRecognized(recognizer: UIPinchGestureRecognizer) {
        switch recognizer.state {
        case UIGestureRecognizerState.Changed:
            self.updateInnerRing(recognizer.scale)
            break
            
        default:
            break
        }
    }
    
    // Responders
    @IBAction func shuttleButtonWasPressed(sender: IconButton) {
        self.sendOutShuttleButton(toBottomEdge: false)
    }
    
    // Visual Updaters
    func updateInnerRing(scale: CGFloat) {
        var modifiedScale = scale * 0.25
        
        var newHeight = modifiedScale * CGFloat(self.maxCameraAltitude / self.mapView!.camera.altitude) * self.innerRingInitialSize.height
        var newWidth = modifiedScale * CGFloat(self.maxCameraAltitude / self.mapView!.camera.altitude) * self.innerRingInitialSize.width
        
        if newWidth > self.outerRingWidthConstraint?.constant {
            newWidth = self.outerRingWidthConstraint!.constant
            newHeight = newWidth
            
            self.bringInShuttleButton()
        } else {
            self.sendOutShuttleButton()
        }
        
        self.innerRingHeightConstraint?.constant = newHeight
        self.innerRingWidthConstraint?.constant = newWidth
        
        self.innerRing?.setNeedsUpdateConstraints()
        self.innerRing?.setNeedsDisplay()
    }
    
    func bringInShuttleButton() {
        self.shuttleButtonIsShowing = true
        self.shuttleButtonVerticalConstraint?.constant = 0
        UIView.animateWithDuration(2.00, animations: {
            self.shuttleButton?.layoutIfNeeded()
            return
        })
    }
    
    func sendOutShuttleButton(toBottomEdge: Bool = true) {
        if !self.shuttleButtonIsShowing {
            return
        }
        
        self.shuttleButtonIsShowing = false
        if toBottomEdge {
            UIView.animate([
                (0.50, {
                    self.shuttleButton?.rotation = 135
                    return
                }),
                
                (2.00, {
                    self.shuttleButtonVerticalConstraint?.constant = toBottomEdge ? -200 : 500
                    self.shuttleButton?.layoutIfNeeded()
                })
            ], completion: {
                self.shuttleButton?.rotation = -45
                return
            })
        } else {
            UIView.animate([
                (0.25, {
                    self.shuttleButtonVerticalConstraint?.constant = toBottomEdge ? -200 : 500
                    self.shuttleButton?.layoutIfNeeded()
                })
            ], completion: {
                self.shuttleButton?.rotation = -45
                self.shuttleButtonVerticalConstraint?.constant = -200
                self.shuttleButton?.setNeedsUpdateConstraints()
                return
            })
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(mapView: MKMapView!, regionDidChangeAnimated animated: Bool) {
        self.updateInnerRing(1.0)
        self.viewerManager?.viewingCoordinate = mapView.centerCoordinate
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var viewerView = ViewerAnnotationView(viewer: annotation as Viewer)
        viewerView.tintColor = UIColor(red: 0.94, green: 0.22, blue: 0.44, alpha: 1.00)
        return viewerView
    }
}

extension MapViewController: ViewerManagerDelegate {
    func viewerManager(viewManager: ViewerManager, didAddCoordinate coordinate: CLLocationCoordinate2D) {
        self.mapView?.addAnnotation(Viewer(coordinate: coordinate))
    }
    
    func viewerManager(viewManager: ViewerManager, didRemoveCoordinate coordinate: CLLocationCoordinate2D) {
        for annotation: MKAnnotation in self.mapView!.annotations as [MKAnnotation] {
            if coordinate == annotation.coordinate {
                self.mapView?.removeAnnotation(annotation)
                break
            }
        }
    }
}
