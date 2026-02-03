//
//  HomeView.swift
//  counts
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var viewModel: CountersViewModel

    @State private var showCreateSheet = false
    @State private var showLimitSheet = false
    @State private var showAboutSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                Group {
                    if viewModel.counters.isEmpty {
                        emptyStateView
                    } else {
                        countersList
                    }
                }
            }
            .navigationTitle("Counts")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showAboutSheet = true
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(Theme.textSecondary)
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if viewModel.canAddCounter {
                            showCreateSheet = true
                        } else {
                            showLimitSheet = true
                        }
                    } label: {
                        Image(systemName: "plus")
                            .foregroundStyle(Theme.textPrimary)
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateCounterView { counter in
                    viewModel.add(counter: counter)
                }
            }
            .sheet(isPresented: $showLimitSheet) {
                limitReachedSheet
            }
            .sheet(isPresented: $showAboutSheet) {
                AboutView()
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Text("No counters yet")
                .font(.headline)
                .foregroundStyle(Theme.textSecondary)
            Text("Tap + to create your first counter")
                .font(.subheadline)
                .foregroundStyle(Theme.textTertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var countersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(Array(viewModel.counters.enumerated()), id: \.element.id) { index, counter in
                    CounterCardView(
                        counter: counter,
                        onIncrement: {
                            if var updated = viewModel.counters.first(where: { $0.id == counter.id }) {
                                updated.manualValue += 1
                                viewModel.update(counter: updated)
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .animation(Theme.gentleSpring.delay(Double(index) * 0.05), value: viewModel.counters.count)
                }
            }
            .padding()
        }
    }

    private var limitReachedSheet: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("Counter Limit Reached")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(Theme.textPrimary)

            Text("You can have up to \(viewModel.maxFreeCounters) counters in the free version.")
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()

            Button("OK") {
                showLimitSheet = false
            }
            .font(.body.weight(.medium))
            .foregroundStyle(Theme.buttonForeground)
            .padding(.horizontal, 32)
            .padding(.vertical, 14)
            .background(Theme.buttonBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(Theme.background)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    HomeView()
        .environmentObject(CountersViewModel())
}
