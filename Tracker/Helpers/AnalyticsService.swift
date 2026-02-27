import Foundation
import AppMetricaCore

struct AnalyticsService {
    static func activate() {
        guard let configuration = AppMetricaConfiguration(apiKey: "f783b296-f1f4-41c2-876b-61ab1a0cda34") else { return }

        AppMetrica.activate(with: configuration)
    }

    func report(event: String, params: [AnyHashable: Any]) {
        AppMetrica.reportEvent(name: event, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }

    // MARK: - Convenience

    func reportMainScreen(event: String, item: String? = nil) {
        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": "Main"
        ]
        if let item {
            params["item"] = item
        }
        report(event: "main", params: params)
    }
}
