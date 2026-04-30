import UIKit

final class SettingsViewController: UIViewController {
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupScrollView()
        setupHeader()
        setupGeneralSection()
        setupDefaultsSection()
        setupDisclaimerSection()
        setupAboutSection()
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
        lbl.setEmojiSafeText("⚙️ Settings", font: AppTheme.Typeface.display(26), color: AppTheme.Pigment.mistGray)
        contentStack.addArrangedSubview(lbl)
    }

    private func setupGeneralSection() {
        contentStack.addArrangedSubview(makeSectionLabel("General"))
        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 0
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor),
        ])

        // Haptics toggle
        let hapticsRow = makeToggleRow(
            title: "Haptic Feedback",
            subtitle: "Vibration on interactions",
            icon: "waveform",
            iconColor: AppTheme.Pigment.nebulaViolet,
            isOn: AppStorage.shared.hapticsEnabled
        ) { isOn in
            AppStorage.shared.hapticsEnabled = isOn
        }
        inner.addArrangedSubview(hapticsRow)
        inner.addArrangedSubview(makeDivider())

        // Clear history
        let clearRow = makeActionRow(
            title: "Clear History",
            subtitle: "Remove all saved simulation results",
            icon: "trash",
            iconColor: AppTheme.Pigment.novaRed
        ) { [weak self] in
            self?.confirmClearHistory()
        }
        inner.addArrangedSubview(clearRow)
        contentStack.addArrangedSubview(card)
    }

    private func setupDefaultsSection() {
        contentStack.addArrangedSubview(makeSectionLabel("Simulation Defaults"))
        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 14
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])

        let simLabel = UILabel()
        simLabel.text = "Default Simulation Count"
        simLabel.font = AppTheme.Typeface.body(14)
        simLabel.textColor = AppTheme.Pigment.glacierWhite
        inner.addArrangedSubview(simLabel)

        let seg = UISegmentedControl(items: ["1K", "10K", "100K"])
        seg.selectedSegmentIndex = [1000, 10000, 100000].firstIndex(of: AppStorage.shared.simulationCount) ?? 0
        let selAttr: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.white]
        let normAttr: [NSAttributedString.Key: Any] = [.foregroundColor: AppTheme.Pigment.mistGray]
        seg.setTitleTextAttributes(selAttr, for: .selected)
        seg.setTitleTextAttributes(normAttr, for: .normal)
        seg.selectedSegmentTintColor = AppTheme.Pigment.nebulaViolet
        seg.backgroundColor = AppTheme.Pigment.crystalBorder
        seg.addTarget(self, action: #selector(simCountChanged(_:)), for: .valueChanged)
        inner.addArrangedSubview(seg)
        contentStack.addArrangedSubview(card)
    }

    private func setupDisclaimerSection() {
        contentStack.addArrangedSubview(makeSectionLabel("Legal & Disclaimer"))
        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])

        let warnRow = UIStackView()
        warnRow.axis = .horizontal
        warnRow.spacing = 8
        warnRow.alignment = .center
        let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let ico = UIImageView(image: UIImage(systemName: "checkmark.shield.fill", withConfiguration: cfg))
        ico.tintColor = AppTheme.Pigment.auroraGreen
        ico.contentMode = .scaleAspectFit
        ico.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let headLbl = UILabel()
        headLbl.text = "No Gambling — Educational Tool Only"
        headLbl.font = AppTheme.Typeface.headline(13)
        headLbl.textColor = AppTheme.Pigment.auroraGreen
        headLbl.numberOfLines = 0
        warnRow.addArrangedSubview(ico)
        warnRow.addArrangedSubview(headLbl)
        inner.addArrangedSubview(warnRow)

        let disclaimer = UILabel()
        disclaimer.text = "GachaScope is a mathematical probability analysis tool. It contains no real-money gambling, wagering, prizes, or connections to any commercial game platform. All simulations use seedless PRNG and produce results that reflect statistical distributions only.\n\nEach trial is an independent event. Prior simulation outcomes do not affect future probabilities. Results are for educational and game design research purposes only."
        disclaimer.font = AppTheme.Typeface.caption(12)
        disclaimer.textColor = AppTheme.Pigment.mistGray
        disclaimer.numberOfLines = 0
        inner.addArrangedSubview(disclaimer)

        contentStack.addArrangedSubview(card)
    }

    private func setupAboutSection() {
        contentStack.addArrangedSubview(makeSectionLabel("About"))
        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        inner.alignment = .center
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])

        let cfg = UIImage.SymbolConfiguration(pointSize: 40, weight: .bold)
        let icon = UIImageView(image: UIImage(systemName: "sparkles", withConfiguration: cfg))
        icon.tintColor = AppTheme.Pigment.ssrGold
        icon.contentMode = .scaleAspectFit
        icon.heightAnchor.constraint(equalToConstant: 50).isActive = true

        let appName = UILabel()
        appName.text = "GachaScope"
        appName.font = AppTheme.Typeface.display(22)
        appName.textColor = AppTheme.Pigment.glacierWhite
        appName.textAlignment = .center

        let version = UILabel()
        version.text = "Version 1.0.0"
        version.font = AppTheme.Typeface.caption(13)
        version.textColor = AppTheme.Pigment.mistGray
        version.textAlignment = .center

        let desc = UILabel()
        desc.text = "A probability simulator and analysis tool for gacha and slot mechanics. For educational and game design purposes only."
        desc.font = AppTheme.Typeface.caption(12)
        desc.textColor = AppTheme.Pigment.mistGray
        desc.textAlignment = .center
        desc.numberOfLines = 0

        [icon, appName, version, desc].forEach { inner.addArrangedSubview($0) }
        contentStack.addArrangedSubview(card)
    }

    // MARK: - Helpers
    private func makeSectionLabel(_ text: String) -> UILabel {
        let lbl = UILabel()
        lbl.text = text.uppercased()
        lbl.font = AppTheme.Typeface.caption(11)
        lbl.textColor = AppTheme.Pigment.mistGray
        return lbl
    }

    private func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = AppTheme.Pigment.crystalBorder
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return v
    }

    private func makeToggleRow(title: String, subtitle: String, icon: String, iconColor: UIColor,
                                isOn: Bool, onChange: @escaping (Bool) -> Void) -> UIView {
        let row = UIView()
        row.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true

        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: cfg))
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = AppTheme.Typeface.body(14)
        titleLbl.textColor = AppTheme.Pigment.glacierWhite

        let subLbl = UILabel()
        subLbl.text = subtitle
        subLbl.font = AppTheme.Typeface.caption(12)
        subLbl.textColor = AppTheme.Pigment.mistGray

        let textStack = UIStackView(arrangedSubviews: [titleLbl, subLbl])
        textStack.axis = .vertical
        textStack.spacing = 2

        let toggle = UISwitch()
        toggle.isOn = isOn
        toggle.onTintColor = AppTheme.Pigment.nebulaViolet
        toggle.addAction(UIAction { _ in onChange(toggle.isOn) }, for: .valueChanged)

        let hStack = UIStackView(arrangedSubviews: [iconView, textStack, toggle])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -12),
            hStack.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
        ])
        return row
    }

    private func makeActionRow(title: String, subtitle: String, icon: String,
                                iconColor: UIColor, action: @escaping () -> Void) -> UIView {
        let row = UIView()
        row.heightAnchor.constraint(greaterThanOrEqualToConstant: 60).isActive = true
        row.isUserInteractionEnabled = true

        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let iconView = UIImageView(image: UIImage(systemName: icon, withConfiguration: cfg))
        iconView.tintColor = iconColor
        iconView.contentMode = .scaleAspectFit
        iconView.translatesAutoresizingMaskIntoConstraints = false
        iconView.widthAnchor.constraint(equalToConstant: 24).isActive = true

        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.font = AppTheme.Typeface.body(14)
        titleLbl.textColor = iconColor

        let subLbl = UILabel()
        subLbl.text = subtitle
        subLbl.font = AppTheme.Typeface.caption(12)
        subLbl.textColor = AppTheme.Pigment.mistGray

        let textStack = UIStackView(arrangedSubviews: [titleLbl, subLbl])
        textStack.axis = .vertical
        textStack.spacing = 2

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = AppTheme.Pigment.mistGray
        chevron.contentMode = .scaleAspectFit
        chevron.widthAnchor.constraint(equalToConstant: 14).isActive = true

        let hStack = UIStackView(arrangedSubviews: [iconView, textStack, chevron])
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: row.topAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -12),
            hStack.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 16),
            hStack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -16),
        ])

        let tap = UITapGestureRecognizer(target: nil, action: nil)
        tap.addTarget(self, action: #selector(rowTapped(_:)))
        row.addGestureRecognizer(tap)
        row.tag = contentStack.arrangedSubviews.count
        objc_setAssociatedObject(row, &AssociatedKeys.actionKey, ActionWrapper(action), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return row
    }

    @objc private func rowTapped(_ gr: UITapGestureRecognizer) {
        guard let wrapper = objc_getAssociatedObject(gr.view as Any, &AssociatedKeys.actionKey) as? ActionWrapper else { return }
        Haptics.shared.tapMedium()
        wrapper.action()
    }

    @objc private func simCountChanged(_ seg: UISegmentedControl) {
        let counts = [1000, 10000, 100000]
        AppStorage.shared.simulationCount = counts[seg.selectedSegmentIndex]
        Haptics.shared.selectItem()
    }

    private func confirmClearHistory() {
        AlertView.show(on: self,
            title: "Clear History",
            message: "This will remove all saved simulation results. This action cannot be undone.",
            actions: [
                (title: "Cancel",    style: .secondary,    handler: nil),
                (title: "Clear All", style: .destructive,  handler: {
                    AppStorage.shared.clearAllHistory()
                    Haptics.shared.successPulse()
                })
            ])
    }
}

private enum AssociatedKeys {
    static var actionKey = "actionKey"
}

private final class ActionWrapper {
    let action: () -> Void
    init(_ action: @escaping () -> Void) { self.action = action }
}
