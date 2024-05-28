//
//  SharedData.swift
//  JRNL
//
//  Created by 박지혜 on 5/16/24.
//

import UIKit
import SwiftData

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
    
    // 데이터 삭제 시 인스턴스의 id에 해당하는 데이터를 지움
    func removeSelectedJournalEntry(_ selectedJournalEntry: JournalEntry) {
        journalEntries.removeAll {
            $0.key == selectedJournalEntry.key
        }
    }
    
    func removeJournalEntry(index: Int) {
        journalEntries.remove(at: index)
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        // FileManager.default - 싱글톤 패턴
        return paths[0]
    }
    
    func loadJournalEntriesData() {
        let pathDirectory = getDocumentDirectory() // 유저 경로
        let fileURL = pathDirectory.appendingPathComponent("journalEntriesData.json")
        // 파일 액세스에는 꼭 do-catch문로 작성
        do {
            let data = try Data(contentsOf: fileURL)
            let journalEntriesData = try JSONDecoder().decode([JournalEntry].self, from: data) // 형태만 전달함(self)
            journalEntries = journalEntriesData
        } catch {
            print("Failed to read JSON data: \(error.localizedDescription)")
        }
    }
    
    func saveJournalEntriesData() {
        let pathDirectory = getDocumentDirectory()
        try? FileManager.default.createDirectory(at: pathDirectory, withIntermediateDirectories: true)
        let filePath = pathDirectory.appendingPathComponent("journalEntriesData.json")
        let json = try? JSONEncoder().encode(journalEntries) // encoder는 decoder와 달리 타입을 이미 알고 있음
        do {
            try json!.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
    }
}
