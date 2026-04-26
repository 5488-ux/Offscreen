import Foundation

enum CapabilityNotes {
    static let screenTime = "FamilyControls, DeviceActivity, and ManagedSettings should be enabled after the matching Apple entitlements and provisioning profile are ready."
    static let health = "HealthKit rewards should read only steps, exercise minutes, workouts, and active energy after user authorization."
    static let video = "Valid watch time should count only while the app is foregrounded and AVPlayer is playing at normal speed."
}

