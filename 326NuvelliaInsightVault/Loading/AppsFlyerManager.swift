import Foundation
import AppsFlyerLib

extension Notification.Name {
    static let appsFlyerConversionDataReady = Notification.Name("appsFlyerConversionDataReady")
}

enum AppsFlyerManagerKeys {
    static let conversionDataString = "AppsFlyerConversionDataString"
    static let conversionDataUpdatedAt = "AppsFlyerConversionDataUpdatedAt"
}

final class AppsFlyerManager: NSObject {

    static let shared = AppsFlyerManager()

    private(set) var conversionDataString: String? {
        get {
            UserDefaults.standard.string(forKey: AppsFlyerManagerKeys.conversionDataString)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppsFlyerManagerKeys.conversionDataString)
        }
    }

    private(set) var conversionDataUpdatedAt: TimeInterval? {
        get {
            let value = UserDefaults.standard.double(forKey: AppsFlyerManagerKeys.conversionDataUpdatedAt)
            return value > 0 ? value : nil
        }
        set {
            if let newValue {
                UserDefaults.standard.set(newValue, forKey: AppsFlyerManagerKeys.conversionDataUpdatedAt)
            } else {
                UserDefaults.standard.removeObject(forKey: AppsFlyerManagerKeys.conversionDataUpdatedAt)
            }
        }
    }

    func hasFreshConversionData(within seconds: TimeInterval) -> Bool {
        guard conversionDataString != nil, let updatedAt = conversionDataUpdatedAt else { return false }
        return Date().timeIntervalSince1970 - updatedAt <= seconds
    }

    private var currentConversionData: [AnyHashable: Any]?

    private var isRetryScheduled = false

    private let organicRetryDelay: TimeInterval = 5

    private override init() {
        super.init()
    }

    func handleConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        let status = installData["af_status"] as? String
        if status == "Organic" && !isRetryScheduled {
            isRetryScheduled = true
            currentConversionData = installData
            scheduleConversionDataRetry()
            return
        }

        applyConversionData(installData)
    }

    func handleConversionDataFail(_ error: Error?) {
    }

    private func applyConversionData(_ installData: [AnyHashable: Any]) {
        currentConversionData = installData
        mergeAndSaveConversionString()
    }

    private func scheduleConversionDataRetry() {
        DispatchQueue.main.asyncAfter(deadline: .now() + organicRetryDelay) { [weak self] in
            self?.performConversionDataRetry()
        }
    }

    private func performConversionDataRetry() {
        AppsFlyerLib.shared().start(completionHandler: { [weak self] dictionary, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let dict = dictionary as? [AnyHashable: Any], dict["af_status"] != nil {
                    self.applyConversionData(dict)
                } else if self.currentConversionData != nil {
                    self.mergeAndSaveConversionString()
                }
                self.isRetryScheduled = false
            }
        })
    }

    private var deepLinkData: [AnyHashable: Any]?

    func handleDeepLinkData(_ deepLinkPayload: [AnyHashable: Any]) {
        deepLinkData = deepLinkPayload
        mergeAndSaveConversionString()
    }

    private func mergeAndSaveConversionString() {
        var merged: [String: Any] = [:]

        if let conversion = currentConversionData {
            for (key, value) in conversion {
                guard let k = key as? String else { continue }
                if merged[k] == nil {
                    merged[k] = value
                }
            }
        }

        if let udl = deepLinkData {
            for (key, value) in udl {
                guard let k = key as? String else { continue }
                if merged[k] == nil {
                    merged[k] = value
                }
            }
        }

        guard let jsonData = try? JSONSerialization.data(withJSONObject: merged),
              let string = String(data: jsonData, encoding: .utf8) else {
            return
        }
        conversionDataString = string
        conversionDataUpdatedAt = Date().timeIntervalSince1970
        NotificationCenter.default.post(name: .appsFlyerConversionDataReady, object: nil)
    }

    func restartConversionFetch() {
        AppsFlyerLib.shared().start(completionHandler: { [weak self] dictionary, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let dict = dictionary as? [AnyHashable: Any], dict["af_status"] != nil {
                    self.handleConversionDataSuccess(dict)
                }
            }
        })
    }

    func clearConversionDataIfStale(olderThan seconds: TimeInterval) {
        guard !hasFreshConversionData(within: seconds) else { return }
        clearStoredConversionString()
    }

    func clearStoredConversionString() {
        conversionDataString = nil
        conversionDataUpdatedAt = nil
        currentConversionData = nil
        deepLinkData = nil
        isRetryScheduled = false
    }
}
