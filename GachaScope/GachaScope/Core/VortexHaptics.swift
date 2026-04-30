import UIKit

final class Haptics {
    static let shared = Haptics()
    private init() {}

    private let impactLight   = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium  = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy   = UIImpactFeedbackGenerator(style: .heavy)
    private let notifyGen     = UINotificationFeedbackGenerator()
    private let selectionGen  = UISelectionFeedbackGenerator()

    func primeAll() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notifyGen.prepare()
        selectionGen.prepare()
    }

    func tapLight()    { impactLight.impactOccurred() }
    func tapMedium()   { impactMedium.impactOccurred() }
    func tapHeavy()    { impactHeavy.impactOccurred() }
    func selectItem()  { selectionGen.selectionChanged() }
    func successPulse(){ notifyGen.notificationOccurred(.success) }
    func warnPulse()   { notifyGen.notificationOccurred(.warning) }
    func errorPulse()  { notifyGen.notificationOccurred(.error) }

    func ssrBurst() {
        impactHeavy.impactOccurred()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.impactMedium.impactOccurred() }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.impactLight.impactOccurred() }
    }
}
