import Foundation
import Observation

@MainActor
@Observable
final class GoalSettings {
    static let shared = GoalSettings()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = UserDefaults(suiteName: postureAppGroupID) ?? .standard) {
        self.defaults = defaults
    }

    private enum Key {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let hasCalibrated = "hasCalibrated"
        static let dailyReminderEnabled = "dailyReminderEnabled"
        static let dailyReminderHour = "dailyReminderHour"
        static let sensitivity = "sensitivity"  // 0=relaxed, 1=normal, 2=strict
        static let alwaysOnEnabled = "alwaysOnEnabled"
    }

    var alwaysOnEnabled: Bool {
        get { defaults.bool(forKey: Key.alwaysOnEnabled) }
        set { defaults.set(newValue, forKey: Key.alwaysOnEnabled) }
    }

    var hasCompletedOnboarding: Bool {
        get { defaults.bool(forKey: Key.hasCompletedOnboarding) }
        set { defaults.set(newValue, forKey: Key.hasCompletedOnboarding) }
    }

    var hasCalibrated: Bool {
        get { defaults.bool(forKey: Key.hasCalibrated) }
        set { defaults.set(newValue, forKey: Key.hasCalibrated) }
    }

    var dailyReminderEnabled: Bool {
        get { defaults.object(forKey: Key.dailyReminderEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.dailyReminderEnabled) }
    }

    var dailyReminderHour: Int {
        get { defaults.object(forKey: Key.dailyReminderHour) as? Int ?? 9 }
        set { defaults.set(newValue, forKey: Key.dailyReminderHour) }
    }

    var sensitivity: Int {
        get { defaults.object(forKey: Key.sensitivity) as? Int ?? 1 }
        set { defaults.set(newValue, forKey: Key.sensitivity) }
    }
}
