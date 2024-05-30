//
//  JRNLWidget.swift
//  JRNLWidget
//
//  Created by 박지혜 on 5/30/24.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    let modelContext = ModelContext(try! ModelContainer(for: JournalEntry.self,
                                                        configurations:ModelConfiguration(isStoredInMemoryOnly: false)))
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(),
                    journalEntryDate: "JRNL",
                    journalEntryTitle: ""
                    )
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(),
                                journalEntryDate: "JRNL",
                                journalEntryTitle: ""
                                )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        let descriptor = FetchDescriptor<JournalEntry>()
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        
        if let journalEntries = try? modelContext.fetch(descriptor) {
            for minuteOffset in 0 ..< journalEntries.count {
                let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 5, to: currentDate)!
                let entry = SimpleEntry(date: entryDate,
                                        journalEntryDate: journalEntries[minuteOffset].dateString,
                                        journalEntryTitle: journalEntries[minuteOffset].entryTitle)
                entries.append(entry)
            }
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var journalEntryDate: String
    var journalEntryTitle: String
}

struct JRNLWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack {
                Text(entry.journalEntryDate)
                    .font(.headline)
                Text(entry.journalEntryTitle)
                    .font(.body)
            }
        }
    }
}

struct JRNLWidget: Widget {
    let kind: String = "JRNLWidget"
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([JournalEntry.self])
//        let modelContainers: ModelConfiguration
//    }

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                JRNLWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                JRNLWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("JRNLWidget")
        .description("This sidget displays journal entries.")
        .supportedFamilies([.systemMedium, .accessoryRectangular]) // 홈위젯 사이즈, 잠금화면 사이즈
    }
}

#Preview(as: .accessoryRectangular) {
    JRNLWidget()
} timeline: {
    SimpleEntry(date: Date(),
                journalEntryDate: "JRNL",
                journalEntryTitle: "")
    SimpleEntry(date: Date(),
                journalEntryDate: "JRNL",
                journalEntryTitle: "")
}
