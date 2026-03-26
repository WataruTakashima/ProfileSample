//
//  ProfileEditView.swift
//  ProfileSample
//
//  Created by w.t on 2026/03/26.
//

import SwiftUI

// MARK: - Root View

struct ProfileEditView: View {
    @State private var name = "アレックス・ジョンソン"
    @State private var email = "alex.johnson@example.com"
    @State private var bio = "サンフランシスコを拠点とするプロダクトデザイナー。クリーンなインターフェースとユーザーエクスペリエンスに情熱を注いでいます。"
    @State private var pushNotificationsEnabled = true
    @State private var isPublicProfile = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ProfileImageSection()

                PersonalInfoSection(
                    name: $name,
                    email: $email,
                    bio: $bio
                )

                SettingsSection(
                    pushNotificationsEnabled: $pushNotificationsEnabled,
                    isPublicProfile: $isPublicProfile
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 24)
        }
        .background(Color(red: 0.05, green: 0.05, blue: 0.18).ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            SaveButton {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .navigationTitle("プロフィール編集")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.05, green: 0.05, blue: 0.18), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

// MARK: - Profile Image Section

private struct ProfileImageSection: View {
    var body: some View {
        HStack {
            Spacer()
            ZStack(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(red: 0.3, green: 0.4, blue: 0.45))
                    .frame(width: 110, height: 110)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    .overlay {
                        Circle().stroke(Color.blue, lineWidth: 3)
                    }

                Button {
                    // 画像選択アクション（学習用サンプルのため未実装）
                } label: {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .offset(x: 4, y: 4)
            }
            Spacer()
        }
    }
}

// MARK: - Personal Info Section

private struct PersonalInfoSection: View {
    @Binding var name: String
    @Binding var email: String
    @Binding var bio: String

    private let fieldBackground = Color(red: 0.1, green: 0.1, blue: 0.28)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "個人情報")

            LabeledInputField(label: "氏名", background: fieldBackground) {
                TextField("氏名", text: $name)
                    .foregroundStyle(.white)
            }

            LabeledInputField(label: "メールアドレス", background: fieldBackground) {
                TextField("メールアドレス", text: $email)
                    .foregroundStyle(.white)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
            }

            LabeledInputField(label: "自己紹介", background: fieldBackground) {
                TextField("自己紹介", text: $bio, axis: .vertical)
                    .foregroundStyle(.white)
                    .lineLimit(4...)
            }
        }
    }
}

// MARK: - Settings Section

private struct SettingsSection: View {
    @Binding var pushNotificationsEnabled: Bool
    @Binding var isPublicProfile: Bool

    private let fieldBackground = Color(red: 0.1, green: 0.1, blue: 0.28)

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "設定")

            VStack(spacing: 0) {
                ToggleRow(
                    icon: "bell.fill",
                    iconColor: .blue,
                    label: "プッシュ通知",
                    isOn: $pushNotificationsEnabled
                )

                Divider().background(Color.white.opacity(0.1))

                ToggleRow(
                    icon: "globe.badge.chevron.backward",
                    iconColor: Color(red: 0.2, green: 0.7, blue: 0.4),
                    label: "公開プロフィール",
                    isOn: $isPublicProfile
                )
            }
            .background(fieldBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Save Button

private struct SaveButton: View {
    var onSave: (() -> Void)? = nil

    var body: some View {
        Button {
            onSave?()
        } label: {
            Text("変更を保存")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(red: 0.05, green: 0.05, blue: 0.18))
    }
}

// MARK: - Shared Components

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.footnote)
            .fontWeight(.semibold)
            .foregroundStyle(.white.opacity(0.7))
    }
}

private struct LabeledInputField<Content: View>: View {
    let label: String
    let background: Color
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)

            content()
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

private struct ToggleRow: View {
    let icon: String
    let iconColor: Color
    let label: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)

            Text(label)
                .foregroundStyle(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(.blue)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ProfileEditView()
    }
}
