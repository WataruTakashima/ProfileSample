# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

iOS SwiftUI application built with Xcode 26.3, targeting iOS 26.2+. Currently a starter template ready for feature development.

- Bundle ID: `com.Libeles.ProfileSample`
- Supports iPhone and iPad
- Swift 5.0 with modern concurrency (`@MainActor` default actor isolation)

## Build Commands

```bash
# Build (Debug)
xcodebuild -project ProfileSample.xcodeproj -scheme ProfileSample -configuration Debug

# Build for simulator
xcodebuild -project ProfileSample.xcodeproj -scheme ProfileSample -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 16'

# Build (Release)
xcodebuild -project ProfileSample.xcodeproj -scheme ProfileSample -configuration Release
```

## Architecture

Single-target SwiftUI app with a straightforward entry point → view hierarchy:

- `ProfileSampleApp.swift` — `@main` entry point, declares `WindowGroup` with `ContentView`
- `ContentView.swift` — Root view; start adding UI here

Key Xcode project settings:
- `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` — all types default to `@MainActor`
- `SWIFT_APPROACHABLE_CONCURRENCY = YES` — simplified async/await model
- `GENERATE_INFOPLIST_FILE = YES` — Info.plist is auto-generated; do not create a manual one
