/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import MapKit
import CoreLocation

struct PreferencesKeys {
  static let savedItems = "savedItems"
}

protocol GeoDelegate {
    func allLocations(_ geos: [Geotification])
}

class GeotificationsViewController: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  var geotifications: [Geotification] = []
  var locationManager = CLLocationManager()
    var delegate: GeoDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    locationManager.delegate = self
    locationManager.requestAlwaysAuthorization()
    loadAllGeotifications()
  }
  
     // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "toAddGeo" {
      let vc = segue.destination as! AddGeotificationViewController
      vc.delegate = self
    }
  }
  
  // MARK: Loading and saving functions
  func loadAllGeotifications() {
    geotifications.removeAll()
    let allGeotifications = Geotification.allGeotifications()
    allGeotifications.forEach { add($0) }
  }
    
    @IBAction func confirmTerritory(_ sender: UIButton) {
        saveAllGeotifications()
        delegate?.allLocations(geotifications)
        dismiss(animated: true, completion: nil)
    }
  
  func saveAllGeotifications() {
    let encoder = JSONEncoder()
    do {
      let data = try encoder.encode(geotifications)
      UserDefaults.standard.set(data, forKey: PreferencesKeys.savedItems)
    } catch {
      print("error encoding geotifications")
    }
  }
  
  // MARK: Functions that update the model/associated views with geotification changes
  func add(_ geotification: Geotification) {
    geotifications.append(geotification)
    mapView.addAnnotation(geotification)
    addRadiusOverlay(forGeotification: geotification)
    updateGeotificationsCount()
  }
  
  func remove(_ geotification: Geotification) {
    guard let index = geotifications.firstIndex(of: geotification) else { return }
    geotifications.remove(at: index)
    mapView.removeAnnotation(geotification)
    removeRadiusOverlay(forGeotification: geotification)
    updateGeotificationsCount()
  }
  
  func updateGeotificationsCount() {
    title = "Geotifications: \(geotifications.count)"
    navigationItem.rightBarButtonItem?.isEnabled = (geotifications.count < 20)
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
  
  // MARK: Other mapview functions
  @IBAction func zoomToCurrentLocation(sender: AnyObject) {
    mapView.zoomToUserLocation()
  }
  
  func region(with geotification: Geotification) -> CLCircularRegion {
    let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
    region.notifyOnEntry = (geotification.eventType == .onEntry)
    region.notifyOnExit = !region.notifyOnEntry
    return region
  }
  
  func startMonitoring(geotification: Geotification) {
    if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
      showAlert(withTitle:"Error", message: "Geofencing is not supported on this device!")
      return
    }
    
    if CLLocationManager.authorizationStatus() != .authorizedAlways {
      let message = """
      Your geotification is saved but will only be activated once you grant
      Geotify permission to access the device location.
      """
      showAlert(withTitle:"Warning", message: message)
    }
    
    let fenceRegion = region(with: geotification)
    locationManager.startMonitoring(for: fenceRegion)
  }

  func stopMonitoring(geotification: Geotification) {
    for region in locationManager.monitoredRegions {
      guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
      locationManager.stopMonitoring(for: circularRegion)
    }
  }
}

// MARK: AddGeotificationViewControllerDelegate
extension GeotificationsViewController: AddGeotificationsViewControllerDelegate {
  
  func addGeotificationViewController(_ controller: AddGeotificationViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, note: String, eventType: Geotification.EventType) {
    controller.dismiss(animated: true, completion: nil)
    let clampedRadius = min(radius, locationManager.maximumRegionMonitoringDistance)
    let geotification = Geotification(coordinate: coordinate, radius: clampedRadius, identifier: identifier, note: note, eventType: eventType)
    add(geotification)
    startMonitoring(geotification: geotification)
    saveAllGeotifications()
  }
  
}

// MARK: - Location Manager Delegate
extension GeotificationsViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    mapView.showsUserLocation = status == .authorizedAlways
  }
  
  func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
    print("Monitoring failed for region with identifier: \(region!.identifier)")
  }
  
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Location Manager failed with the following error: \(error)")
  }
  
}

// MARK: - MapView Delegate
extension GeotificationsViewController: MKMapViewDelegate {
  
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
  
  func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
    // Delete geotification
    let geotification = view.annotation as! Geotification
    remove(geotification)
    saveAllGeotifications()
  }
  
}
