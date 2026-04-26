import Foundation

@MainActor
final class ScreenTimeManager: ObservableObject {
    @Published var statusText = "淘宝证书版已关闭 Screen Time 授权。AI、打卡、计划、通知、视频和健康奖励仍可使用。"

    func requestAuthorization() async {
        statusText = "当前 IPA 使用的描述文件不包含 FamilyControls，不能开启 Screen Time 限制。"
    }

    var authorizationApproved: Bool { false }
}
