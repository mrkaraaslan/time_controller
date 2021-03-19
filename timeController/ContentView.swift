//
//  ContentView.swift
//  timeController
//
//  Created by Mehmet Karaaslan on 20.10.2020.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var clock = Clock()
    let w = UIScreen.main.bounds.width
    
    var body: some View {
        VStack {
            if clock.analog {
                ZStack {
                    Circle().fill(Color(.gray).opacity(0.5))
                    
                    ForEach(0..<60, id:\.self) { number in
                        Rectangle()
                            .fill(Color(.black))
                            .frame(width: 2, height: (number % 5) == 0 ? 15 : 5)
                            .offset(y: (self.w - 60) / 2)
                            .rotationEffect(.init(degrees: Double(number) * 6))
                    }
                    
                    //Hour
                    Rectangle()
                        .fill(Color(.black))
                        .frame(width: 4, height: (w - 140) / 2)
                        .offset(y: -(w - 140) / 4)
                        .rotationEffect(.init(degrees: self.clock.hour * 30))
                    
                    //Second
                    Rectangle()
                        .fill(Color(.black))
                        .frame(width: 2, height: (w - 100) / 2)
                        .offset(y: -(w - 100) / 4)
                        .rotationEffect(.init(degrees: Double(self.clock.minute) * 6))
                    
                    Circle()
                        .fill(Color(.black))
                        .frame(width: 20)
                }
                .frame(width: self.w - 32, height: self.w - 32)
            }
            else {
                HStack {
                    Text("\(self.clock.hourInt)")
                    Text(":")
                    Text("\(clock.minute)")
                }.font(.largeTitle)
            }
            
            HStack {
                Button(action: {
                    self.clock.analog.toggle()
                }) {
                    Image(systemName: "arrow.2.circlepath").imageScale(.large)
                }
                Slider(value: $clock.desiredValue, in: 1...50, step: 1).foregroundColor(.blue)
                Text("\(Int(clock.desiredValue))")
            }
        }
        .padding(16)
        .onAppear() {
            self.clock.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                self.clock.minute += 1
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class Clock: ObservableObject {
    
    @Published var analog = false
    
    @Published var desiredValue = 6.0 {
        didSet {
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(withTimeInterval: desiredValue, repeats: true) { _ in
                self.minute += 1
            }
        }
    }
    
    @Published var hourInt: Int {
        didSet {
            if hourInt == 24 {
                hour = 0
                hourInt = 0
            }
        }
    }
    @Published var hour: Double
    @Published var minute: Int {
        didSet {
            if minute == 60 {
                minute = 0
                hourInt += 1
            }
            else if minute % 12 == 0 {
                hour += 0.2
            }
        }
    }
    
    var timer = Timer()
    
    init() {
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH"
        self.hour = Double(formatter.string(from: date))!
        self.hourInt = Int(formatter.string(from: date))!
        formatter.dateFormat = "mm"
        self.minute = Int(formatter.string(from: date))!
        
        self.hour += Double(self.minute / 12) * 0.2
    }
}
