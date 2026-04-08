//
//  CounterDetailView.swift
//  Kolvo
//

import SwiftUI

struct CounterDetailView: View {
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: CounterDetailViewModel

    @State private var isEditingName = false
    @State private var editedName = ""
    @State private var showResetConfirmation = false
    @State private var showDeleteConfirmation = false
    @State private var displayValue: Int = 0
    @State private var timer: Timer?
    @State private var incrementScale: CGFloat = 1.0
    @State private var appeared = false
    @State private var selectedUnit: TimeUnit = .days

    init(counter: Counter, onUpdate: @escaping (Counter) -> Void, onDelete: @escaping (Counter) -> Void) {
        _viewModel = StateObject(wrappedValue: CounterDetailViewModel(
            counter: counter,
            onUpdate: onUpdate,
            onDelete: onDelete
        ))
        _selectedUnit = State(initialValue: counter.unit ?? .days)
    }

    var body: some View {
        ZStack {
            Theme.background
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                nameSection

                valueSection

                if viewModel.counter.type == .auto {
                    unitPickerSection
                }

                subtextSection

                Spacer()

                actionsSection

                Spacer()
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Theme.destructive)
                }
            }
        }
        .confirmationDialog("Delete Counter", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                viewModel.delete()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showResetConfirmation) {
            resetConfirmationSheet
        }
        .onAppear {
            editedName = viewModel.counter.name
            selectedUnit = viewModel.counter.unit ?? .days
            updateDisplayValue()
            startTimerIfNeeded()
            withAnimation(Theme.gentleSpring.delay(0.1)) {
                appeared = true
            }
        }
        .onDisappear {
            stopTimer()
        }
        .onChange(of: selectedUnit) { _, newUnit in
            viewModel.updateUnit(newUnit)
            restartTimer()
            withAnimation(Theme.quickSpring) {
                updateDisplayValue()
            }
        }
    }

    private var nameSection: some View {
        Group {
            if isEditingName {
                TextField("Name", text: $editedName)
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.horizontal, 40)
                    .onSubmit {
                        if !editedName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            viewModel.updateName(editedName.trimmingCharacters(in: .whitespacesAndNewlines))
                        } else {
                            editedName = viewModel.counter.name
                        }
                        isEditingName = false
                    }
            } else {
                Text(viewModel.counter.name)
                    .font(.title2)
                    .foregroundStyle(Theme.textSecondary)
                    .onTapGesture {
                        editedName = viewModel.counter.name
                        withAnimation(Theme.quickSpring) {
                            isEditingName = true
                        }
                    }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var valueSection: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("\(displayValue)")
                .font(.system(size: 72, weight: .bold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)
                .contentTransition(.numericText())

            if viewModel.counter.type == .auto {
                Text(displayValue == 1 ? selectedUnit.singularName : selectedUnit.rawValue)
                    .font(.title)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.9)
        .animation(Theme.gentleSpring.delay(0.15), value: appeared)
    }

    private var unitPickerSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TimeUnit.allCases, id: \.self) { unit in
                    Button {
                        withAnimation(Theme.gentleSpring) {
                            selectedUnit = unit
                        }
                    } label: {
                        Text(unit.displayName)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(selectedUnit == unit ? Theme.buttonForeground : Theme.textSecondary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(selectedUnit == unit ? Theme.buttonBackground : Theme.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                    }
                    .buttonStyle(SoftButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .opacity(appeared ? 1 : 0)
        .animation(Theme.gentleSpring.delay(0.18), value: appeared)
    }

    private var subtextSection: some View {
        Text(viewModel.subtextLabel)
            .font(.subheadline)
            .foregroundStyle(Theme.textTertiary)
            .opacity(appeared ? 1 : 0)
            .animation(Theme.gentleSpring.delay(0.2), value: appeared)
    }

    private var actionsSection: some View {
        VStack(spacing: 20) {
            if viewModel.counter.type == .manual {
                Button {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()

                    withAnimation(Theme.quickSpring) {
                        incrementScale = 0.9
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(Theme.gentleSpring) {
                            incrementScale = 1.0
                        }
                    }

                    viewModel.increment()
                    withAnimation(Theme.quickSpring) {
                        updateDisplayValue()
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Theme.buttonForeground)
                        .frame(width: 72, height: 72)
                        .background(Theme.buttonBackground)
                        .clipShape(Circle())
                        .scaleEffect(incrementScale)
                }
                .buttonStyle(.plain)
            }

            Button {
                showResetConfirmation = true
            } label: {
                Text("Reset")
                    .font(.body)
                    .foregroundStyle(Theme.textTertiary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(SoftButtonStyle())
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .animation(Theme.gentleSpring.delay(0.25), value: appeared)
    }

    private var resetConfirmationSheet: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Reset Counter")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(Theme.textPrimary)

            Text(resetMessage)
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            HStack(spacing: 16) {
                Button("Cancel") {
                    showResetConfirmation = false
                }
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.textPrimary)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                Button("Reset") {
                    viewModel.reset()
                    withAnimation(Theme.quickSpring) {
                        updateDisplayValue()
                    }
                    showResetConfirmation = false
                }
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.buttonForeground)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(Theme.buttonBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private var resetMessage: String {
        switch viewModel.counter.type {
        case .manual:
            return "This will set the counter value back to 0."
        case .auto:
            return "This will set the start date to now."
        }
    }

    private func updateDisplayValue() {
        switch viewModel.counter.type {
        case .manual:
            displayValue = viewModel.counter.manualValue
        case .auto:
            displayValue = selectedUnit.calculate(from: viewModel.counter.startDate)
        }
    }

    private func startTimerIfNeeded() {
        guard viewModel.counter.type == .auto else { return }

        let interval = selectedUnit.timerInterval

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

    private func restartTimer() {
        stopTimer()
        startTimerIfNeeded()
    }
}

#Preview {
    NavigationStack {
        CounterDetailView(
            counter: Counter(name: "Sober", type: .auto, startDate: Date().addingTimeInterval(-86400 * 30), unit: .days),
            onUpdate: { _ in },
            onDelete: { _ in }
        )
    }
}
