//
//  CreateGuildMainVC.swift
//  TwoGT
//
//  Created by Arthur Mayes on 11/4/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CreateGuildMainVC: UIViewController {
    
    @IBOutlet weak var nameItButton: UIButton!
    @IBOutlet weak var locateItButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!

    var geotifications: [Geotification] = [] {
        willSet {
            upset()
        }
        didSet {
            set()
        }
    }
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        geotifications = Geotification.allGeotifications()
    }
    

    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toNameIt" {
            let vc = segue.destination as! NameNewCommunityVC
            vc.configure(self)
        } else if segue.identifier == "toLocation" {
            let vc = segue.destination as! GeotificationsViewController
            vc.delegate = self
        }
    }
    
    // MARK: Functions that update the model/associated views with geotification changes
    func set() {
        for g in geotifications {
            mapView.addAnnotation(g)
            addRadiusOverlay(forGeotification: g)
        }
    }
    
    func upset() {
        mapView.removeAnnotations(geotifications)
        for g in geotifications {
            removeRadiusOverlay(forGeotification: g)
        }
    }

    // MARK: Map overlay functions
    func addRadiusOverlay(forGeotification geotification: Geotification) {
      mapView?.addOverlay(MKCircle(center: geotification.coordinate, radius: geotification.radius))
    }
    
    func removeRadiusOverlay(forGeotification geotification: Geotification) {
      // Find exactly one overlay which has the same coordinates & radius to remove
      guard let overlays = mapView?.overlays else { return }
      for overlay in overlays {
        guard let circleOverlay = overlay as? MKCircle else { continue }
        let coord = circleOverlay.coordinate
        if coord.latitude == geotification.coordinate.latitude && coord.longitude == geotification.coordinate.longitude && circleOverlay.radius == geotification.radius {
          mapView?.removeOverlay(circleOverlay)
          break
        }
      }
    }
}

extension CreateGuildMainVC: GeoDelegate {
    func allLocations(_ geos: [Geotification]) {
        self.geotifications = geos
    }
}

// MARK: - MapView Delegate
extension CreateGuildMainVC: MKMapViewDelegate {
  
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    let identifier = "myGeotification"
    if annotation is Geotification {
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKPinAnnotationView
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.canShowCallout = true
        let removeButton = UIButton(type: .custom)
        removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        removeButton.setImage(UIImage(named: "DeleteGeotification")!, for: .normal)
        annotationView?.leftCalloutAccessoryView = removeButton
      } else {
        annotationView?.annotation = annotation
      }
      return annotationView
    }
    return nil
  }
  
  
  func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    if overlay is MKCircle {
      let circleRenderer = MKCircleRenderer(overlay: overlay)
      circleRenderer.lineWidth = 1.0
      circleRenderer.strokeColor = .purple
      circleRenderer.fillColor = UIColor.purple.withAlphaComponent(0.4)
      return circleRenderer
    }
    return MKOverlayRenderer(overlay: overlay)
  }
}

