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
    @State private var showExplain = false

    var body: some View {
        let previousMonthCount = countInstances(for: .previousMonth)
        let previousYearCount = countInstances(for: .previousYear)
        let daysSinceLastInstance = daysSinceLastTimer()

        return VStack {
            if isShowingSplash {
                SplashView(isShowingSplash: $isShowingSplash)
            } else {
                List {
                   
                    Section(header: VStack(alignment: .leading) {
                        HStack {
                            Text("History")
                                .font(.title.bold())
                            Spacer()
                            Button(action: {
                                showExplain = true
                            }) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1)))
                                    .padding()
                                    .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                            }
                            
                        }
                        Text("Total instance this month: \(previousMonthCount)")
                            .font(.title3)
                        Text("Total instance this year: \(previousYearCount)")
                            .font(.title3)
                        if let days = daysSinceLastInstance {
                            Text("Days since last instance: \(days)")
                                .font(.title3)
                        }
                    }) {
                        ForEach(timers, id: \.self) { timer in
                            Text(formatDate(timer))
                        }
                        .onDelete(perform: {
                            deleteTimer(at: $0)
                            saveTimers() // Call safeTimers() without animation
                        })
                    }
                }
                .listStyle(GroupedListStyle())
//                .navigationBarTitle("History", displayMode: .large)
                .onAppear {
                    loadTimers()
                }

                Spacer() // Push the button to the bottom

                Button(action: recordTimer) {
                    Text("Record")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .font(.title)
                        .background(Color(#colorLiteral(red: 1, green: 0.8323456645, blue: 0.4732058644, alpha: 1))
)
                        .foregroundColor(.black)
                        .cornerRadius(10)
                        .padding()
                        .shadow(color: Color.black.opacity(0.5), radius: 5, x: 0, y: 2)
                }
            }
        }
        .sheet(isPresented: $showExplain) {
            ShowExplainView(onConfirm: {
                showExplain = false
            })
        }
        .onDisappear {
            saveTimers()
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

// MARK: - App Card View
struct AppCardView: View {
    var imageName: String
    var appName: String
    var appDescription: String
    var appURL: String
    
    var body: some View {
        HStack {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(7)
            
            VStack(alignment: .leading) {
                Text(appName)
                    .font(.title3)
                Text(appDescription)
                    .font(.caption)
            }
            .frame(alignment: .leading)
            
            Spacer()
            Button(action: {
                if let url = URL(string: appURL) {
                    UIApplication.shared.open(url)
                }
            }) {
                Text("Try")
                    .font(.headline)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

// MARK: - Explain View
struct ShowExplainView: View {
    var onConfirm: () -> Void

    var body: some View {
        ScrollView {
            VStack {
               HStack{
                   Text("Ads & App Functionality")
                       .font(.title.bold())
                   Spacer()
               }
              
                //ads
                VStack {
                    HStack {
                        Text("Ads")
                            .font(.largeTitle.bold())
                        Spacer()
                    }
                    ZStack {
//                        Image("threedollar")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .cornerRadius(25)
//                            .clipped()
//                            .onTapGesture {
//                                if let url = URL(string: "https://b33.biz/three-dollar/") {
//                                    UIApplication.shared.open(url)
//                                }
//                            }
                    }
                    // App Cards
                    VStack {
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "sos", appName: "SOS Light", appDescription: "SOS Light is designed to maximize the chances of getting help in emergency situations.", appURL: "https://apps.apple.com/app/s0s-light/id6504213303")
                        Divider().background(Color.gray)
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "worry", appName: "Worry Bin", appDescription: "Helps you track, manage, and conquer your worries like never before.", appURL: "https://apps.apple.com/id/app/worry-bin/id6498626727")
                        Divider().background(Color.gray)
                        
                        Divider().background(Color.gray)
                        AppCardView(imageName: "bodycam", appName: "BODYCam", appDescription: "Record videos effortlessly and discreetly.", appURL: "https://apps.apple.com/id/app/b0dycam/id6496689003")
                        Divider().background(Color.gray)
                        // Add more AppCardViews here if needed
                        // App Data
                     
                        
                        AppCardView(imageName: "timetell", appName: "TimeTell", appDescription: "Announce the time every 30 seconds, no more guessing and checking your watch, for time-sensitive tasks.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "SingLoop", appName: "Sing LOOP", appDescription: "Record your voice effortlessly, and play it back in a loop.", appURL: "https://apps.apple.com/id/app/sing-l00p/id6480459464")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "loopspeak", appName: "LOOPSpeak", appDescription: "Type or paste your text, play in loop, and enjoy hands-free narration.", appURL: "https://apps.apple.com/id/app/loopspeak/id6473384030")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "insomnia", appName: "Insomnia Sheep", appDescription: "Design to ease your mind and help you relax leading up to sleep.", appURL: "https://apps.apple.com/id/app/insomnia-sheep/id6479727431")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "dryeye", appName: "Dry Eye Read", appDescription: "The go-to solution for a comfortable reading experience, by adjusting font size and color to suit your reading experience.", appURL: "https://apps.apple.com/id/app/dry-eye-read/id6474282023")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "iprogram", appName: "iProgramMe", appDescription: "Custom affirmations, schedule notifications, stay inspired daily.", appURL: "https://apps.apple.com/id/app/iprogramme/id6470770935")
                        Divider().background(Color.gray)
                        
                        AppCardView(imageName: "worry", appName: "Worry Bin", appDescription: "A place for worry.", appURL: "https://apps.apple.com/id/app/worry-bin/id6498626727")
                        Divider().background(Color.gray)
                    
                    }
                    Spacer()

                   
                   
                }
//                .padding()
//                .cornerRadius(15.0)
//                .padding()
                
                //ads end
                
                
                HStack{
                    Text("App Functionality")
                        .font(.title.bold())
                    Spacer()
                }
               
               Text("""
               •Show statistics about timers, including the total instances for the previous month and year, and days since the last instance.
               •Allow users to record timers, which adds a timestamp to the list of timers.
               •Display the list of recorded timers with the ability to delete individual timers.
               •Implement basic navigation within the app to switch between views.
               •Style the app interface with appropriate fonts, colors, and layouts for a pleasant user experience.
               """)
               .font(.title3)
               .multilineTextAlignment(.leading)
               .padding()
               
               Spacer()
                
                HStack {
                    Text("TemptationTrack is developed by Three Dollar.")
                        .font(.title3.bold())
                    Spacer()
                }

               Button("Close") {
                   // Perform confirmation action
                   onConfirm()
               }
               .font(.title)
               .padding()
               .cornerRadius(25.0)
               .padding()
           }
           .padding()
           .cornerRadius(15.0)
           .padding()
        }
    }
}

struct TimerListView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

/*
//work well but dont want to use navigationstack
import SwiftUI

struct ContentView: View {
    @State private var timers: [Date] = []
    @State private var isShowingSplash = true

    var body: some View {
        let previousMonthCount = countInstances(for: .previousMonth)
        let previousYearCount = countInstances(for: .previousYear)
        let daysSinceLastInstance = daysSinceLastTimer()

        return NavigationStack {
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
                            .onDelete(perform: {
                                deleteTimer(at: $0)
                                saveTimers() // Call safeTimers() without animation
                            })
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .navigationBarTitle("History", displayMode: .large)
                    .onAppear {
                        loadTimers()
                    }

                    Spacer() // Push the button to the bottom

                    Button(action: recordTimer) {
                        Text("Record")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                    }
                }
                .onDisappear {
                    saveTimers()
                }
            }
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


*/

/*
//udah ok namun ada perubahan button dan tambahan ads
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
                            .onDelete(perform: {
                                deleteTimer(at: $0)
                                saveTimers() // Call safeTimers() without animation
                            })
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


*/
