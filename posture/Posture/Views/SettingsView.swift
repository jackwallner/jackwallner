import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(GoalSettings.self) private var settings
    @Environment(\.modelContext) private var context

    @State private var notificationsAuthorized: Bool = false

    var body: some View {
        @Bindable var settings = settings
        NavigationStack {
            Form {
                Section("Daily reminder") {
                    Toggle("Remind me each day", isOn: $settings.dailyReminderEnabled)
                    if settings.dailyReminderEnabled {
                        Stepper("At \(settings.dailyReminderHour):00", value: $settings.dailyReminderHour, in: 5...22)
                    }
                }

                Section("Sensitivity") {
                    Picker("Sensitivity", selection: $settings.sensitivity) {
                        Text("Relaxed").tag(0)
                        Text("Normal").tag(1)
                        Text("Strict").tag(2)
                    }
                    .pickerStyle(.segmented)
                }

                Section("Calibration") {
                    Button("Recalibrate") {
                        CalibrationService(context: context).clear()
                        settings.hasCalibrated = false
                    }
                    .foregroundStyle(Theme.brandPrimary)
                }

                Section("About") {
                    LabeledContent("Version", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—")
                }
            }
            .navigationTitle("Settings")
            .onChange(of: settings.dailyReminderEnabled) { _, enabled in
                Task { await applyReminderSettings(enabled: enabled, hour: settings.dailyReminderHour) }
            }
            .onChange(of: settings.dailyReminderHour) { _, hour in
                Task { await applyReminderSettings(enabled: settings.dailyReminderEnabled, hour: hour) }
            }
        }
    }

    private func applyReminderSettings(enabled: Bool, hour: Int) async {
        if enabled {
            _ = await NotificationService.requestAuthorization()
            await NotificationService.scheduleDailyReminder(hour: hour)
        } else {
            await NotificationService.cancelDailyReminder()
        }
    }
}
