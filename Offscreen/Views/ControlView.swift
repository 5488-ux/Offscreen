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
                Section("授权") {
                    Text(screenTime.statusText)
                        .foregroundStyle(.secondary)
                    Button("请求 Screen Time 授权") {
                        Task {
                            await screenTime.requestAuthorization()
                        }
                    }
                }

                #if canImport(FamilyControls)
                Section("限制 App") {
                    FamilyActivityPicker(selection: $screenTime.restrictedSelection)
                        .frame(minHeight: 280)
                }

                Section("限制控制") {
                    Button("开启限制") {
                        restrictions.applyRestrictions(selection: screenTime.restrictedSelection)
                    }
                    Button("解除限制") {
                        restrictions.clearRestrictions()
                    }
                    .foregroundStyle(.red)
                    Text(restrictions.lastMessage)
                        .foregroundStyle(.secondary)
                }
                #else
                Section("不可用") {
                    Text("当前构建环境不可用 FamilyControls。")
                }
                #endif
            }
            .navigationTitle("限制")
        }
    }
}
