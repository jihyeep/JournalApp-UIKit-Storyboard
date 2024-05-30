//
//  ViewController.swift
//  JRNL
//
//  Created by 박지혜 on 5/7/24.
//

import UIKit
import SwiftData

class JournalListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UISearchResultsUpdating {
    
    // MARK: - Properties
    // IB와 연결된 오브젝트(객체)
    @IBOutlet var collectionView: UICollectionView!
//    var sampleJournalEntryData = SampleJournalEntryData()
    
    let search = UISearchController(searchResultsController: nil)
    var journalEntries: [JournalEntry] = []
    var filteredTableData: [JournalEntry] = []
    
    var container: ModelContainer? // 담는 그릇
    var context: ModelContext? // 담기는 데이터
    let descriptor = FetchDescriptor<JournalEntry>(sortBy: [SortDescriptor<JournalEntry>(\.dateString)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 샘플 데이터 생성
//        sampleJournalEntryData.createSampleJournalEntryData()
//        SharedData.shared.loadJournalEntriesData()
        // 스위프트 데이터
        guard let _container = try? ModelContainer(for: JournalEntry.self) else {
            fatalError("Could not initialize Container")
        }
        container = _container
        context = ModelContext(_container)
        
        fetchJournalEntries()
        
        // 여백 설정
        setupCollectionView()
        
        search.searchResultsUpdater = self
        // 사용자가 검색 인터페이스를 활성화했을 때 배경이 흐려지는지 여부를 결정
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search titles"
        navigationItem.searchController = search
    
    }
    
    // 화면 회전할 때마다 레이아웃 업데이트
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    

    
    // MARK: - UICollectionViewDataSource
    // 특정 섹션에 대한 컬렉션 뷰의 행 수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if search.isActive {
            return self.filteredTableData.count
        } else {
//            return SharedData.shared.numberOfJournalEntries()
            return self.journalEntries.count
        }
    }
    
    // 특정 위치에 대한 컬렉션 뷰 셀 구성 및 반환
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let journalCell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCell", for: indexPath) as! JournalListCollectionViewCell
        
        let journalEntry: JournalEntry
        if self.search.isActive {
            journalEntry = filteredTableData[indexPath.row]
        } else {
//            journalEntry = SharedData.shared.getJournalEntry(index: indexPath.row)
            journalEntry = journalEntries[indexPath.row]
        }
        
        if let photoData = journalEntry.photoData {
            journalCell.photoImageView.image = UIImage(data: photoData) // decoder
        }
        
        journalCell.dateLabel.text = journalEntry.dateString
        journalCell.titleLabel.text = journalEntry.entryTitle
        return journalCell
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let config = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (elements) -> UIMenu? in // nil이 아니면 재사용 가능
            let delete = UIAction(title: "Delete") { [weak self] (action) in
                if let search = self?.search, search.isActive,
                   let selectedJournalEntry = self?.filteredTableData[indexPath.item] {
                    self?.filteredTableData.remove(at: indexPath.item)
//                    SharedData.shared.removeSelectedJournalEntry(selectedJournalEntry)
                    self?.context?.delete(selectedJournalEntry)
                } else {
//                    SharedData.shared.removeJournalEntry(index: indexPath.item)
                    if let selectedJournalEntry = self?.journalEntries[indexPath.item] {
                        self?.journalEntries.remove(at: indexPath.item)
                        self?.context?.delete(selectedJournalEntry)
                    }
                }
//                SharedData.shared.saveJournalEntriesData()
                collectionView.reloadData()
            }
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: [delete])
        }
        return config
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 동적으로 크기 지정
        var columns: CGFloat
        if (traitCollection.horizontalSizeClass == .compact) { // 컴팩트한 화면
            columns = 1
        } else { // 넓은 화면
            columns = 2
        }
        
        let viewWidth = collectionView.frame.width
        let inset = 10.0 // 여백
        let contentWidth = viewWidth - inset * (columns + 1) // viewWidth - 여백 갯수
        let cellWidth = contentWidth / columns
        let cellHeight = 90.0
        return CGSize(width: cellWidth, height: cellHeight)
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
        filteredTableData = /*SharedData.shared.getAllJournalEntries()*/journalEntries.filter { journalEntry in
            journalEntry.entryTitle.lowercased().contains(searchBarText.lowercased())
        }
        self.collectionView.reloadData()
    }
    
    // MARK: - Methods
    // IB와 연결된 이벤트: 'Cancel'-'Exit'
    @IBAction func unwindNewEntryCancel(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func unwindNewEntrySave(segue: UIStoryboardSegue) {
        if let sourceViewController = segue.source as? AddJournalEntryViewController, let newJournalEntry = sourceViewController.newJournalEntry {
//            sampleJournalEntryData.journalEntries.append(newJournalEntry)
//            SharedData.shared.addJournalEntry(newJournalEntry: newJournalEntry)
//            SharedData.shared.saveJournalEntriesData()
            self.context?.insert(newJournalEntry)
            fetchJournalEntries() // 데이터 배치를 다시 함
            // 스유와 다르게 유아이킷은 리로드를 해줘야 함
            collectionView.reloadData()
        } else {
            print("No Entry or Controller")
        }
    }
    
    // 여백 설정
    func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        flowLayout.minimumLineSpacing = 0 // 아이템 간 간격
        flowLayout.minimumLineSpacing = 10 // 라인 넘어가면 10
        collectionView.collectionViewLayout = flowLayout
    }
    
    // 스위프트 데이터에서 조회
    func fetchJournalEntries() {
        // thread safe
        if let journalEntries = try? context?.fetch(descriptor) {
            self.journalEntries = journalEntries
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
              let indexPath = collectionView.indexPath(for: selectedJournalEntryCell) else {
            fatalError("Could not get indexPath")
        }
        
        let selectedJournalEntry: JournalEntry
        if self.search.isActive {
            selectedJournalEntry = filteredTableData[indexPath.row]
        } else {
//            selectedJournalEntry = SharedData.shared.getJournalEntry(index: indexPath.row)
            selectedJournalEntry = journalEntries[indexPath.row]
        }
        journalEntryDetailViewController.selectedJournalEntry = selectedJournalEntry
    }
}

