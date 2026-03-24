//
//  CountdownCard.swift
//  DuoDash
//
//  Created by Ben Siebert on 24.03.26.
//

import SwiftUI


struct CountdownCard: View {
    @ObservedObject var countdown: Countdown
    
    let cardColor = Color(red: 0.95, green: 0.95, blue: 0.97)
    // Determines if we show confetti
    @State private var showConfetti = false
    @State private var triggerConfettiCounter = 0
    
    var targetDate: Date {
        return countdown.targetDate ?? Date()
    }
    
    var body: some View {
        ZStack {
            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                timelineContent(currentDate: context.date)
            }
            if showConfetti {
                ConfettiView(counter: $triggerConfettiCounter)
                    .allowsHitTesting(false) // Let clicks pass through
            }
        }
        .background(cardColor)
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .padding()
        // Trigger confetti when state changes
        .onChange(of: showConfetti) { newValue in
            if newValue { triggerConfettiCounter += 1 }
        }
    }
    
    @ViewBuilder
    func timelineContent(currentDate: Date) -> some View {
        let isFinished = currentDate >= targetDate
        
        VStack(spacing: 0) {
            
            // --- HEADER ---
            Text(isFinished ? "🎉 Event erreicht!" : "⏳ Countdown bis")
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 20)
            
            Divider().padding(.vertical, 10)
            
            // --- CONTENT ---
            VStack(spacing: 20) {
                if isFinished {
                    // FINISHED STATE
                    VStack(spacing: 10) {
                        Text("Es ist soweit!")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.accentColor)
                        
                        Text("Der Zeitpunkt wurde erreicht.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 30)
                    .onAppear {
                        if !showConfetti {
                            withAnimation { showConfetti = true }
                        }
                    }
                    
                } else {
                    // COUNTDOWN STATE
                    let components = getRemainingComponents(now: currentDate)
                    
                    // Main Countdown Display
                    Text(formatCountdown(components))
                        .font(.system(size: 28, weight: .bold, design: .monospaced)) // Monospaced for steady numbers
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primary)
                        .padding(.horizontal)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5) // Shrink if it gets too wide
                    
                    // Small Labels below
                    HStack(spacing: 0) {
                        LabelText("Y")
                        Spacer()
                        LabelText("M")
                        Spacer()
                        LabelText("D")
                        Spacer()
                        LabelText("h")
                        Spacer()
                        LabelText("m")
                        Spacer()
                        LabelText("s")
                    }
                    .padding(.horizontal, 25)
                    .padding(.bottom, 10)
                }
            }
            .padding(.bottom, 20)
        }
    }
    
    // Helper for the small labels
    func LabelText(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundColor(.gray)
            .frame(width: 20) // Align roughly with the numbers
    }
    
    func getRemainingComponents(now: Date) -> DateComponents {
        return Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: now,
            to: targetDate
        )
    }
    
    func formatCountdown(_ c: DateComponents) -> String {
        // Format: YY:MM:DD:HH:mm:SS
        return String(format: "%02d:%02d:%02d:%02d:%02d:%02d",
                      c.year ?? 0,
                      c.month ?? 0,
                      c.day ?? 0,
                      c.hour ?? 0,
                      c.minute ?? 0,
                      c.second ?? 0)
    }
}

// MARK: - Native SwiftUI Confetti Implementation

struct ConfettiView: View {
    @Binding var counter: Int
    
    var body: some View {
        TimelineView(.animation) { timelineContext in
            Canvas { graphicsContext, size in
                // Use the date from TimelineView
                let time = timelineContext.date.timeIntervalSinceReferenceDate
                
                let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange, .pink]
                
                // Create 50 particles
                for i in 0..<50 {
                    // Random-ish parameters based on index
                    let index = Double(i)
                    let xPos = (index / 50.0) * size.width
                    
                    // Fall speed
                    let speed = 150.0 + (index * 2)
                    
                    // Calculate Y position based on time, looping the height
                    let yPos = (time * speed).truncatingRemainder(dividingBy: size.height + 50) - 20
                    
                    // Swaying motion (sine wave)
                    let xOffset = sin(time * 3 + index) * 15
                    
                    // Create a copy of the context to rotate individual particles
                    var particleContext = graphicsContext
                    
                    let rect = CGRect(x: xPos + xOffset, y: yPos, width: 8, height: 8)
                    
                    // Move context to particle center to rotate it
                    particleContext.translateBy(x: rect.midX, y: rect.midY)
                    particleContext.rotate(by: .degrees(time * 150 + (index * 20)))
                    
                    // Draw
                    let path = Path(ellipseIn: CGRect(x: -4, y: -4, width: 8, height: 8))
                    particleContext.fill(path, with: .color(colors[i % colors.count]))
                }
            }
        }
        .allowsHitTesting(false) // Important: lets you click buttons behind the confetti
    }
}
