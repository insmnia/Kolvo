//
//  CounterPagerView.swift
//  Kolvo
//

import SwiftUI

struct CounterPagerView: View {
    @EnvironmentObject private var viewModel: CountersViewModel
    @Binding var selectedIndex: Int
    let onNavigateToDetail: (Counter) -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var timerTick = false
    @State private var timer: Timer?

    private var currentCounter: Counter? {
        let counters = viewModel.counters
        guard selectedIndex >= 0, selectedIndex < counters.count else { return nil }
        return counters[selectedIndex]
    }

    var body: some View {
        GeometryReader { geometry in
            let _ = timerTick
            let pageWidth = geometry.size.width

            HStack(spacing: 0) {
                ForEach(Array(viewModel.counters.enumerated()), id: \.element.id) { index, counter in
                    counterPage(counter: counter, isCurrent: index == selectedIndex)
                        .frame(width: pageWidth)
                }
            }
            .offset(x: -CGFloat(selectedIndex) * pageWidth + dragOffset)
            .gesture(swipeGesture(width: pageWidth))
        }
        .clipped()
        .onAppear { startTimer() }
        .onDisappear { stopTimer() }
        .onChange(of: selectedIndex) { _, _ in restartTimer() }
        .onChange(of: viewModel.counters.count) { _, newCount in
            if selectedIndex >= newCount {
                selectedIndex = max(0, newCount - 1)
            }
        }
    }

    // MARK: - Counter Page

    private func counterPage(counter: Counter, isCurrent: Bool) -> some View {
        VStack(spacing: 16) {
            Text("\(displayValue(for: counter))")
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .contentTransition(.numericText())

            Text(counter.name)
                .font(.title3)
                .foregroundStyle(Theme.textSecondary)

            if counter.type == .auto, let unit = counter.unit {
                Text(displayValue(for: counter) == 1 ? unit.singularName : unit.rawValue)
                    .font(.body)
                    .foregroundStyle(Theme.textTertiary)
            }

            if counter.type == .manual {
                incrementButton(for: counter)
                    .padding(.top, 24)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture {
            if isCurrent {
                onNavigateToDetail(counter)
            }
        }
    }

    // MARK: - Increment Button

    private func incrementButton(for counter: Counter) -> some View {
        Button {
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()

            if var updated = viewModel.counters.first(where: { $0.id == counter.id }) {
                updated.manualValue += 1
                withAnimation(Theme.quickSpring) {
                    viewModel.update(counter: updated)
                }
            }
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 22, weight: .medium))
                .foregroundStyle(Theme.buttonForeground)
                .frame(width: 56, height: 56)
                .background(Theme.buttonBackground)
                .clipShape(Circle())
        }
        .buttonStyle(SoftButtonStyle())
    }

    // MARK: - Swipe Gesture

    private func swipeGesture(width: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                let canGoLeft = selectedIndex > 0
                let canGoRight = selectedIndex < viewModel.counters.count - 1
                let translation = value.translation.width

                if (translation > 0 && !canGoLeft) || (translation < 0 && !canGoRight) {
                    dragOffset = translation * 0.25
                } else {
                    dragOffset = translation
                }
            }
            .onEnded { value in
                let threshold = width * 0.2
                let velocity = value.predictedEndTranslation.width

                withAnimation(Theme.gentleSpring) {
                    if (value.translation.width < -threshold || velocity < -width * 0.5)
                        && selectedIndex < viewModel.counters.count - 1 {
                        selectedIndex += 1
                    } else if (value.translation.width > threshold || velocity > width * 0.5)
                        && selectedIndex > 0 {
                        selectedIndex -= 1
                    }
                    dragOffset = 0
                }
            }
    }

    // MARK: - Display Value

    private func displayValue(for counter: Counter) -> Int {
        switch counter.type {
        case .manual:
            return counter.manualValue
        case .auto:
            let unit = counter.unit ?? .days
            return unit.calculate(from: counter.startDate)
        }
    }

    // MARK: - Timer

    private func startTimer() {
        guard let counter = currentCounter, counter.type == .auto else { return }

        let interval = (counter.unit ?? .days).timerInterval

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            Task { @MainActor in
                withAnimation(Theme.softSpring) {
                    timerTick.toggle()
                }
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func restartTimer() {
        stopTimer()
        startTimer()
    }
}

// MARK: - Page Indicator

struct PageIndicator: View {
    let count: Int
    let currentIndex: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Theme.textSecondary : Theme.textTertiary.opacity(0.3))
                    .frame(
                        width: index == currentIndex ? 8 : 6,
                        height: index == currentIndex ? 8 : 6
                    )
            }
            .animation(Theme.quickSpring, value: currentIndex)
        }
    }
}
