//
//  MapViewController.swift
//  JRNL
//
//  Created by 박지혜 on 5/14/24.
//

import UIKit
import CoreLocation
import MapKit
import SwiftData
import SwiftUI

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    let locationManager = CLLocationManager() // 위치 정보 가져옴
//    var sampleJournalEntryData = SampleJournalEntryData() // 샘플 데이터
    var selectedJournalEntry: JournalEntry?
    
    var container: ModelContainer?
    var context: ModelContext?
    
    var annotations: [JournalMapAnnotation] = []
    
    let globeView = UIHostingController(rootView: GlobeView())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 지도의 중심에 장치의 위치를 띄움
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer // 킬로미터로 정보 지정
        self.navigationItem.title = "Loading..."
//        locationManager.requestLocation() // viewIsAppearing 함수로 이동(호출 시점 이동)
        
        mapView.delegate = self // 델리게이트 지정
//        sampleJournalEntryData.createSampleJournalEntryData()
//        mapView.addAnnotations(sampleJournalEntryData.journalEntries) // 핀이 박힘
        
        guard let _container = try? ModelContainer(for: JournalEntry.self) else {
            fatalError("Could not initialize Container")
        }
        container = _container
        context = ModelContext(_container)
        
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        mapView.removeAnnotations(annotations)
        locationManager.requestLocation()
        
        // MARK: - visionOS
        #if os(xrOS)
        addChild(globeView)
        view.addSubview(globeView.view)
        setupConstraints()
        #endif
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       super.viewDidDisappear(animated)
       #if os(xrOS)
       self.children.forEach {
         $0.willMove(toParent: nil)
         $0.view.removeFromSuperview()
         $0.removeFromParent()
       }
       #endif
     }
    
    // MARK: - CLLocationManagerDelegate
    // 성공
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let myLocation = locations.first {
            let lat = myLocation.coordinate.latitude
            let long = myLocation.coordinate.longitude
            self.navigationItem.title = "Map"
            mapView.region = setInitialRegion(lat: lat, long: long)
//            mapView.addAnnotations(SharedData.shared.getAllJournalEntries())
            
            let descrptor = FetchDescriptor<JournalEntry>(predicate: #Predicate { $0.latitude != nil && $0.longitude != nil })
            guard let journalEntries = try? context?.fetch(descrptor) else {
                return
            }
            annotations = journalEntries.map { JournalMapAnnotation(journal: $0) }
            mapView.addAnnotations(annotations)
        }
    }
    // 실패
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // MARK: - MKMapViewDelegate
    // 핀을 누르면 맵뷰를 생성함
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        let identifier = "mapAnnotation"
//        if annotation is JournalEntry { // is: 타입 체크(값 체크일 경우 ==)
        if annotation is JournalMapAnnotation {
            if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
                annotationView.annotation = annotation
                return annotationView
            } else {
                // 이미 있으면 있는 것을 재사용함
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
//        selectedJournalEntry = annotation as? JournalEntry
        selectedJournalEntry = (annotation as? JournalMapAnnotation)?.journal
        
        // 세그웨이 호출
        self.performSegue(withIdentifier: "showMapDetail", sender: self)
    }
    
    // MARK: - navigation
    // 세그웨이가 실행되기 전에 항상 호출됨(세그웨이 호출 시 데이터 전달) -> 맵뷰의 콜아웃에서 데이터 그려짐
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
    // 전체 지도의 축적과 위치 정보를 나타냄
    func setInitialRegion(lat: CLLocationDegrees, long: CLLocationDegrees) -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long),
                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)) // 지도의 단위
    }
    
    // for visionOS
    private func setupConstraints() {
        globeView.view.translatesAutoresizingMaskIntoConstraints = false
        globeView.view.centerXAnchor.constraint(equalTo:
                                                    view.centerXAnchor).isActive = true
        globeView.view.centerYAnchor.constraint(equalTo:
                                                    view.centerYAnchor).isActive = true
        globeView.view.heightAnchor.constraint(equalToConstant: 600.0).isActive =
        true
        globeView.view.widthAnchor.constraint(equalToConstant: 600.0).isActive =
        true
    }

}
