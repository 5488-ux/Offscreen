# Offscreen

Offscreen is a self-use iOS app for reducing recreational screen time with AI-assisted plans, daily check-ins, activity rewards, and cooldown friction.

## Current MVP

- SwiftUI dashboard for daily allowance and remaining time
- Local 30-day reduction plan
- Keychain-backed AI API key storage and OpenAI-compatible client
- Daily check-in flow with AI review data model
- Screen Time authorization, picker, and ManagedSettings restriction entry points
- HealthKit authorization and activity reward calculation
- Daily video and cancellation cooldown valid-watch-time tracker
- Local notification scheduling for the 9 PM check-in and session warning
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

The code includes FamilyControls, ManagedSettings, and HealthKit integration points. Real device enforcement still requires the matching Apple capabilities and a provisioning profile that contains those entitlements.
