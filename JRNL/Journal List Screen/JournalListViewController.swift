//
//  ViewController.swift
//  JRNL
//
//  Created by 박지혜 on 5/7/24.
//

import UIKit

class JournalListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    // MARK: - Properties
    // IB와 연결된 오브젝트(객체)
    @IBOutlet var tableView: UITableView!
//    var sampleJournalEntryData = SampleJournalEntryData()
    
    let search = UISearchController(searchResultsController: nil)
    var filteredTableData: [JournalEntry] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 샘플 데이터 생성
//        sampleJournalEntryData.createSampleJournalEntryData()
        SharedData.shared.loadJournalEntriesData()
        
        search.searchResultsUpdater = self
        // 사용자가 검색 인터페이스를 활성화했을 때 배경이 흐려지는지 여부를 결정
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search titles"
        navigationItem.searchController = search
    
    }
    
    // MARK: - UITableViewDataSource
    // 특정 섹션에 대한 테이블 뷰의 행 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search.isActive {
            return self.filteredTableData.count
        } else {
            return SharedData.shared.numberOfJournalEntries()
        }
    }
    
    // 특정 위치에 대한 테이블 뷰 셀 구성 및 반환
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let journalCell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath) as! JournalListCollectionViewCell
        
        let journalEntry: JournalEntry
        if self.search.isActive {
            journalEntry = filteredTableData[indexPath.row]
        } else {
            journalEntry = SharedData.shared.getJournalEntry(index: indexPath.row)
        }
        
//        journalCell.photoImageView.image = journalEntry.photo
        if let photoData = journalEntry.photoData {
            journalCell.photoImageView.image = UIImage(data: photoData) // decoder
        }
//        journalCell.dateLabel.text = journalEntry.date.formatted(.dateTime.month().day().year())
        journalCell.dateLabel.text = journalEntry.dateString
        journalCell.titleLabel.text = journalEntry.entryTitle
        return journalCell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if self.search.isActive {
                let selectedJournalEntry = filteredTableData[indexPath.row]
                // 필터링된 데이터에서 특정 데이터 삭제
                filteredTableData.remove(at: indexPath.row)
                SharedData.shared.removeSelectedJournalEntry(selectedJournalEntry)
            } else {
                SharedData.shared.removeJournalEntry(index: indexPath.row)
            }
            
            SharedData.shared.saveJournalEntriesData()
            tableView.reloadData()
        }
    }
    
    // MARK: - UISearchResultsUpdating
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text else {
            return
        }
        filteredTableData.removeAll()
        // 명령형 - 문제 발생 시 break 가능
//        for journalEntry in SharedData.shared.getAllJournalEntries() {
//            if journalEntry.entryTitle.lowercased().contains(searchBarText.lowercased()) {
//                filteredTableData.append(journalEntry)
//            }
//        }
        // 선언형(고차함수 사용) - 문제 발생 시 break 불가능
        filteredTableData = SharedData.shared.getAllJournalEntries().filter { journalEntry in
            journalEntry.entryTitle.lowercased().contains(searchBarText.lowercased())
        }
        self.tableView.reloadData()
    }
    
    // MARK: - Methods
    // IB와 연결된 이벤트: 'Cancel'-'Exit'
    @IBAction func unwindNewEntryCancel(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindNewEntrySave(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? AddJournalEntryViewController, let newJournalEntry = sourceViewController.newJournalEntry {
//            sampleJournalEntryData.journalEntries.append(newJournalEntry)
            SharedData.shared.addJournalEntry(newJournalEntry: newJournalEntry)
            SharedData.shared.saveJournalEntriesData()
            // 스유와 다르게 유아이킷은 리로드를 해줘야 함
            tableView.reloadData()
        } else {
            print("No Entry or Controller")
        }
    }
    
    // MARK: - Navigation
    // 세그웨이가 호출될 때 아래 함수가 실행됨
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        super.prepare(for: segue, sender: sender)
        guard segue.identifier == "entryDetail" else {
            return
        }
        guard let journalEntryDetailViewController = segue.destination as? JournalEntryDetailViewController,
              let selectedJournalEntryCell = sender as? JournalListCollectionViewCell,
              let indexPath = tableView.indexPath(for: selectedJournalEntryCell) else {
            fatalError("Could not get indexPath")
        }
        
        let selectedJournalEntry: JournalEntry
        if self.search.isActive {
            selectedJournalEntry = filteredTableData[indexPath.row]
        } else {
            selectedJournalEntry = SharedData.shared.getJournalEntry(index: indexPath.row)
        }
        journalEntryDetailViewController.selectedJournalEntry = selectedJournalEntry
    }
}

