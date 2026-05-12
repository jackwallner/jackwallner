import Foundation

enum PostureQuality: String, Sendable {
    case good
    case borderline
    case bad
}

/// Pure scoring functions — no I/O, no state. Easy to unit test.
enum PostureScoring {
    /// Convert a single pose deviation (radians from baseline pitch) into a quality bucket.
    /// `slouchDelta` is the calibrated full-slouch reference deviation.
    static func quality(deviation: Double, slouchDelta: Double) -> PostureQuality {
        let absDev = abs(deviation)
        let safeSlouch = max(slouchDelta, .pi / 24)  // floor at 7.5°
        let ratio = absDev / safeSlouch
        if ratio < 0.35 { return .good }
        if ratio < 0.70 { return .borderline }
        return .bad
    }

    /// Aggregate session score 0-100 from time-in-each-quality.
    /// Good = 1.0, borderline = 0.5, bad = 0.0
    static func sessionScore(goodSeconds: Int, borderlineSeconds: Int, badSeconds: Int) -> Int {
        let total = goodSeconds + borderlineSeconds + badSeconds
        guard total > 0 else { return 0 }
        let weighted = Double(goodSeconds) + Double(borderlineSeconds) * 0.5
        return Int((weighted / Double(total) * 100).rounded())
    }

    /// Smooth a noisy stream of pose samples with a simple exponential moving average.
    static func smoothed(previous: Double?, sample: Double, alpha: Double = 0.3) -> Double {
        guard let previous else { return sample }
        return previous * (1 - alpha) + sample * alpha
    }
}
