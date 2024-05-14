//
//  ViewController.swift
//  JRNL
//
//  Created by 박지혜 on 5/7/24.
//

import UIKit

class JournalListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    // IB와 연결된 오브젝트(객체)
    @IBOutlet var tableView: UITableView!
    var sampleJournalEntryData = SampleJournalEntryData()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // 샘플 데이터 생성
        sampleJournalEntryData.createSampleJournalEntryData()
        
    }
    
    // MARK: - UITableViewDataSource
    // 특정 섹션에 대한 테이블 뷰의 행 수
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sampleJournalEntryData.journalEntries.count
    }
    
    // 특정 위치에 대한 테이블 뷰 셀 구성 및 반환
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let journalCell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath) as! JournalListTableViewCell
        let journalEntry = sampleJournalEntryData.journalEntries[indexPath.row]
        journalCell.photoImageView.image = journalEntry.photo
        journalCell.dateLabel.text = journalEntry.date.formatted(.dateTime.month().day().year())
        journalCell.titleLabel.text = journalEntry.entryTitle
        return journalCell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            sampleJournalEntryData.journalEntries.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    // MARK: - Methods
    // IB와 연결된 이벤트: 'Cancel'-'Exit'
    @IBAction func unwindNewEntryCancel(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindNewEntrySave(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? AddJournalEntryViewController, let newJournalEntry = sourceViewController.newJournalEntry {
            sampleJournalEntryData.journalEntries.append(newJournalEntry)
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
              let selectedJournalEntryCell = sender as? JournalListTableViewCell,
              let indexPath = tableView.indexPath(for: selectedJournalEntryCell) else {
            fatalError("Could not get indexPath")
        }
        let selectedJournalEntry = sampleJournalEntryData.journalEntries[indexPath.row]
        journalEntryDetailViewController.selectedJournalEntry = selectedJournalEntry
    }
}

