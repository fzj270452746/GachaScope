import UIKit

final class SlotsViewController: UIViewController {
    // MARK: - State
    private var reelConfig: ReelConfig = ReelConfig.classicFruit()
    private var simCount: Int = AppStorage.shared.simulationCount
    private var lastResult: ReelSlotResult?
    var onSlotResult: ((ReelSlotResult) -> Void)?

    // MARK: - UI Top-level
    private let scrollView    = UIScrollView()
    private let contentStack  = UIStackView()

    // Symbol editor
    private let rtpValueLabel    = UILabel()
    private let symbolEditorCard = GlowCard()
    private var symbolEditorInner: UIStackView?

    // Sim controls
    private let simSegment   = UISegmentedControl(items: ["1K", "10K", "100K"])
    private let simulateBtn  = PulseButton()

    // Results
    private let rtpBadge         = StatBadgeView(title: "Sim RTP",      value: "—", accentColor: AppTheme.Pigment.auroraGreen)
    private let winsBadge         = StatBadgeView(title: "Total Wins",   value: "—", accentColor: AppTheme.Pigment.prismaticBlue)
    private let bigWinsBadge      = StatBadgeView(title: "Jackpots",     value: "—", accentColor: AppTheme.Pigment.ssrGold)
    private let lossStreakBadge   = StatBadgeView(title: "Max Miss Run", value: "—", accentColor: AppTheme.Pigment.novaRed)
    private let symFreqCard       = GlowCard()
    private let symFreqChart      = SymbolFrequencyChartView()
    private let balanceCard       = GlowCard()
    private let balanceChart      = BalanceCurveView()
    private let streakCard        = GlowCard()
    private let streakChart       = StreakFlameView()
    private let insightCard       = GlowCard()
    private let insightStack      = UIStackView()
    private let loadingOverlay    = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupScrollView()
        setupHeader()
        setupPresetPicker()
        setupSymbolEditor()
        setupSimControl()
        setupSimulateButton()
        setupStatsGrid()
        setupSymFreqCard()
        setupCharts()
        setupInsightCard()
        setupLoadingOverlay()
    }
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }

    // MARK: - Scroll
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

    // MARK: - Header
    private func setupHeader() {
        let lbl = UILabel()
        lbl.text = "◈ Reward Cycle Engine"
        lbl.font = AppTheme.Typeface.display(26)
        lbl.textColor = AppTheme.Pigment.stellarPink
        contentStack.addArrangedSubview(lbl)
        let sub = UILabel()
        sub.text = "Configure reel symbols, weights, and payouts. Simulate to analyze probability distributions."
        sub.font = AppTheme.Typeface.body(13)
        sub.textColor = AppTheme.Pigment.mistGray
        sub.numberOfLines = 0
        contentStack.addArrangedSubview(sub)
    }

    // MARK: - Preset Picker
    private func setupPresetPicker() {
        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
        ])
        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.distribution = .equalSpacing
        titleRow.alignment = .center
        let titleLbl = makeLabel("Symbol Presets", font: AppTheme.Typeface.headline(15), color: AppTheme.Pigment.glacierWhite)
        let subLbl   = makeLabel("Quick-load a reel configuration", font: AppTheme.Typeface.caption(11), color: AppTheme.Pigment.mistGray)
        let hdr = UIStackView(arrangedSubviews: [titleLbl, subLbl])
        hdr.axis = .vertical
        hdr.spacing = 2
        titleRow.addArrangedSubview(hdr)
        inner.addArrangedSubview(titleRow)

        let presets: [(String, String, UIColor, () -> ReelConfig)] = [
            ("leaf.fill", "Classic Fruit",  AppTheme.Pigment.ssrGold,     ReelConfig.classicFruit),
            ("rocket.fill", "Space Quest",    AppTheme.Pigment.prismaticBlue, ReelConfig.spaceQuest),
            ("shield.lefthalf.filled", "Mythic Realm",  AppTheme.Pigment.nebulaViolet, ReelConfig.mythicRealm),
        ]
        let btnRow = UIStackView()
        btnRow.axis = .horizontal
        btnRow.spacing = 10
        btnRow.distribution = .fillEqually
        for (iconName, name, color, factory) in presets {
            let btn = makePresetButton(iconName: iconName, name: name, color: color, factory: factory)
            btnRow.addArrangedSubview(btn)
        }
        inner.addArrangedSubview(btnRow)
        contentStack.addArrangedSubview(card)
    }

    private func makePresetButton(iconName: String, name: String, color: UIColor, factory: @escaping () -> ReelConfig) -> UIView {
        let btn = UIButton(type: .system)
        btn.backgroundColor = color.withAlphaComponent(0.12)
        btn.layer.cornerRadius = 10
        btn.layer.borderWidth = 1
        btn.layer.borderColor = color.withAlphaComponent(0.35).cgColor
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = color
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 28).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 28).isActive = true
        let nameLbl = makeLabel(name, font: AppTheme.Typeface.caption(11), color: color)
        nameLbl.textAlignment = .center
        nameLbl.numberOfLines = 2
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(nameLbl)
        btn.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: btn.leadingAnchor, constant: 6),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: btn.trailingAnchor, constant: -6),
            btn.heightAnchor.constraint(equalToConstant: 72),
        ])
        btn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            self.reelConfig = factory()
            self.rebuildSymbolEditor()
            Haptics.shared.successPulse()
        }, for: .touchUpInside)
        return btn
    }

    // MARK: - Symbol Editor
    private func setupSymbolEditor() {
        symbolEditorCard.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(symbolEditorCard)
        rebuildSymbolEditor()
    }

    private func rebuildSymbolEditor() {
        // Clear old content
        symbolEditorCard.subviews.forEach { $0.removeFromSuperview() }

        let outer = UIStackView()
        outer.axis = .vertical
        outer.spacing = 0
        outer.translatesAutoresizingMaskIntoConstraints = false
        symbolEditorCard.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: symbolEditorCard.topAnchor, constant: 14),
            outer.bottomAnchor.constraint(equalTo: symbolEditorCard.bottomAnchor, constant: -14),
            outer.leadingAnchor.constraint(equalTo: symbolEditorCard.leadingAnchor, constant: 14),
            outer.trailingAnchor.constraint(equalTo: symbolEditorCard.trailingAnchor, constant: -14),
        ])
        symbolEditorInner = outer

        // Header with live RTP
        let headerRow = UIStackView()
        headerRow.axis = .horizontal
        headerRow.distribution = .equalSpacing
        headerRow.alignment = .center
        let titleLbl = makeLabel("Symbol Configuration", font: AppTheme.Typeface.headline(15), color: AppTheme.Pigment.glacierWhite)
        let rtpStack = UIStackView()
        rtpStack.axis = .vertical
        rtpStack.alignment = .trailing
        rtpStack.spacing = 2
        let rtpTitle = makeLabel("Theoretical RTP", font: AppTheme.Typeface.caption(10), color: AppTheme.Pigment.mistGray)
        rtpValueLabel.font = AppTheme.Typeface.mono(14)
        rtpValueLabel.textColor = AppTheme.Pigment.auroraGreen
        rtpStack.addArrangedSubview(rtpTitle)
        rtpStack.addArrangedSubview(rtpValueLabel)
        headerRow.addArrangedSubview(titleLbl)
        headerRow.addArrangedSubview(rtpStack)
        outer.addArrangedSubview(headerRow)
        outer.addArrangedSubview(makeSpacing(10))

        // Column header
        let colHeader = makeColumnHeaderRow()
        outer.addArrangedSubview(colHeader)
        outer.addArrangedSubview(makeDivider())

        // Symbol rows
        for (i, sym) in reelConfig.symbols.enumerated() {
            let row = buildSymbolRow(index: i, symbol: sym)
            outer.addArrangedSubview(row)
            if i < reelConfig.symbols.count - 1 {
                outer.addArrangedSubview(makeDivider())
            }
        }

        outer.addArrangedSubview(makeSpacing(10))

        // Scatter config row
        let scatterRow = buildScatterConfigRow()
        outer.addArrangedSubview(scatterRow)

        updateRTPLabel()
    }

    private func makeColumnHeaderRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        let symLbl   = makeLabel("Symbol",  font: AppTheme.Typeface.caption(10), color: AppTheme.Pigment.mistGray)
        let wLbl     = makeLabel("Weight",  font: AppTheme.Typeface.caption(10), color: AppTheme.Pigment.mistGray)
        let p3Lbl    = makeLabel("3× Pay",  font: AppTheme.Typeface.caption(10), color: AppTheme.Pigment.mistGray)
        let p2Lbl    = makeLabel("2× Pay",  font: AppTheme.Typeface.caption(10), color: AppTheme.Pigment.mistGray)
        wLbl.textAlignment = .center
        p3Lbl.textAlignment = .center
        p2Lbl.textAlignment = .center
        symLbl.widthAnchor.constraint(equalToConstant: 80).isActive = true
        wLbl.widthAnchor.constraint(equalToConstant: 68).isActive = true
        p3Lbl.widthAnchor.constraint(equalToConstant: 68).isActive = true
        p2Lbl.widthAnchor.constraint(equalToConstant: 68).isActive = true
        row.addArrangedSubview(symLbl)
        row.addArrangedSubview(wLbl)
        row.addArrangedSubview(p3Lbl)
        row.addArrangedSubview(p2Lbl)
        return row
    }

    private func buildSymbolRow(index: Int, symbol: ReelSymbol) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 4
        row.alignment = .center
        row.layoutMargins = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        row.isLayoutMarginsRelativeArrangement = true

        // Symbol label
        let symStack = UIStackView()
        symStack.axis = .horizontal
        symStack.spacing = 4
        symStack.alignment = .center
        symStack.widthAnchor.constraint(equalToConstant: 80).isActive = true
        let iconView = UIImageView(image: ReelSymbolArtwork.image(for: symbol.identifier, pointSize: 18, weight: .semibold))
        iconView.tintColor = symbol.isWild
            ? AppTheme.Pigment.ssrGold
            : (symbol.isScatter ? AppTheme.Pigment.stellarPink : AppTheme.Pigment.glacierWhite)
        iconView.contentMode = .scaleAspectFit
        iconView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let nameStack = UIStackView()
        nameStack.axis = .vertical
        nameStack.spacing = 1
        let nameLbl = makeLabel(symbol.name, font: AppTheme.Typeface.caption(11), color: AppTheme.Pigment.glacierWhite)
        nameLbl.numberOfLines = 1
        nameStack.addArrangedSubview(nameLbl)
        // Special badge
        if symbol.isWild {
            let badge = makeBadge("WILD", color: AppTheme.Pigment.ssrGold)
            nameStack.addArrangedSubview(badge)
        } else if symbol.isScatter {
            let badge = makeBadge("SCAT", color: AppTheme.Pigment.stellarPink)
            nameStack.addArrangedSubview(badge)
        }
        symStack.addArrangedSubview(iconView)
        symStack.addArrangedSubview(nameStack)

        // Weight control
        let weightCtrl = makeIntControl(
            value: symbol.weight, min: 0, max: 20,
            color: symbol.isWild || symbol.isScatter ? AppTheme.Pigment.ssrGold : AppTheme.Pigment.stellarPink,
            width: 68
        ) { [weak self] newVal in
            guard let self = self else { return }
            self.reelConfig.symbols[index].weight = newVal
            self.updateRTPLabel()
        }

        // 3× payout control (disabled for wild/scatter)
        let pay3Color = symbol.isWild || symbol.isScatter ? AppTheme.Pigment.crystalBorder : AppTheme.Pigment.auroraGreen
        let pay3Ctrl = makeDoubleControl(
            value: symbol.payout3, step: 1.0, min: 0, max: 200,
            color: pay3Color, width: 68,
            enabled: !symbol.isWild && !symbol.isScatter
        ) { [weak self] newVal in
            guard let self = self else { return }
            self.reelConfig.symbols[index].payout3 = newVal
            self.updateRTPLabel()
        }

        // 2× payout control (only non-wild, non-scatter)
        let pay2Color = symbol.isWild || symbol.isScatter ? AppTheme.Pigment.crystalBorder : AppTheme.Pigment.prismaticBlue
        let pay2Ctrl = makeDoubleControl(
            value: symbol.payout2, step: 0.5, min: 0, max: 20,
            color: pay2Color, width: 68,
            enabled: !symbol.isWild && !symbol.isScatter
        ) { [weak self] newVal in
            guard let self = self else { return }
            self.reelConfig.symbols[index].payout2 = newVal
            self.updateRTPLabel()
        }

        row.addArrangedSubview(symStack)
        row.addArrangedSubview(weightCtrl)
        row.addArrangedSubview(pay3Ctrl)
        row.addArrangedSubview(pay2Ctrl)
        return row
    }

    private func buildScatterConfigRow() -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .center
        let lbl = makeLabel("Scatter Pay ×", font: AppTheme.Typeface.body(13), color: AppTheme.Pigment.mistGray)
        let ctrl = makeDoubleControl(
            value: reelConfig.scatterPayout, step: 1.0, min: 2, max: 50,
            color: AppTheme.Pigment.stellarPink, width: 80, enabled: true
        ) { [weak self] newVal in
            guard let self = self else { return }
            self.reelConfig.scatterPayout = newVal
            self.updateRTPLabel()
        }
        row.addArrangedSubview(lbl)
        row.addArrangedSubview(UIView())  // spacer
        row.addArrangedSubview(ctrl)
        return row
    }

    // MARK: - Control factory helpers
    /// Integer +/- control returning new value via closure
    private func makeIntControl(value: Int, min minVal: Int, max maxVal: Int, color: UIColor, width: CGFloat, onChange: @escaping (Int) -> Void) -> UIView {
        var current = value
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 2
        container.alignment = .center
        container.widthAnchor.constraint(equalToConstant: width).isActive = true

        let minusBtn = makeStepBtn("-")
        let valLbl   = UILabel()
        valLbl.text  = "\(current)"
        valLbl.font  = AppTheme.Typeface.mono(12)
        valLbl.textColor = color
        valLbl.textAlignment = .center
        valLbl.adjustsFontSizeToFitWidth = true
        valLbl.minimumScaleFactor = 0.7
        valLbl.widthAnchor.constraint(equalToConstant: 24).isActive = true
        let plusBtn  = makeStepBtn("+")

        container.addArrangedSubview(minusBtn)
        container.addArrangedSubview(valLbl)
        container.addArrangedSubview(plusBtn)

        minusBtn.addAction(UIAction { _ in
            if current > minVal {
                current -= 1
                valLbl.text = "\(current)"
                onChange(current)
                Haptics.shared.selectItem()
            }
        }, for: .touchUpInside)
        plusBtn.addAction(UIAction { _ in
            if current < maxVal {
                current += 1
                valLbl.text = "\(current)"
                onChange(current)
                Haptics.shared.selectItem()
            }
        }, for: .touchUpInside)
        return container
    }

    private func makeDoubleControl(value: Double, step: Double, min minVal: Double, max maxVal: Double,
                                    color: UIColor, width: CGFloat, enabled: Bool,
                                    onChange: @escaping (Double) -> Void) -> UIView {
        var current = value
        let container = UIStackView()
        container.axis = .horizontal
        container.spacing = 2
        container.alignment = .center
        container.widthAnchor.constraint(equalToConstant: width).isActive = true
        container.alpha = enabled ? 1.0 : 0.3

        let minusBtn = makeStepBtn("-")
        let valLbl   = UILabel()
        valLbl.text  = formatPayout(current)
        valLbl.font  = AppTheme.Typeface.mono(11)
        valLbl.textColor = color
        valLbl.textAlignment = .center
        valLbl.adjustsFontSizeToFitWidth = true
        let plusBtn  = makeStepBtn("+")

        minusBtn.isEnabled = enabled
        plusBtn.isEnabled  = enabled

        container.addArrangedSubview(minusBtn)
        container.addArrangedSubview(valLbl)
        container.addArrangedSubview(plusBtn)

        minusBtn.addAction(UIAction { _ in
            if current > minVal {
                current = Swift.max(minVal, current - step)
                valLbl.text = self.formatPayout(current)
                onChange(current)
                Haptics.shared.selectItem()
            }
        }, for: .touchUpInside)
        plusBtn.addAction(UIAction { _ in
            if current < maxVal {
                current = Swift.min(maxVal, current + step)
                valLbl.text = self.formatPayout(current)
                onChange(current)
                Haptics.shared.selectItem()
            }
        }, for: .touchUpInside)
        return container
    }

    private func makeStepBtn(_ title: String) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = AppTheme.Typeface.headline(14)
        btn.tintColor = AppTheme.Pigment.mistGray
        btn.widthAnchor.constraint(equalToConstant: 16).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 28).isActive = true
        return btn
    }

    private func formatPayout(_ v: Double) -> String {
        v == Double(Int(v)) ? "\(Int(v))×" : String(format: "%.1f×", v)
    }

    private func makeBadge(_ text: String, color: UIColor) -> UIView {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = AppTheme.Typeface.caption(8)
        lbl.textColor = color
        lbl.backgroundColor = color.withAlphaComponent(0.15)
        lbl.layer.cornerRadius = 3
        lbl.layer.masksToBounds = true
        lbl.textAlignment = .center
        return lbl
    }

    private func updateRTPLabel() {
        let rtp = reelConfig.theoreticalRTP
        rtpValueLabel.text = String(format: "≈ %.1f%%", rtp * 100)
        rtpValueLabel.textColor = rtp >= 0.85 ? AppTheme.Pigment.auroraGreen
                                : rtp >= 0.60 ? AppTheme.Pigment.ssrGold
                                : AppTheme.Pigment.novaRed
    }

    // MARK: - Sim count
    private func setupSimControl() {
        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .vertical; inner.spacing = 12
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])
        inner.addArrangedSubview(makeLabel("Simulation Count", font: AppTheme.Typeface.headline(15), color: AppTheme.Pigment.glacierWhite))
        simSegment.selectedSegmentIndex = [1000, 10000, 100000].firstIndex(of: simCount) ?? 0
        simSegment.selectedSegmentTintColor = AppTheme.Pigment.stellarPink
        simSegment.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        simSegment.setTitleTextAttributes([.foregroundColor: AppTheme.Pigment.mistGray], for: .normal)
        simSegment.backgroundColor = AppTheme.Pigment.crystalBorder.withAlphaComponent(0.3)
        simSegment.addTarget(self, action: #selector(simSegmentChanged), for: .valueChanged)
        inner.addArrangedSubview(simSegment)
        contentStack.addArrangedSubview(card)
    }

    private func setupSimulateButton() {
        simulateBtn.setTitle("▶  RUN SIMULATION", for: .normal)
        simulateBtn.gradientColors = [AppTheme.Pigment.stellarPink, AppTheme.Pigment.nebulaViolet]
        simulateBtn.translatesAutoresizingMaskIntoConstraints = false
        simulateBtn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        simulateBtn.addTarget(self, action: #selector(runSimulation), for: .touchUpInside)
        contentStack.addArrangedSubview(simulateBtn)
    }

    // MARK: - Stats + Charts
    private func setupStatsGrid() {
        let grid = UIStackView(arrangedSubviews: [
            makeRow([rtpBadge, winsBadge]),
            makeRow([bigWinsBadge, lossStreakBadge])
        ])
        grid.axis = .vertical; grid.spacing = 10
        contentStack.addArrangedSubview(grid)
    }

    private func setupSymFreqCard() {
        symFreqCard.translatesAutoresizingMaskIntoConstraints = false
        symFreqCard.isHidden = true
        let titleLbl = makeLabel("Symbol Hit Distribution", font: AppTheme.Typeface.headline(14), color: AppTheme.Pigment.glacierWhite)
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        symFreqChart.backgroundColor = .clear
        symFreqChart.translatesAutoresizingMaskIntoConstraints = false
        symFreqCard.addSubview(titleLbl)
        symFreqCard.addSubview(symFreqChart)
        NSLayoutConstraint.activate([
            titleLbl.topAnchor.constraint(equalTo: symFreqCard.topAnchor, constant: 14),
            titleLbl.leadingAnchor.constraint(equalTo: symFreqCard.leadingAnchor, constant: 16),
            symFreqChart.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 10),
            symFreqChart.leadingAnchor.constraint(equalTo: symFreqCard.leadingAnchor, constant: 12),
            symFreqChart.trailingAnchor.constraint(equalTo: symFreqCard.trailingAnchor, constant: -12),
            symFreqChart.bottomAnchor.constraint(equalTo: symFreqCard.bottomAnchor, constant: -12),
        ])
        contentStack.addArrangedSubview(symFreqCard)
    }

    private func setupCharts() {
        // Balance
        let balTitle = makeLabel("Balance Simulation", font: AppTheme.Typeface.headline(14), color: AppTheme.Pigment.glacierWhite)
        balTitle.translatesAutoresizingMaskIntoConstraints = false
        balanceChart.translatesAutoresizingMaskIntoConstraints = false
        balanceCard.addSubview(balTitle)
        balanceCard.addSubview(balanceChart)
        NSLayoutConstraint.activate([
            balTitle.topAnchor.constraint(equalTo: balanceCard.topAnchor, constant: 14),
            balTitle.leadingAnchor.constraint(equalTo: balanceCard.leadingAnchor, constant: 16),
            balanceChart.topAnchor.constraint(equalTo: balTitle.bottomAnchor, constant: 10),
            balanceChart.leadingAnchor.constraint(equalTo: balanceCard.leadingAnchor, constant: 8),
            balanceChart.trailingAnchor.constraint(equalTo: balanceCard.trailingAnchor, constant: -8),
            balanceChart.bottomAnchor.constraint(equalTo: balanceCard.bottomAnchor, constant: -12),
            balanceChart.heightAnchor.constraint(equalToConstant: 160),
        ])
        contentStack.addArrangedSubview(balanceCard)

        // Streak
        let strTitle = makeLabel("Miss Streak Analysis", font: AppTheme.Typeface.headline(14), color: AppTheme.Pigment.glacierWhite)
        strTitle.translatesAutoresizingMaskIntoConstraints = false
        streakChart.translatesAutoresizingMaskIntoConstraints = false
        streakCard.addSubview(strTitle)
        streakCard.addSubview(streakChart)
        NSLayoutConstraint.activate([
            strTitle.topAnchor.constraint(equalTo: streakCard.topAnchor, constant: 14),
            strTitle.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 16),
            streakChart.topAnchor.constraint(equalTo: strTitle.bottomAnchor, constant: 10),
            streakChart.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 8),
            streakChart.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor, constant: -8),
            streakChart.bottomAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: -12),
            streakChart.heightAnchor.constraint(equalToConstant: 140),
        ])
        contentStack.addArrangedSubview(streakCard)
    }

    private func setupInsightCard() {
        insightStack.axis = .vertical; insightStack.spacing = 10
        insightStack.translatesAutoresizingMaskIntoConstraints = false
        insightCard.addSubview(insightStack)
        NSLayoutConstraint.activate([
            insightStack.topAnchor.constraint(equalTo: insightCard.topAnchor, constant: 14),
            insightStack.bottomAnchor.constraint(equalTo: insightCard.bottomAnchor, constant: -14),
            insightStack.leadingAnchor.constraint(equalTo: insightCard.leadingAnchor, constant: 16),
            insightStack.trailingAnchor.constraint(equalTo: insightCard.trailingAnchor, constant: -16),
        ])
        insightCard.isHidden = true
        contentStack.addArrangedSubview(insightCard)
    }

    private func setupLoadingOverlay() {
        loadingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        loadingOverlay.isHidden = true
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = AppTheme.Pigment.stellarPink
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.addSubview(activityIndicator)
        view.addSubview(loadingOverlay)
        NSLayoutConstraint.activate([
            loadingOverlay.topAnchor.constraint(equalTo: view.topAnchor),
            loadingOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            loadingOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            loadingOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: loadingOverlay.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loadingOverlay.centerYAnchor),
        ])
    }

    // MARK: - Actions
    @objc private func simSegmentChanged() {
        simCount = [1000, 10000, 100000][simSegment.selectedSegmentIndex]
        AppStorage.shared.simulationCount = simCount
    }

    @objc private func runSimulation() {
        simulateBtn.animatePulse()
        Haptics.shared.tapHeavy()
        loadingOverlay.isHidden = false
        activityIndicator.startAnimating()
        let cfg = reelConfig

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let result = ReelSlotEngine.shared.runSimulation(config: cfg, totalSpins: self.simCount)
            DispatchQueue.main.async {
                self.lastResult = result
                self.updateUI(with: result)
                self.loadingOverlay.isHidden = true
                self.activityIndicator.stopAnimating()
                Haptics.shared.successPulse()
                let summary = String(format: "RTP:%.1f%% Wins:%d Jackpots:%d MaxMiss:%d",
                                     result.rtp * 100, result.totalWins, result.bigWins,
                                     result.maxConsecutiveLosses)
                AppStorage.shared.appendSlotHistory(summary)
                self.onSlotResult?(result)
            }
        }
    }

    // MARK: - Update UI
    private func updateUI(with result: ReelSlotResult) {
        rtpBadge.updateValue(String(format: "%.1f%%", result.rtp * 100))
        winsBadge.updateValue("\(result.totalWins)")
        bigWinsBadge.updateValue("\(result.bigWins)")
        lossStreakBadge.updateValue("\(result.maxConsecutiveLosses)")

        updateSymFreqChart(result: result)

        let step = max(1, result.spins.count / 200)
        var lossRun = 0
        var streaks: [Int] = []
        for (i, spin) in result.spins.enumerated() {
            if !spin.isWin { lossRun += 1 } else { lossRun = 0 }
            if i % step == 0 { streaks.append(lossRun) }
        }
        streakChart.setStreaks(streaks)
        balanceChart.setCurve(result.balanceCurve)
        populateSlotInsightCard(result: result)
    }

    private func updateSymFreqChart(result: ReelSlotResult) {
        let palette: [UIColor] = [
            AppTheme.Pigment.ssrGold,
            AppTheme.Pigment.srPurple,
            AppTheme.Pigment.prismaticBlue,
            AppTheme.Pigment.auroraGreen,
            AppTheme.Pigment.stellarPink,
            AppTheme.Pigment.nebulaViolet,
            AppTheme.Pigment.ssrGold.withAlphaComponent(0.7),
            AppTheme.Pigment.stellarPink.withAlphaComponent(0.6),
        ]
        var entries: [SymbolFrequencyChartView.SymEntry] = []
        for (i, sym) in result.config.symbols.enumerated() {
            let hits = result.symbolHitCounts[sym.identifier] ?? 0
            let color = palette[i % palette.count]
            entries.append(.init(identifier: sym.identifier, emoji: sym.emoji, name: sym.name,
                                 hits: hits, weight: sym.weight, color: color))
        }
        entries = entries.filter { $0.weight > 0 }.sorted { $0.hits > $1.hits }
        let totalHits = entries.reduce(0) { $0 + $1.hits }

        // Update height constraint based on entry count
        let neededHeight = CGFloat(max(1, entries.count)) * 32
        symFreqChart.constraints.filter { $0.firstAttribute == .height }.forEach {
            symFreqChart.removeConstraint($0)
        }
        symFreqChart.heightAnchor.constraint(equalToConstant: neededHeight).isActive = true

        symFreqChart.setEntries(entries, total: totalHits)
        symFreqCard.isHidden = entries.isEmpty
    }

    // MARK: - Insight card
    private func populateSlotInsightCard(result: ReelSlotResult) {
        insightStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let header = UILabel()
        header.text = "Statistical Insights"
        header.font = AppTheme.Typeface.headline(14)
        header.textColor = AppTheme.Pigment.glacierWhite
        insightStack.addArrangedSubview(header)
        let div = UIView(); div.backgroundColor = AppTheme.Pigment.crystalBorder
        div.heightAnchor.constraint(equalToConstant: 1).isActive = true
        insightStack.addArrangedSubview(div)

        let theoRTP = result.config.theoreticalRTP
        let rtpDelta = (result.rtp - theoRTP) * 100
        insightStack.addArrangedSubview(makeInsightRow(
            icon: "percent", iconColor: AppTheme.Pigment.auroraGreen,
            text: "Return-to-Player: \(String(format: "%.2f%%", result.rtp * 100))  ·  Theoretical: \(String(format: "%.2f%%", theoRTP * 100))",
            subtext: "Delta \(String(format: "%+.2f%%", rtpDelta)) — within expected PRNG variance for \(result.totalSpins) spins",
            subtextColor: abs(rtpDelta) < 8 ? AppTheme.Pigment.auroraGreen : AppTheme.Pigment.ssrGold
        ))

        let hitEveryN = result.winRateActual > 0 ? 1.0 / result.winRateActual : 0
        insightStack.addArrangedSubview(makeInsightRow(
            icon: "target", iconColor: AppTheme.Pigment.prismaticBlue,
            text: "Win rate: \(String(format: "%.2f%%", result.winRateActual * 100)) — 1 win per \(String(format: "%.1f", hitEveryN)) spins",
            subtext: "E[X] = 1/p = 1/\(String(format: "%.4f", result.winRateActual)) ≈ \(String(format: "%.1f", hitEveryN)) spins",
            subtextColor: AppTheme.Pigment.mistGray
        ))

        let p99Miss = result.winRateActual > 0
            ? Int(ceil(log(0.01) / log(1 - result.winRateActual))) : 0
        let missColor: UIColor = result.maxConsecutiveLosses > p99Miss
            ? AppTheme.Pigment.novaRed : AppTheme.Pigment.mistGray
        insightStack.addArrangedSubview(makeInsightRow(
            icon: "xmark.circle", iconColor: AppTheme.Pigment.novaRed,
            text: "Longest miss streak: \(result.maxConsecutiveLosses)  ·  P99 streak: \(p99Miss)",
            subtext: result.maxConsecutiveLosses > p99Miss
                ? "⚠️ Observed miss streak exceeds 99th percentile threshold"
                : "Miss streak within normal statistical range",
            subtextColor: missColor
        ))

        // Jackpot symbol
        if let topEntry = result.symbolHitCounts.max(by: { $0.value < $1.value }),
           let topSym = result.config.symbols.first(where: { $0.identifier == topEntry.key }) {
            insightStack.addArrangedSubview(makeInsightRow(
                icon: "star.fill", iconColor: AppTheme.Pigment.ssrGold,
                text: "Most-won symbol: \(topSym.name) — \(topEntry.value) wins",
                subtext: "3× payout: \(formatPayout(topSym.payout3))  ·  Weight: \(topSym.weight)",
                subtextColor: AppTheme.Pigment.ssrGold
            ))
        }

        insightCard.isHidden = false
    }

    private func makeInsightRow(icon: String, iconColor: UIColor, text: String, subtext: String, subtextColor: UIColor) -> UIView {
        let row = UIStackView(); row.axis = .horizontal; row.spacing = 10; row.alignment = .top
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let ico = UIImageView(image: UIImage(systemName: icon, withConfiguration: cfg))
        ico.tintColor = iconColor; ico.contentMode = .scaleAspectFit
        ico.widthAnchor.constraint(equalToConstant: 18).isActive = true
        ico.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let ts = UIStackView(); ts.axis = .vertical; ts.spacing = 2
        let ml = UILabel(); ml.setEmojiSafeText(text, font: AppTheme.Typeface.body(12), color: AppTheme.Pigment.glacierWhite); ml.numberOfLines = 0
        let sl = UILabel(); sl.setEmojiSafeText(subtext, font: AppTheme.Typeface.caption(11), color: subtextColor); sl.numberOfLines = 0
        ts.addArrangedSubview(ml); ts.addArrangedSubview(sl)
        row.addArrangedSubview(ico); row.addArrangedSubview(ts)
        return row
    }

    // MARK: - Helpers
    private func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let l = UILabel(); l.setEmojiSafeText(text, font: font, color: color); return l
    }
    private func makeDivider() -> UIView {
        let v = UIView(); v.backgroundColor = AppTheme.Pigment.crystalBorder
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true; return v
    }
    private func makeSpacing(_ h: CGFloat) -> UIView {
        let v = UIView(); v.heightAnchor.constraint(equalToConstant: h).isActive = true; return v
    }
    private func makeRow(_ views: [UIView]) -> UIStackView {
        let s = UIStackView(arrangedSubviews: views)
        s.axis = .horizontal; s.distribution = .fillEqually; s.spacing = 10; return s
    }
}
