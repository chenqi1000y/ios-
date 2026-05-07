import Foundation

enum AppConfig {
    static let appName = "灵居"
    static let slogan = "先看家的样子，再决定要不要装"

    static let websiteURL: URL = {
        guard let url = URL(string: "https://ios1.ma37.com") else {
            preconditionFailure("Invalid websiteURL")
        }
        return url
    }()

    static let apiBaseURL: URL = {
        guard let url = URL(string: "https://ios1.ma37.com/api") else {
            preconditionFailure("Invalid apiBaseURL")
        }
        return url
    }()

    static let mockAPIMode = false
    static let pollingIntervalSeconds = 1.5
    static let maxPollingAttempts = 120
    static let uploadTargetBytes = 3 * 1024 * 1024
    static let maxUploadBytes = 10 * 1024 * 1024
}
