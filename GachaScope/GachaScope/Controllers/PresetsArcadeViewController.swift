import UIKit

final class PresetsViewController: UIViewController {
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupScrollView()
        setupHeader()
        setupGachaPresets()
        setupSlotPresets()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    private func setupScrollView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
        ])
    }

    private func setupHeader() {
        let lbl = UILabel()
        lbl.text = "⬡ Presets"
        lbl.font = AppTheme.Typeface.display(26)
        lbl.textColor = AppTheme.Pigment.auroraGreen
        contentStack.addArrangedSubview(lbl)
        let sub = UILabel()
        sub.text = "Tap a preset to apply it instantly."
        sub.font = AppTheme.Typeface.body(13)
        sub.textColor = AppTheme.Pigment.mistGray
        contentStack.addArrangedSubview(sub)
    }

    private func setupGachaPresets() {
        let title = makeSectionLabel("Gacha Presets")
        contentStack.addArrangedSubview(title)
        for preset in SimPreset.allGachaPresets {
            contentStack.addArrangedSubview(makeGachaPresetCard(preset))
        }
    }

    private func setupSlotPresets() {
        let title = makeSectionLabel("Slot Presets")
        contentStack.addArrangedSubview(title)
        for preset in ReelPreset.allSlotPresets {
            contentStack.addArrangedSubview(makeSlotPresetCard(preset))
        }
    }

    private func makeSectionLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = AppTheme.Typeface.headline(15)
        lbl.textColor = AppTheme.Pigment.glacierWhite
        return lbl
    }

    private func makeGachaPresetCard(_ preset: SimPreset) -> UIView {
        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .horizontal
        inner.spacing = 14
        inner.alignment = .center
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])

        let iconBg = UIView()
        iconBg.backgroundColor = AppTheme.Pigment.nebulaViolet.withAlphaComponent(0.2)
        iconBg.layer.cornerRadius = 22
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 44),
            iconBg.heightAnchor.constraint(equalToConstant: 44),
        ])
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: preset.iconName, withConfiguration: cfg))
        iconView.tintColor = AppTheme.Pigment.ssrGold
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
        ])

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4
        let nameLbl = UILabel()
        nameLbl.text = preset.displayName
        nameLbl.font = AppTheme.Typeface.headline(14)
        nameLbl.textColor = AppTheme.Pigment.glacierWhite
        let descLbl = UILabel()
        descLbl.text = preset.description
        descLbl.font = AppTheme.Typeface.caption(12)
        descLbl.textColor = AppTheme.Pigment.mistGray
        descLbl.numberOfLines = 2
        let statsLbl = UILabel()
        statsLbl.text = "SSR \(String(format: "%.1f", preset.ssrRate * 100))%  •  Pity \(preset.hardPity)"
        statsLbl.font = AppTheme.Typeface.mono(11)
        statsLbl.textColor = AppTheme.Pigment.ssrGold
        textStack.addArrangedSubview(nameLbl)
        textStack.addArrangedSubview(descLbl)
        textStack.addArrangedSubview(statsLbl)

        let applyBtn = PulseButton()
        applyBtn.setTitle("Apply", for: .normal)
        applyBtn.titleLabel?.font = AppTheme.Typeface.body(13)
        applyBtn.gradientColors = AppTheme.Pigment.gradientAccent
        applyBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            applyBtn.widthAnchor.constraint(equalToConstant: 64),
            applyBtn.heightAnchor.constraint(equalToConstant: 36),
        ])
        applyBtn.accessibilityLabel = preset.identifier
        applyBtn.addTarget(self, action: #selector(applyGachaPreset(_:)), for: .touchUpInside)

        inner.addArrangedSubview(iconBg)
        inner.addArrangedSubview(textStack)
        inner.addArrangedSubview(applyBtn)
        return card
    }

    private func makeSlotPresetCard(_ preset: ReelPreset) -> UIView {
        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .horizontal
        inner.spacing = 14
        inner.alignment = .center
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])

        let iconBg = UIView()
        iconBg.backgroundColor = AppTheme.Pigment.stellarPink.withAlphaComponent(0.2)
        iconBg.layer.cornerRadius = 22
        iconBg.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconBg.widthAnchor.constraint(equalToConstant: 44),
            iconBg.heightAnchor.constraint(equalToConstant: 44),
        ])
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: preset.iconName, withConfiguration: cfg))
        iconView.tintColor = AppTheme.Pigment.stellarPink
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconBg.addSubview(iconView)
        NSLayoutConstraint.activate([
            iconView.centerXAnchor.constraint(equalTo: iconBg.centerXAnchor),
            iconView.centerYAnchor.constraint(equalTo: iconBg.centerYAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 24),
            iconView.heightAnchor.constraint(equalToConstant: 24),
        ])

        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 4
        let nameLbl = UILabel()
        nameLbl.text = preset.displayName
        nameLbl.font = AppTheme.Typeface.headline(14)
        nameLbl.textColor = AppTheme.Pigment.glacierWhite
        let descLbl = UILabel()
        descLbl.text = preset.description
        descLbl.font = AppTheme.Typeface.caption(12)
        descLbl.textColor = AppTheme.Pigment.mistGray
        descLbl.numberOfLines = 2
        let statsLbl = UILabel()
        statsLbl.text = "Win \(String(format: "%.0f", preset.winRate * 100))%  •  Max \(Int(preset.maxWinMultiplier))x"
        statsLbl.font = AppTheme.Typeface.mono(11)
        statsLbl.textColor = AppTheme.Pigment.stellarPink
        textStack.addArrangedSubview(nameLbl)
        textStack.addArrangedSubview(descLbl)
        textStack.addArrangedSubview(statsLbl)

        let applyBtn = PulseButton()
        applyBtn.setTitle("Apply", for: .normal)
        applyBtn.titleLabel?.font = AppTheme.Typeface.body(13)
        applyBtn.gradientColors = [AppTheme.Pigment.stellarPink, UIColor(hex: "#BE185D")]
        applyBtn.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            applyBtn.widthAnchor.constraint(equalToConstant: 64),
            applyBtn.heightAnchor.constraint(equalToConstant: 36),
        ])
        applyBtn.accessibilityLabel = preset.identifier
        applyBtn.addTarget(self, action: #selector(applySlotPreset(_:)), for: .touchUpInside)

        inner.addArrangedSubview(iconBg)
        inner.addArrangedSubview(textStack)
        inner.addArrangedSubview(applyBtn)
        return card
    }

    @objc private func applyGachaPreset(_ sender: UIButton) {
        guard let id = sender.accessibilityLabel,
              let preset = SimPreset.allGachaPresets.first(where: { $0.identifier == id }) else { return }
        AppStorage.shared.ssrRate     = preset.ssrRate
        AppStorage.shared.srRate      = preset.srRate
        AppStorage.shared.hardPity    = preset.hardPity
        AppStorage.shared.softPity    = preset.softPity
        AppStorage.shared.pityEnabled = preset.pityEnabled
        Haptics.shared.successPulse()
        AlertView.show(on: self,
                             title: "Preset Applied",
                             message: "\"\(preset.displayName)\" has been applied to Gacha settings.",
                             actions: [(title: "Got it", style: .primary, handler: nil)])
    }

    @objc private func applySlotPreset(_ sender: UIButton) {
        guard let id = sender.accessibilityLabel,
              let preset = ReelPreset.allSlotPresets.first(where: { $0.identifier == id }) else { return }
        AppStorage.shared.winRate    = preset.winRate
        AppStorage.shared.bigWinRate = preset.bigWinRate
        Haptics.shared.successPulse()
        AlertView.show(on: self,
                             title: "Preset Applied",
                             message: "\"\(preset.displayName)\" has been applied to Slot settings.",
                             actions: [(title: "Got it", style: .primary, handler: nil)])
    }
}
