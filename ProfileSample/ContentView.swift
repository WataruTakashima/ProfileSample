//
//  ContentView.swift
//  ProfileSample
//
//  Created by w.t on 2026/03/26.
//

import SwiftUI

struct ContentView: View {
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color(red: 0.05, green: 0.05, blue: 0.18)
                    .ignoresSafeArea()

                VStack(spacing: 40) {
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.blue)

                        Text("ProfileSample")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)

                        Text("宣言的UIの学習サンプル")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Button {
                        path.append("profile")
                    } label: {
                        Text("プロフィールを編集する")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 32)

                    Button {
                        path.append("puyo")
                    } label: {
                        HStack(spacing: 8) {
                            Text("🫧")
                            Text("ぷよぷよで遊ぶ")
                                .font(.headline)
                            Text("🫧")
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.6, green: 0.1, blue: 0.9),
                                         Color(red: 0.2, green: 0.4, blue: 1.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 32)
                }
            }
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "puyo":
                    PuyoPuyoGameView()
                default:
                    ProfileEditView()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
