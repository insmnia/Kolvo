//
//  AboutView.swift
//  Kolvo
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var appeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                Theme.background
                    .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    appInfo

                    contactSection

                    Spacer()

                    privacyLink

                    footer
                }
                .padding()
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundStyle(Theme.textPrimary)
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

    private var appInfo: some View {
        VStack(spacing: 12) {
            Text("Kolvo")
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(Theme.textPrimary)

            Text("Track meaningful numbers, calmly.")
                .font(.body)
                .foregroundStyle(Theme.textSecondary)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
    }

    private var contactSection: some View {
        VStack(spacing: 12) {
            Text("Get in touch")
                .font(.subheadline)
                .foregroundStyle(Theme.textTertiary)

            VStack(spacing: 8) {
                ContactRow(icon: "envelope.fill", label: "Email", value: "yaraslau.blonski@gmail.com", url: "mailto:yaraslau.blonski@gmail.com")
                ContactRow(icon: "paperplane.fill", label: "Telegram", value: "@horekih", url: "https://t.me/horekih")
                ContactRow(icon: "at", label: "X (Twitter)", value: "@horek1h", url: "https://x.com/horek1h")
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(Theme.gentleSpring.delay(0.15), value: appeared)
    }

    private var privacyLink: some View {
        Button {
            if let url = URL(string: "https://insmnia.github.io/kolvo/privacy-policy.html") {
                UIApplication.shared.open(url)
            }
        } label: {
            Text("Privacy Policy")
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
                .underline(color: Theme.textTertiary)
        }
        .opacity(appeared ? 1 : 0)
        .animation(Theme.gentleSpring.delay(0.2), value: appeared)
    }

    private var footer: some View {
        Text("Made with care")
            .font(.caption)
            .foregroundStyle(Theme.textTertiary)
            .opacity(appeared ? 1 : 0)
            .animation(Theme.gentleSpring.delay(0.25), value: appeared)
    }
}

struct ContactRow: View {
    let icon: String
    let label: String
    let value: String
    let url: String

    var body: some View {
        Button {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(Theme.accent)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(Theme.textTertiary)
                    Text(value)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textPrimary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textTertiary)
            }
            .padding(14)
            .background(Theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(SoftButtonStyle())
    }
}

#Preview {
    AboutView()
}
