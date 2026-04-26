import SwiftUI

#if canImport(FamilyControls)
import FamilyControls
#endif

struct ControlView: View {
    @StateObject private var screenTime = ScreenTimeManager()
    @StateObject private var restrictions = RestrictionManager()

    var body: some View {
        NavigationStack {
            List {
                Section("Authorization") {
                    Text(screenTime.statusText)
                        .foregroundStyle(.secondary)
                    Button("Request Screen Time authorization") {
                        Task {
                            await screenTime.requestAuthorization()
                        }
                    }
                }

                #if canImport(FamilyControls)
                Section("Restricted apps") {
                    FamilyActivityPicker(selection: $screenTime.restrictedSelection)
                        .frame(minHeight: 280)
                }

                Section("Restrictions") {
                    Button("Apply restrictions") {
                        restrictions.applyRestrictions(selection: screenTime.restrictedSelection)
                    }
                    Button("Clear restrictions") {
                        restrictions.clearRestrictions()
                    }
                    .foregroundStyle(.red)
                    Text(restrictions.lastMessage)
                        .foregroundStyle(.secondary)
                }
                #else
                Section("Unavailable") {
                    Text("FamilyControls is unavailable in this build environment.")
                }
                #endif
            }
            .navigationTitle("Control")
        }
    }
}

