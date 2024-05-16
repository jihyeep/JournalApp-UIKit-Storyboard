//
//  SharedData.swift
//  JRNL
//
//  Created by 박지혜 on 5/16/24.
//

import UIKit

class SharedData {
    static let shared = SharedData() // 싱글톤의 시작
    private var journalEntries: [JournalEntry] // 직접 접근하지 않음 -> 통제가 쉬움
    
    private init() {
        journalEntries = []
    }
    
    func numberOfJournalEntries() -> Int {
        journalEntries.count
    }
    
    func getJournalEntry(index: Int) -> JournalEntry {
        journalEntries[index]
    }
    
    func getAllJournalEntries() -> [JournalEntry] {
        let readOnlyJournalEntries = journalEntries // 원본이 아닌 사본을 주는 형태
        return readOnlyJournalEntries
    }
    
    func addJournalEntry(newJournalEntry: JournalEntry) {
        journalEntries.append(newJournalEntry)
    }
    
    func removeJournalEntry(index: Int) {
        journalEntries.remove(at: index)
    }
}
