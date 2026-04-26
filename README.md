# Offscreen

Offscreen is a self-use iOS app for reducing recreational screen time with AI-assisted plans, daily check-ins, activity rewards, and cooldown friction.

## Current MVP

- SwiftUI dashboard for daily allowance and remaining time
- Local 30-day reduction plan
- AI API settings placeholder
- Daily check-in placeholder
- Health reward and Screen Time capability notes
- GitHub Actions workflow for simulator build and signed IPA export

## Tech stack

- SwiftUI
- XcodeGen
- UserDefaults JSON persistence for MVP state
- GitHub Actions on macOS for build and IPA export

## Local development

1. Install XcodeGen on macOS.
2. Run `xcodegen generate`.
3. Open `Offscreen.xcodeproj`.
4. Build and run the `Offscreen` scheme.

## IPA signing

The workflow in `.github/workflows/ios-build.yml` follows the existing `opsai-ssh-ios` signing pattern. Add these repository secrets when signing is ready:

- `IOS_MOBILEPROVISION_BASE64`
- `IOS_TEAM_ID`
- `IOS_BUNDLE_ID`
- `IOS_PROFILE_NAME`
- `IOS_CERT_PEM_BASE64`
- `IOS_KEY_PEM_BASE64`

The app currently avoids privileged Screen Time entitlements so the initial IPA can build with a normal ad-hoc profile. FamilyControls, DeviceActivity, ManagedSettings, and HealthKit should be enabled after the matching Apple capabilities and provisioning profile are ready.

