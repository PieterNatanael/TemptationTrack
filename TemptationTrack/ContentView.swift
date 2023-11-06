//
//  ContentView.swift
//  TemptationTrack
//
//  Created by Pieter Yoshua Natanael on 01/11/23.
//

import SwiftUI

struct ContentView: View {
    @State private var timers: [Date] = []
    @State private var isShowingSplash = true

    var body: some View {
        let previousMonthCount = countInstances(for: .previousMonth)
        let previousYearCount = countInstances(for: .previousYear)
        let daysSinceLastInstance = daysSinceLastTimer()

        return  NavigationStack {
            if isShowingSplash {
                SplashView(isShowingSplash: $isShowingSplash)
            } else {
                VStack {
                    List {
                        Section(header: VStack(alignment: .leading) {
                            Text("Total instance this month: \(previousMonthCount)")
                            Text("Total instance this year: \(previousYearCount)")
                            if let days = daysSinceLastInstance {
                                Text("Days since last instance: \(days)")
                            }
                        }) {
                            ForEach(timers, id: \.self) { timer in
                                Text(formatDate(timer))
                            }
                            .onDelete(perform: deleteTimer)
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .navigationBarTitle("History", displayMode: .large)
                    .navigationBarItems(trailing: Button(action: recordTimer) {
                        Text("Record")
                    })
                    .onAppear {
                        loadTimers()
                    }}
                .onDisappear {
                    saveTimers()
                }}
        }
    }
    
    func recordTimer() {
        timers.append(Date())
    }
    
    func deleteTimer(at offsets: IndexSet) {
        timers.remove(atOffsets: offsets)
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy HH:mm:ss"
        return formatter.string(from: date)
    }
    
    private func loadTimers() {
        if let savedTimersData = UserDefaults.standard.data(forKey: "savedTimers"),
           let savedTimers = try? JSONDecoder().decode([Date].self, from: savedTimersData) {
            timers = savedTimers
        }
    }
    
    private func saveTimers() {
        if let encodedTimers = try? JSONEncoder().encode(timers) {
            UserDefaults.standard.set(encodedTimers, forKey: "savedTimers")
        }
    }

    private func countInstances(for timeFrame: TimeFrame) -> Int {
        let currentDate = Date()
        let calendar = Calendar.current
        let startDate: Date
        let endDate: Date

        switch timeFrame {
            case .previousMonth:
                startDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
                endDate = currentDate
            case .previousYear:
                startDate = calendar.date(byAdding: .year, value: -1, to: currentDate)!
                endDate = currentDate
        }

        return timers.filter { $0 >= startDate && $0 <= endDate }.count
    }
    
    func daysSinceLastTimer() -> Int? {
        guard let lastTimerDate = timers.last else {
            return nil
        }

        let currentDate = Date()
        let calendar = Calendar.current
        if let days = calendar.dateComponents([.day], from: lastTimerDate, to: currentDate).day {
            return days
        }

        return nil
    }
}

enum TimeFrame {
    case previousMonth
    case previousYear
}

struct TimerListView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



