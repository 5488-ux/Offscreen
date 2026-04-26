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

                Section("白名单 App") {
                    Text("电话、短信、地图、支付、健康、学习和家人联系工具应加入白名单。白名单不会被 Offscreen 限制。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    FamilyActivityPicker(selection: $screenTime.whitelistSelection)
                        .frame(minHeight: 220)
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

                Section("说明") {
                    Text("iOS 不允许普通 App 直接关闭其他 App。Offscreen 只能通过 Screen Time 授权能力限制访问，用户仍可能卸载 App 或关闭授权。")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("限制")
        }
    }
}
