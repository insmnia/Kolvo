//
//  CreateCounterView.swift
//  Kolvo
//

import SwiftUI

struct CreateCounterView: View {
    @Environment(\.dismiss) private var dismiss

    let onCreate: (Counter) -> Void

    @State private var name = ""
    @State private var counterType: CounterType = .manual
    @State private var startDate = Date()
    @State private var timeUnit: TimeUnit = .days
    @State private var initialValue = 0
    @State private var appeared = false

    private var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        nameSection
                        typeSection
                        configSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("New Counter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textSecondary)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        let counter = Counter(
                            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                            type: counterType,
                            startDate: startDate,
                            manualValue: initialValue,
                            unit: counterType == .auto ? timeUnit : nil
                        )
                        onCreate(counter)
                        dismiss()
                    }
                    .fontWeight(.medium)
                    .foregroundStyle(isValid ? Theme.textPrimary : Theme.textTertiary)
                    .disabled(!isValid)
                }
            }
            .onAppear {
                withAnimation(Theme.gentleSpring.delay(0.1)) {
                    appeared = true
                }
            }
        }
        .presentationDragIndicator(.visible)
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Name")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            TextField("What are you counting?", text: $name)
                .font(.body)
                .padding(14)
                .background(Theme.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var typeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            HStack(spacing: 12) {
                ForEach(CounterType.allCases, id: \.self) { type in
                    Button {
                        withAnimation(Theme.gentleSpring) {
                            counterType = type
                        }
                    } label: {
                        VStack(spacing: 8) {
                            Image(systemName: type == .auto ? "clock" : "hand.tap")
                                .font(.system(size: 20))

                            Text(type.displayName)
                                .font(.subheadline.weight(.medium))

                            Text(type == .auto ? "Tracks time" : "Tap to count")
                                .font(.caption)
                                .foregroundStyle(Theme.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundStyle(counterType == type ? Theme.buttonForeground : Theme.textPrimary)
                        .background(counterType == type ? Theme.buttonBackground : Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(SoftButtonStyle())
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(Theme.gentleSpring.delay(0.15), value: appeared)
    }

    private var configSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if counterType == .auto {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Date")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)

                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(10)
                        .background(Theme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Unit")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(TimeUnit.allCases, id: \.self) { unit in
                                Button {
                                    withAnimation(Theme.quickSpring) {
                                        timeUnit = unit
                                    }
                                } label: {
                                    Text(unit.displayName)
                                        .font(.subheadline.weight(.medium))
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .foregroundStyle(timeUnit == unit ? Theme.buttonForeground : Theme.textPrimary)
                                        .background(timeUnit == unit ? Theme.buttonBackground : Theme.cardBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                                .buttonStyle(SoftButtonStyle())
                            }
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Initial Value")
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)

                    HStack {
                        Button {
                            withAnimation(Theme.quickSpring) {
                                if initialValue > 0 { initialValue -= 1 }
                            }
                        } label: {
                            Image(systemName: "minus")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Theme.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(Theme.cardBackground)
                                .clipShape(Circle())
                        }
                        .buttonStyle(SoftButtonStyle())

                        Spacer()

                        Text("\(initialValue)")
                            .font(.system(size: 32, weight: .semibold, design: .rounded))
                            .foregroundStyle(Theme.textPrimary)
                            .contentTransition(.numericText())

                        Spacer()

                        Button {
                            withAnimation(Theme.quickSpring) {
                                initialValue += 1
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Theme.textPrimary)
                                .frame(width: 44, height: 44)
                                .background(Theme.cardBackground)
                                .clipShape(Circle())
                        }
                        .buttonStyle(SoftButtonStyle())
                    }
                    .padding(16)
                    .background(Theme.cardBackground.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(Theme.gentleSpring.delay(0.2), value: appeared)
    }
}

struct SoftButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(Theme.quickSpring, value: configuration.isPressed)
    }
}

#Preview {
    CreateCounterView { _ in }
}
