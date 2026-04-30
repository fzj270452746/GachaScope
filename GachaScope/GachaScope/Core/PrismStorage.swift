import Foundation

final class AppStorage {
    static let shared = AppStorage()
    private init() {}

    private let defaults = UserDefaults.standard

    private enum Key {
        static let gachaPreset    = "prism.gacha.preset"
        static let slotPreset     = "prism.slot.preset"
        static let simCount       = "prism.sim.count"
        static let pityEnabled    = "prism.pity.enabled"
        static let ssrRate        = "prism.gacha.ssrRate"
        static let srRate         = "prism.gacha.srRate"
        static let winRate        = "prism.slot.winRate"
        static let bigWinRate     = "prism.slot.bigWinRate"
        static let hardPity       = "prism.gacha.hardPity"
        static let softPity       = "prism.gacha.softPity"
        static let historyGacha   = "prism.history.gacha"
        static let historySlot    = "prism.history.slot"
        static let hapticsEnabled = "prism.haptics.enabled"
        static let onboardingDone = "prism.onboarding.done"
    }

    // MARK: - Gacha Config
    var ssrRate: Double {
        get { defaults.object(forKey: Key.ssrRate) as? Double ?? 0.01 }
        set { defaults.set(newValue, forKey: Key.ssrRate) }
    }
    var srRate: Double {
        get { defaults.object(forKey: Key.srRate) as? Double ?? 0.09 }
        set { defaults.set(newValue, forKey: Key.srRate) }
    }
    var hardPity: Int {
        get { defaults.object(forKey: Key.hardPity) as? Int ?? 90 }
        set { defaults.set(newValue, forKey: Key.hardPity) }
    }
    var softPity: Int {
        get { defaults.object(forKey: Key.softPity) as? Int ?? 70 }
        set { defaults.set(newValue, forKey: Key.softPity) }
    }
    var pityEnabled: Bool {
        get { defaults.object(forKey: Key.pityEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.pityEnabled) }
    }

    // MARK: - Slot Config
    var winRate: Double {
        get { defaults.object(forKey: Key.winRate) as? Double ?? 0.25 }
        set { defaults.set(newValue, forKey: Key.winRate) }
    }
    var bigWinRate: Double {
        get { defaults.object(forKey: Key.bigWinRate) as? Double ?? 0.03 }
        set { defaults.set(newValue, forKey: Key.bigWinRate) }
    }

    // MARK: - Simulation
    var simulationCount: Int {
        get { defaults.object(forKey: Key.simCount) as? Int ?? 1000 }
        set { defaults.set(newValue, forKey: Key.simCount) }
    }

    // MARK: - App State
    var hapticsEnabled: Bool {
        get { defaults.object(forKey: Key.hapticsEnabled) as? Bool ?? true }
        set { defaults.set(newValue, forKey: Key.hapticsEnabled) }
    }
    var onboardingDone: Bool {
        get { defaults.bool(forKey: Key.onboardingDone) }
        set { defaults.set(newValue, forKey: Key.onboardingDone) }
    }

    // MARK: - History (last 10 results summary)
    func appendGachaHistory(_ entry: String) {
        var arr = defaults.stringArray(forKey: Key.historyGacha) ?? []
        arr.append(entry)
        if arr.count > 10 { arr.removeFirst() }
        defaults.set(arr, forKey: Key.historyGacha)
    }
    func gachaHistory() -> [String] {
        defaults.stringArray(forKey: Key.historyGacha) ?? []
    }
    func appendSlotHistory(_ entry: String) {
        var arr = defaults.stringArray(forKey: Key.historySlot) ?? []
        arr.append(entry)
        if arr.count > 10 { arr.removeFirst() }
        defaults.set(arr, forKey: Key.historySlot)
    }
    func slotHistory() -> [String] {
        defaults.stringArray(forKey: Key.historySlot) ?? []
    }
    func clearAllHistory() {
        defaults.removeObject(forKey: Key.historyGacha)
        defaults.removeObject(forKey: Key.historySlot)
    }
}
