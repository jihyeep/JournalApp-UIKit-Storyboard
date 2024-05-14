//
//  MapViewController.swift
//  JRNL
//
//  Created by 박지혜 on 5/14/24.
//

import UIKit
import CoreLocation
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var sampleJournalEntryData = SampleJournalEntryData()
    var selectedJournalEntry: JournalEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        self.navigationItem.title = "Loading..."
        locationManager.requestLocation()
        
        mapView.delegate = self
        sampleJournalEntryData.createSampleJournalEntryData()
        mapView.addAnnotations(sampleJournalEntryData.journalEntries)
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let myLocation = locations.first {
            let lat = myLocation.coordinate.latitude
            let long = myLocation.coordinate.longitude
            self.navigationItem.title = "Map"
            mapView.region = setInitialRegion(lat: lat, long: long)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // MARK: - MKMapViewDelegate
    // 맵뷰를 가져오면
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        let identifier = "mapAnnotation"
        if annotation is JournalEntry { // is: 타입 체크(값 체크일 경우 ==)
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                // viewDidLoad를 하지 않았기 때문에 직접 만들어줌
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView.canShowCallout = true
                let calloutButton = UIButton(type: .detailDisclosure) // i 버튼 추가
                annotationView.rightCalloutAccessoryView = calloutButton
                return annotationView
            }
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = mapView.selectedAnnotations.first else {
            return
        }
        selectedJournalEntry = annotation as? JournalEntry
        // 세그웨이 호출
        self.performSegue(withIdentifier: "showMapDetail", sender: self)
    }
    
    // MARK: - navigation
    // 세그웨이 호출 시 데이터 전달 -> 맵뷰의 콜아웃에서 데이터 그려짐
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "showMapDetail" else {
            fatalError("Unexpected segue identifier")
        }
        guard let entryDetailViewController = segue.destination as? JournalEntryDetailViewController else {
            fatalError("Unexpected view Controller")
        }
        entryDetailViewController.selectedJournalEntry = selectedJournalEntry
    }
    
    // MARK: - Methods
    func setInitialRegion(lat: CLLocationDegrees, long: CLLocationDegrees) -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long),
                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }

}
