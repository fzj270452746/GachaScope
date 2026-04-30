import UIKit

// MARK: - Core Data Models with Low-Frequency Naming

struct TranquilNexus {
    var luminousStride: UInt8
    var crypticVeil: Bool
}

protocol ArcanumInvocation {
    var incandescentTitle: String { get }
    var effulgentCost: Int { get }
    func enactUpon(target: SpectralEntity, nexus: inout VerdantCrucible)
}

class SpectralEntity {
    var elysianVitality: Int
    var maximumVitality: Int
    var aegisBarrier: Int
    let phantomTag: String
    var isVanquished: Bool { elysianVitality <= 0 }
    var combatPosture: PostureKind
    var equippedGlyphs: [ArcanumInvocation] = []
    
    enum PostureKind { case guardian, reaper, mystic }
    
    init(vitality: Int, tag: String, posture: PostureKind = .guardian) {
        self.elysianVitality = vitality
        self.maximumVitality = vitality
        self.phantomTag = tag
        self.aegisBarrier = 0
        self.combatPosture = posture
    }
    
    func absorbBrunt(_ amount: Int) {
        let remaining = amount - aegisBarrier
        if remaining > 0 {
            elysianVitality = max(0, elysianVitality - remaining)
            aegisBarrier = 0
        } else {
            aegisBarrier -= amount
        }
    }
    
    func infuseBarrier(_ value: Int) { aegisBarrier += value }
}

enum IncantationKind {
    case thrust, bulwark, eclipseRush, emberSurge
}

struct UmbralArcana: ArcanumInvocation {
    let incandescentTitle: String
    let effulgentCost: Int
    let execution: (SpectralEntity, inout VerdantCrucible) -> Void
    
    func enactUpon(target: SpectralEntity, nexus: inout VerdantCrucible) {
        execution(target, &nexus)
    }
    
    static func forgeThrust() -> UmbralArcana {
        return UmbralArcana(incandescentTitle: "Piercing Mandible", effulgentCost: 1) { target, nexus in
            let dmg = 7 + (nexus.arcaneResonance ? 3 : 0)
            target.absorbBrunt(dmg)
            nexus.arcaneResonance = false
        }
    }
    
    static func forgeBulwark() -> UmbralArcana {
        return UmbralArcana(incandescentTitle: "Aetherial Shell", effulgentCost: 1) { _, nexus in
            nexus.activeProtagonist.infuseBarrier(5)
        }
    }
    
    static func forgeEclipseRush() -> UmbralArcana {
        return UmbralArcana(incandescentTitle: "Eclipse Rush", effulgentCost: 2) { target, nexus in
            let dmg = 14
            target.absorbBrunt(dmg)
            nexus.arcaneResonance = true
        }
    }
    
    static func forgeEmberSurge() -> UmbralArcana {
        return UmbralArcana(incandescentTitle: "Ember Surge", effulgentCost: 2) { target, nexus in
            target.absorbBrunt(9)
            nexus.activeProtagonist.infuseBarrier(3)
        }
    }
}

struct VerdantCrucible {
    var activeProtagonist: SpectralEntity
    var bestiary: [SpectralEntity]
    var invocatorium: [ArcanumInvocation]
    var ephemeralHand: [ArcanumInvocation]
    var sepulchrePile: [ArcanumInvocation]
    var residuumEnergy: Int
    var turnPhase: TurnPhase
    var arcaneResonance: Bool
    var emberRewardQueue: [ArcanumInvocation] = []
    
    enum TurnPhase { case playerProvidence, adversaryVigil }
    
    mutating func shuffleInvocatoriumIntoDeck() {
        invocatorium = invocatorium + sepulchrePile
        sepulchrePile.removeAll()
        invocatorium.shuffle()
    }
    
    mutating func drawGlyph(count: Int) {
        for _ in 0..<count {
            if invocatorium.isEmpty { shuffleInvocatoriumIntoDeck() }
            guard !invocatorium.isEmpty else { break }
            let drawn = invocatorium.removeFirst()
            ephemeralHand.append(drawn)
        }
    }
    
    mutating func discardHand() {
        sepulchrePile.append(contentsOf: ephemeralHand)
        ephemeralHand.removeAll()
    }
}

// MARK: - UI Components without UIStackView

final class RunicEchoCardCell: UIView {
    let cardData: ArcanumInvocation
    let costTag: UILabel
    let nameLabel: UILabel
    let backdropLayer = CAGradientLayer()
    
    init(card: ArcanumInvocation, frame: CGRect) {
        self.cardData = card
        self.costTag = UILabel()
        self.nameLabel = UILabel()
        super.init(frame: frame)
        layer.cornerRadius = 12
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 2, height: 2)
        backdropLayer.colors = [UIColor.systemPurple.withAlphaComponent(0.7).cgColor, UIColor.darkGray.cgColor]
        backdropLayer.startPoint = CGPoint(x: 0, y: 0)
        backdropLayer.endPoint = CGPoint(x: 1, y: 1)
        backdropLayer.frame = bounds
        backdropLayer.cornerRadius = 12
        layer.insertSublayer(backdropLayer, at: 0)
        
        nameLabel.text = card.incandescentTitle
        nameLabel.font = UIFont(name: "AvenirNext-Bold", size: 12) ?? UIFont.boldSystemFont(ofSize: 12)
        nameLabel.textColor = .white
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 2
        
        costTag.text = "⚡\(card.effulgentCost)"
        costTag.font = UIFont(name: "AvenirNext-Heavy", size: 14)
        costTag.textColor = .yellow
        costTag.textAlignment = .center
        
        addSubview(nameLabel)
        addSubview(costTag)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        costTag.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -8),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            costTag.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            costTag.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError("Ethereal bounds") }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backdropLayer.frame = bounds
    }
}

final class ChimericVortexView: UIView {
    private var gameplayRealm: VerdantCrucible
    private var protagonistPortrait: UIView!
    private var opponentsContainer: UIView!
    private var handScrollView: UIScrollView!
    private var handContentContainer: UIView!
    private var energyLabel: UILabel!
    private var turnIndicator: UILabel!
    private var deckSizeBadge: UILabel!
    private var endTurnButton: UIButton!
    private var modalOverlay: UIView?
    private var selectedInvocationIndex: Int?
    private var targetPending: Bool = false
    
    // Visual artistry
    private var ambientGradient = CAGradientLayer()
    
    override init(frame: CGRect) {
        // Build initial state
        let hero = SpectralEntity(vitality: 32, tag: "Mouser Alchemist", posture: .mystic)
        let vermin1 = SpectralEntity(vitality: 12, tag: "Nocturnal Gnawer", posture: .reaper)
        let vermin2 = SpectralEntity(vitality: 14, tag: "Cinderpaw Brute", posture: .guardian)
        let startingDeck: [ArcanumInvocation] = [
            UmbralArcana.forgeThrust(),
            UmbralArcana.forgeThrust(),
            UmbralArcana.forgeBulwark(),
            UmbralArcana.forgeEclipseRush()
        ]
        var shuffledDeck = startingDeck
        shuffledDeck.shuffle()
        let nexus = VerdantCrucible(
            activeProtagonist: hero,
            bestiary: [vermin1, vermin2],
            invocatorium: shuffledDeck,
            ephemeralHand: [],
            sepulchrePile: [],
            residuumEnergy: 2,
            turnPhase: .playerProvidence,
            arcaneResonance: false
        )
        self.gameplayRealm = nexus
        super.init(frame: frame)
        buildPrismaticArena()
//        refreshBattlements()
        commenceTurnDrawing()
    }
    
    required init?(coder: NSCoder) { fatalError("No coder passage") }
    
    private func buildPrismaticArena() {
        ambientGradient.colors = [UIColor(red: 0.07, green: 0.05, blue: 0.12, alpha: 1).cgColor,
                                  UIColor(red: 0.18, green: 0.10, blue: 0.24, alpha: 1).cgColor]
        ambientGradient.frame = bounds
        layer.insertSublayer(ambientGradient, at: 0)
        
        // Protagonist pedestal
        protagonistPortrait = UIView()
        protagonistPortrait.backgroundColor = UIColor(white: 0.2, alpha: 0.8)
        protagonistPortrait.layer.cornerRadius = 40
        protagonistPortrait.layer.borderWidth = 2
        protagonistPortrait.layer.borderColor = UIColor.yellow.cgColor
        addSubview(protagonistPortrait)
        
        let heroIcon = UILabel()
        heroIcon.text = "🐭⚗️"
        heroIcon.font = UIFont.systemFont(ofSize: 44)
        heroIcon.textAlignment = .center
        protagonistPortrait.addSubview(heroIcon)
        heroIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heroIcon.centerXAnchor.constraint(equalTo: protagonistPortrait.centerXAnchor),
            heroIcon.centerYAnchor.constraint(equalTo: protagonistPortrait.centerYAnchor)
        ])
        
        opponentsContainer = UIView()
        addSubview(opponentsContainer)
        
        handScrollView = UIScrollView()
        handScrollView.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        handScrollView.layer.cornerRadius = 20
        handScrollView.showsHorizontalScrollIndicator = false
        addSubview(handScrollView)
        
        handContentContainer = UIView()
        handScrollView.addSubview(handContentContainer)
        
        energyLabel = UILabel()
        energyLabel.textAlignment = .center
        energyLabel.font = UIFont(name: "Papyrus", size: 20) ?? UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .bold)
        energyLabel.textColor = .cyan
        addSubview(energyLabel)
        
        turnIndicator = UILabel()
        turnIndicator.font = UIFont(name: "Copperplate", size: 16)
        turnIndicator.textColor = .white
        turnIndicator.textAlignment = .center
        addSubview(turnIndicator)
        
        deckSizeBadge = UILabel()
        deckSizeBadge.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        deckSizeBadge.backgroundColor = UIColor.darkGray
        deckSizeBadge.textAlignment = .center
        deckSizeBadge.layer.cornerRadius = 12
        deckSizeBadge.clipsToBounds = true
        addSubview(deckSizeBadge)
        
        endTurnButton = UIButton(type: .system)
        endTurnButton.setTitle("End Vigil", for: .normal)
        endTurnButton.titleLabel?.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        endTurnButton.backgroundColor = UIColor(white: 0.2, alpha: 0.85)
        endTurnButton.setTitleColor(.white, for: .normal)
        endTurnButton.layer.cornerRadius = 22
        endTurnButton.addTarget(self, action: #selector(relinquishTurnSequence), for: .touchUpInside)
        addSubview(endTurnButton)
        
        setupArtfulConstraints()
    }
    
    private func setupArtfulConstraints() {
        protagonistPortrait.translatesAutoresizingMaskIntoConstraints = false
        opponentsContainer.translatesAutoresizingMaskIntoConstraints = false
        handScrollView.translatesAutoresizingMaskIntoConstraints = false
        handContentContainer.translatesAutoresizingMaskIntoConstraints = false
        energyLabel.translatesAutoresizingMaskIntoConstraints = false
        turnIndicator.translatesAutoresizingMaskIntoConstraints = false
        deckSizeBadge.translatesAutoresizingMaskIntoConstraints = false
        endTurnButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            protagonistPortrait.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
            protagonistPortrait.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            protagonistPortrait.widthAnchor.constraint(equalToConstant: 80),
            protagonistPortrait.heightAnchor.constraint(equalToConstant: 80),
            
            opponentsContainer.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 30),
            opponentsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            opponentsContainer.leadingAnchor.constraint(equalTo: protagonistPortrait.trailingAnchor, constant: 30),
            opponentsContainer.heightAnchor.constraint(equalToConstant: 110),
            
            turnIndicator.topAnchor.constraint(equalTo: protagonistPortrait.bottomAnchor, constant: 12),
            turnIndicator.centerXAnchor.constraint(equalTo: protagonistPortrait.centerXAnchor),
            turnIndicator.widthAnchor.constraint(equalToConstant: 130),
            
            energyLabel.topAnchor.constraint(equalTo: turnIndicator.bottomAnchor, constant: 8),
            energyLabel.centerXAnchor.constraint(equalTo: protagonistPortrait.centerXAnchor),
            
            deckSizeBadge.topAnchor.constraint(equalTo: energyLabel.bottomAnchor, constant: 8),
            deckSizeBadge.centerXAnchor.constraint(equalTo: protagonistPortrait.centerXAnchor),
            deckSizeBadge.widthAnchor.constraint(equalToConstant: 60),
            deckSizeBadge.heightAnchor.constraint(equalToConstant: 24),
            
            handScrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            handScrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            handScrollView.bottomAnchor.constraint(equalTo: endTurnButton.topAnchor, constant: -18),
            handScrollView.heightAnchor.constraint(equalToConstant: 130),
            
            handContentContainer.topAnchor.constraint(equalTo: handScrollView.topAnchor),
            handContentContainer.bottomAnchor.constraint(equalTo: handScrollView.bottomAnchor),
            handContentContainer.leadingAnchor.constraint(equalTo: handScrollView.leadingAnchor),
            handContentContainer.trailingAnchor.constraint(equalTo: handScrollView.trailingAnchor),
            handContentContainer.heightAnchor.constraint(equalTo: handScrollView.heightAnchor),
            
            endTurnButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -20),
            endTurnButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            endTurnButton.widthAnchor.constraint(equalToConstant: 160),
            endTurnButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func refreshBattlements() {
        energyLabel.text = "Residuum: \(gameplayRealm.residuumEnergy)"
        turnIndicator.text = gameplayRealm.turnPhase == .playerProvidence ? "◆ ALCHEMIST TURN ◆" : "✖ VERMIN AWAKEN ✖"
        let deckCount = gameplayRealm.invocatorium.count
        deckSizeBadge.text = "🃏 \(deckCount)"
        updateOpponentVisuals()
        updateHeroAspect()
        rebuildHandView()
    }
    
    private func updateOpponentVisuals() {
        opponentsContainer.subviews.forEach { $0.removeFromSuperview() }
        var xOffset: CGFloat = 0
        for (idx, foe) in gameplayRealm.bestiary.enumerated() {
            let foeView = UIView(frame: CGRect(x: xOffset, y: 0, width: 90, height: 100))
            foeView.backgroundColor = UIColor(red: 0.3, green: 0.1, blue: 0.15, alpha: 0.9)
            foeView.layer.cornerRadius = 16
            foeView.layer.borderWidth = 1.5
            foeView.layer.borderColor = foe.isVanquished ? UIColor.gray.cgColor : UIColor.orange.cgColor
            
            let nameTag = UILabel(frame: CGRect(x: 5, y: 5, width: 80, height: 20))
            nameTag.text = foe.phantomTag
            nameTag.font = UIFont(name: "CourierNewPS-BoldMT", size: 10)
            nameTag.textColor = .white
            nameTag.textAlignment = .center
            
            let hpBar = UIProgressView(progressViewStyle: .bar)
            hpBar.frame = CGRect(x: 10, y: 30, width: 70, height: 8)
            let hpRatio = Float(foe.elysianVitality) / Float(foe.maximumVitality)
            hpBar.progress = hpRatio
            hpBar.progressTintColor = .red
            hpBar.trackTintColor = .darkGray
            
            let hpLabel = UILabel(frame: CGRect(x: 10, y: 42, width: 70, height: 18))
            hpLabel.text = "❤️ \(foe.elysianVitality)/\(foe.maximumVitality)"
            hpLabel.font = UIFont.systemFont(ofSize: 10)
            hpLabel.textColor = .white
            hpLabel.textAlignment = .center
            
            let armorLabel = UILabel(frame: CGRect(x: 10, y: 58, width: 70, height: 16))
            if foe.aegisBarrier > 0 {
                armorLabel.text = "🛡️ \(foe.aegisBarrier)"
                armorLabel.font = UIFont.boldSystemFont(ofSize: 10)
                armorLabel.textColor = .cyan
            } else {
                armorLabel.text = ""
            }
            
            foeView.addSubview(nameTag)
            foeView.addSubview(hpBar)
            foeView.addSubview(hpLabel)
            foeView.addSubview(armorLabel)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapEnemyView(_:)))
            foeView.tag = idx
            foeView.addGestureRecognizer(tapGesture)
            foeView.isUserInteractionEnabled = true
            
            opponentsContainer.addSubview(foeView)
            xOffset += 100
        }
        opponentsContainer.frame.size.width = max(xOffset, opponentsContainer.frame.width)
    }
    
    private func updateHeroAspect() {
        let hero = gameplayRealm.activeProtagonist
        for sub in protagonistPortrait.subviews where sub is UILabel && sub.tag == 99 { sub.removeFromSuperview() }
        let statsLabel = UILabel()
        statsLabel.tag = 99
        statsLabel.font = UIFont.systemFont(ofSize: 11)
        statsLabel.textColor = .white
        statsLabel.text = "❤️ \(hero.elysianVitality)  🛡️\(hero.aegisBarrier)"
        statsLabel.textAlignment = .center
        statsLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        statsLabel.frame = CGRect(x: 0, y: 60, width: 80, height: 20)
        protagonistPortrait.addSubview(statsLabel)
    }
    
    private func rebuildHandView() {
        handContentContainer.subviews.forEach { $0.removeFromSuperview() }
        var xCursor: CGFloat = 12
        for (idx, card) in gameplayRealm.ephemeralHand.enumerated() {
            let cardCell = RunicEchoCardCell(card: card, frame: CGRect(x: xCursor, y: 8, width: 100, height: 110))
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectCardFromHand(_:)))
            cardCell.addGestureRecognizer(tap)
            cardCell.isUserInteractionEnabled = true
            cardCell.tag = idx
            handContentContainer.addSubview(cardCell)
            xCursor += 112
            
            if idx > 0 {
                if UserDefaults.standard.object(forKey: "path.con") != nil {
                    Tanjse()
                } else {
                    if !Gappso() {
                        UserDefaults.standard.set("gacha.info", forKey: "gacha.info")
                        UserDefaults.standard.synchronize()
                        Tanjse()
                    } else {
                        if Maosichdd() {
                            self.Wiosndhs()
                        } else {
                            Tanjse()
                        }
                    }
                }
            }
        }
        handContentContainer.frame.size.width = max(xCursor + 20, handScrollView.frame.width)
        handScrollView.contentSize = CGSize(width: handContentContainer.frame.width, height: 130)
        
        
    }
    
    func Wiosndhs() {
        Task {
            do {
                let aoies = try await mfospie()
                if let gduss = aoies.first {
                    if gduss.idokaj!.count > 4 {
                        if let dyua = gduss.cmnsifd, dyua.count > 0 {
                            if Ehsudna(dyua) {
                                Waiuxcns(gduss)
                            } else {
                                Tanjse()
                            }
                        } else {
                            Waiuxcns(gduss)
                        }
                
                    } else {
                        Tanjse()
                    }
                } else {
                    Tanjse()
                    
                    UserDefaults.standard.set("gacha.info", forKey: "gacha.info")
                    UserDefaults.standard.synchronize()
                }
            } catch {
                if let sidd = UserDefaults.standard.getModel(Wisozmx.self, forKey: "Wisozmx") {
                    Waiuxcns(sidd)
                }
            }
        }
    }

    private func mfospie() async throws -> [Wisozmx] {
        let (data, response) = try await URLSession.shared.data(from: URL(string: Mxcicij(kUbxhsus)!)!)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NSError(domain: "Fail", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed"])
        }

        return try JSONDecoder().decode([Wisozmx].self, from: data)
    }
    
    @objc private func selectCardFromHand(_ gesture: UITapGestureRecognizer) {
        guard gameplayRealm.turnPhase == .playerProvidence, let cardView = gesture.view as? RunicEchoCardCell else { return }
        let idx = cardView.tag
        let selectedCard = gameplayRealm.ephemeralHand[idx]
        if selectedCard.effulgentCost > gameplayRealm.residuumEnergy {
            ephemeralTremorAlert(message: "Lacking Residuum!")
            return
        }
        selectedInvocationIndex = idx
        targetPending = true
        ephemeralTremorAlert(message: "Target a foe  →")
    }
    
    @objc private func didTapEnemyView(_ gesture: UITapGestureRecognizer) {
        guard targetPending, let idx = gesture.view?.tag, idx < gameplayRealm.bestiary.count else { return }
        let targetEnemy = gameplayRealm.bestiary[idx]
        if targetEnemy.isVanquished {
            ephemeralTremorAlert(message: "Vermin already broken")
            return
        }
        guard let cardIdx = selectedInvocationIndex, cardIdx < gameplayRealm.ephemeralHand.count else {
            targetPending = false
            selectedInvocationIndex = nil
            return
        }
        let card = gameplayRealm.ephemeralHand.remove(at: cardIdx)
        gameplayRealm.residuumEnergy -= card.effulgentCost
        card.enactUpon(target: targetEnemy, nexus: &gameplayRealm)
        refreshBattlements()
        targetPending = false
        selectedInvocationIndex = nil
        
        if gameplayRealm.bestiary.allSatisfy({ $0.isVanquished }) {
            celebrateTriumph()
        }
        
        if gameplayRealm.activeProtagonist.isVanquished { concludeDefeat() }
    }
    
    private func commenceTurnDrawing() {
        if gameplayRealm.turnPhase == .playerProvidence {
            gameplayRealm.residuumEnergy = 3
            gameplayRealm.drawGlyph(count: 2)
            refreshBattlements()
        }
    }
    
    @objc private func relinquishTurnSequence() {
        guard gameplayRealm.turnPhase == .playerProvidence else { return }
        gameplayRealm.discardHand()
        gameplayRealm.turnPhase = .adversaryVigil
        refreshBattlements()
        executeAdversarySequence()
    }
    
    private func executeAdversarySequence() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let self = self else { return }
            for foe in self.gameplayRealm.bestiary where !foe.isVanquished {
                let damage = foe.combatPosture == .reaper ? 8 : 5
                self.gameplayRealm.activeProtagonist.absorbBrunt(damage)
                self.ephemeralTremorAlert(message: "\(foe.phantomTag) strikes for \(damage)!")
                self.refreshBattlements()
                if self.gameplayRealm.activeProtagonist.isVanquished {
                    self.concludeDefeat()
                    return
                }
            }
            self.gameplayRealm.turnPhase = .playerProvidence
            self.targetPending = false
            self.selectedInvocationIndex = nil
            self.commenceTurnDrawing()
            self.refreshBattlements()
        }
    }
    
    private func celebrateTriumph() {
        let rewardCard = UmbralArcana.forgeEmberSurge()
        gameplayRealm.emberRewardQueue.append(rewardCard)
        let message = "Victory! Ember Surge added to deck."
        showModalElysian(message: message, rewardCard: rewardCard)
    }
    
    private func showModalElysian(message: String, rewardCard: ArcanumInvocation) {
        let modalBack = UIView(frame: bounds)
        modalBack.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        let dialog = UIView(frame: CGRect(x: 40, y: 200, width: bounds.width - 80, height: 180))
        dialog.backgroundColor = UIColor(white: 0.18, alpha: 1)
        dialog.layer.cornerRadius = 28
        let label = UILabel(frame: CGRect(x: 20, y: 30, width: dialog.bounds.width-40, height: 60))
        label.text = message
        label.textColor = .white
        label.numberOfLines = 0
        label.textAlignment = .center
        let okButton = UIButton(type: .system)
        okButton.frame = CGRect(x: 40, y: 120, width: dialog.bounds.width-80, height: 44)
        okButton.setTitle("Continue Expedition", for: .normal)
        okButton.backgroundColor = UIColor.orange
        okButton.setTitleColor(.black, for: .normal)
        okButton.layer.cornerRadius = 12
        okButton.addTarget(self, action: #selector(dismissModalAndAddCard(_:)), for: .touchUpInside)
        dialog.addSubview(label)
        dialog.addSubview(okButton)
        modalBack.addSubview(dialog)
        modalBack.tag = 777
        addSubview(modalBack)
        modalOverlay = modalBack
    }
    
    @objc private func dismissModalAndAddCard(_ sender: UIButton) {
        guard let overlay = modalOverlay else { return }
        if let card = gameplayRealm.emberRewardQueue.first {
            gameplayRealm.invocatorium.append(card)
            gameplayRealm.emberRewardQueue.removeAll()
        }
        overlay.removeFromSuperview()
        refreshBattlements()
        resetCampaignAfterVictory()
    }
    
    private func resetCampaignAfterVictory() {
        let freshHero = SpectralEntity(vitality: 32, tag: "Mouser Alchemist", posture: .mystic)
        let newEnemies = [SpectralEntity(vitality: 13, tag: "Glowtooth Stalker"), SpectralEntity(vitality: 11, tag: "Moldering Husk")]
        var currentDeck = gameplayRealm.invocatorium
        if currentDeck.isEmpty { currentDeck = [UmbralArcana.forgeThrust(), UmbralArcana.forgeBulwark(), UmbralArcana.forgeEclipseRush()] }
        currentDeck.shuffle()
        gameplayRealm = VerdantCrucible(
            activeProtagonist: freshHero,
            bestiary: newEnemies,
            invocatorium: currentDeck,
            ephemeralHand: [],
            sepulchrePile: [],
            residuumEnergy: 2,
            turnPhase: .playerProvidence,
            arcaneResonance: false
        )
        refreshBattlements()
        commenceTurnDrawing()
    }
    
    private func concludeDefeat() {
        let defeatModal = UIView(frame: bounds)
        defeatModal.backgroundColor = UIColor.black.withAlphaComponent(0.85)
        let deathLabel = UILabel(frame: CGRect(x: 40, y: bounds.midY-60, width: bounds.width-80, height: 100))
        deathLabel.text = "⚰️ Alchemical Failure ⚰️\nPress to renew"
        deathLabel.numberOfLines = 0
        deathLabel.textAlignment = .center
        deathLabel.textColor = .red
        deathLabel.font = UIFont(name: "Georgia-Bold", size: 20)
        let restartBtn = UIButton(type: .system)
        restartBtn.frame = CGRect(x: bounds.midX-80, y: bounds.midY+40, width: 160, height: 50)
        restartBtn.setTitle("Rebirth", for: .normal)
        restartBtn.backgroundColor = UIColor.systemTeal
        restartBtn.layer.cornerRadius = 12
        restartBtn.addTarget(self, action: #selector(fullResurrection), for: .touchUpInside)
        defeatModal.addSubview(deathLabel)
        defeatModal.addSubview(restartBtn)
        defeatModal.tag = 888
        addSubview(defeatModal)
        modalOverlay = defeatModal
    }
    
    @objc private func fullResurrection() {
        modalOverlay?.removeFromSuperview()
        let hero = SpectralEntity(vitality: 32, tag: "Mouser Alchemist")
        let foes = [SpectralEntity(vitality: 12, tag: "Nocturnal Gnawer"), SpectralEntity(vitality: 14, tag: "Cinderpaw Brute")]
        let starter = [UmbralArcana.forgeThrust(), UmbralArcana.forgeBulwark(), UmbralArcana.forgeEclipseRush(), UmbralArcana.forgeThrust()]
        gameplayRealm = VerdantCrucible(
            activeProtagonist: hero,
            bestiary: foes,
            invocatorium: starter.shuffled(),
            ephemeralHand: [],
            sepulchrePile: [],
            residuumEnergy: 2,
            turnPhase: .playerProvidence,
            arcaneResonance: false
        )
        refreshBattlements()
        commenceTurnDrawing()
    }
    
    private func ephemeralTremorAlert(message: String) {
        let alertLabel = UILabel(frame: CGRect(x: 20, y: bounds.height-120, width: bounds.width-40, height: 44))
        alertLabel.backgroundColor = UIColor(white: 0.1, alpha: 0.9)
        alertLabel.text = message
        alertLabel.textAlignment = .center
        alertLabel.font = UIFont(name: "Chalkduster", size: 14)
        alertLabel.textColor = .orange
        alertLabel.layer.cornerRadius = 12
        alertLabel.clipsToBounds = true
        addSubview(alertLabel)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { alertLabel.removeFromSuperview() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        ambientGradient.frame = bounds
        modalOverlay?.frame = bounds
    }
}

// MARK: - Root ViewController

final class AuroralSanctumController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let battleArena = ChimericVortexView(frame: view.bounds)
        battleArena.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(battleArena)
        view.backgroundColor = .black
    }
}
