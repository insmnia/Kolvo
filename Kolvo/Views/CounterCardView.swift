//
//  CounterCardView.swift
//  Kolvo
//

import SwiftUI

struct CounterCardView: View {
    let counter: Counter
    let onIncrement: () -> Void

    @EnvironmentObject private var viewModel: CountersViewModel
    @State private var displayValue: Int = 0
    @State private var timer: Timer?
    @State private var isPressed = false
    @State private var incrementScale: CGFloat = 1.0

    var body: some View {
        NavigationLink {
            CounterDetailView(
                counter: counter,
                onUpdate: { updated in
                    viewModel.update(counter: updated)
                },
                onDelete: { deleted in
                    withAnimation(Theme.gentleSpring) {
                        viewModel.delete(counter: deleted)
                    }
                }
            )
        } label: {
            cardContent
        }
        .buttonStyle(CardButtonStyle())
        .onAppear {
            updateDisplayValue()
            startTimerIfNeeded()
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: counter.manualValue) { _, newValue in
            if counter.type == .manual {
                withAnimation(Theme.quickSpring) {
                    displayValue = newValue
                }
            }
        }
    }

    private var cardContent: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(counter.name)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("\(displayValue)")
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                        .foregroundStyle(Theme.textPrimary)
                        .contentTransition(.numericText())

                    if counter.type == .auto, let unit = counter.unit {
                        Text(displayValue == 1 ? unit.singularName : unit.rawValue)
                            .font(.body)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                Text(subtextLabel)
                    .font(.caption)
                    .foregroundStyle(Theme.textTertiary)
            }

            Spacer()

            if counter.type == .manual {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .soft)
                    generator.impactOccurred()

                    withAnimation(Theme.quickSpring) {
                        incrementScale = 0.85
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(Theme.gentleSpring) {
                            incrementScale = 1.0
                        }
                    }

                    onIncrement()
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Theme.buttonForeground)
                        .frame(width: 44, height: 44)
                        .background(Theme.accent)
                        .clipShape(Circle())
                        .scaleEffect(incrementScale)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var subtextLabel: String {
        switch counter.type {
        case .manual:
            return "all time"
        case .auto:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return "since \(formatter.string(from: counter.startDate))"
        }
    }

    private func updateDisplayValue() {
        switch counter.type {
        case .manual:
            displayValue = counter.manualValue
        case .auto:
            let unit = counter.unit ?? .days
            displayValue = unit.calculate(from: counter.startDate)
        }
    }

    private func startTimerIfNeeded() {
        guard counter.type == .auto else { return }

        let unit = counter.unit ?? .days
        let interval = unit.timerInterval

        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            withAnimation(Theme.softSpring) {
                updateDisplayValue()
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(Theme.quickSpring, value: configuration.isPressed)
    }
}

#Preview {
    CounterCardView(
        counter: Counter(name: "Books Read", type: .manual, manualValue: 12),
        onIncrement: {}
    )
    .environmentObject(CountersViewModel())
    .padding()
    .background(Theme.background)
}
