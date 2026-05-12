import SwiftData
import SwiftUI

struct SessionView: View {
    let targetSeconds: Int

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss

    @State private var face = FaceTrackingService()
    @State private var engine: SessionEngine?

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if let engine {
                runningView(engine: engine)
            } else {
                ProgressView("Preparing camera…")
            }
        }
        .task { await prepare() }
        .onDisappear {
            face.stop()
            engine?.cancel()
        }
    }

    private func runningView(engine: SessionEngine) -> some View {
        VStack(spacing: 20) {
            HStack {
                Button("Cancel") {
                    engine.cancel()
                    dismiss()
                }
                .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(remaining(engine: engine))s")
                    .font(Theme.bigNumber(20))
                    .monospacedDigit()
            }
            .padding(.horizontal)

            CameraPreview(session: face.session)
                .aspectRatio(3/4, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 20))
                .padding(.horizontal)

            PostureLiveIndicator(quality: engine.currentQuality)

            Spacer()

            switch engine.state {
            case .finished(let score):
                summaryCard(score: score)
            default:
                EmptyView()
            }
        }
        .padding(.vertical)
    }

    private func summaryCard(score: Int) -> some View {
        VStack(spacing: 12) {
            PostureRing(score: score, size: 160)
            Text(scoreLabel(score))
                .font(.headline)
                .foregroundStyle(Theme.qualityColor(qualityForScore(score)))
            Button {
                StreakService(context: context).recordSessionCompleted()
                dismiss()
            } label: {
                Text("Done")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.brandGradient, in: .rect(cornerRadius: 14))
                    .foregroundStyle(.white)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Theme.cardSurface, in: .rect(cornerRadius: Theme.cardRadius))
        .padding(.horizontal)
    }

    private func remaining(engine: SessionEngine) -> Int {
        max(0, targetSeconds - engine.elapsedSeconds)
    }

    private func qualityForScore(_ score: Int) -> PostureQuality {
        switch score {
        case 80...: return .good
        case 50..<80: return .borderline
        default: return .bad
        }
    }

    private func scoreLabel(_ score: Int) -> String {
        switch score {
        case 90...: return "Outstanding"
        case 75..<90: return "Strong"
        case 50..<75: return "Keep practicing"
        default: return "Reset & try again"
        }
    }

    private func prepare() async {
        let calService = CalibrationService(context: context)
        guard let calibration = calService.current() else {
            dismiss()
            return
        }
        let engine = SessionEngine(context: context, calibration: calibration, source: .camera)
        face.onSample = { pitch, _, _ in
            let dev = pitch - calibration.basePitch
            engine.ingestPitchDeviation(dev)
        }
        await face.start()
        engine.start(targetSeconds: targetSeconds)
        self.engine = engine
    }
}
