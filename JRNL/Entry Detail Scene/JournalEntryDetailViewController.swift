//
//  JournalEntryDetailViewController.swift
//  JRNL
//
//  Created by 박지혜 on 5/10/24.
//

import UIKit
import MapKit

class JournalEntryDetailViewController: UITableViewController {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyTextView: UITextView!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var mapImageView: UIImageView!
    
    var selectedJournalEntry: JournalEntry?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dateLabel.text = selectedJournalEntry?.date.formatted(
            .dateTime.year().month(.wide).day()
        )
        titleLabel.text = selectedJournalEntry?.entryTitle
        bodyTextView.text = selectedJournalEntry?.entryBody
        photoImageView.image = selectedJournalEntry?.photo
        getMapSnapshot()
    }
    
    // MARK: - Private Methods
    private func getMapSnapshot() {
        if let lat = selectedJournalEntry?.latitude,
           let long = selectedJournalEntry?.longitude {
            let options = MKMapSnapshotter.Options()
            options.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            options.size = CGSize(width: 300, height: 300)
            options.preferredConfiguration = MKStandardMapConfiguration()
            let snapShotter = MKMapSnapshotter(options: options)
            snapShotter.start { snapShot, error in
                if let snapshot = snapShot {
                    self.mapImageView.image = snapshot.image
                } else if let error = error {
                    print("snapShot error: \(error.localizedDescription)")
                }
            }
        } else {
            self.mapImageView.image = UIImage(systemName: "map")
        }
    }

    /*
    // MARK: - Table view data source
    // 섹션
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    // 로우
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 7
    }
    */

}
