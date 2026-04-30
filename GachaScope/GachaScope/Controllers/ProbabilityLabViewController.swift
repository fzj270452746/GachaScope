import UIKit

final class ProbabilityViewController: UIViewController {
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    // MARK: - Expected Cost Calculator state
    private var calcRate: Double = 0.006
    private var calcCostPerPull: Double = 0
    private let calcRateSlider  = UISlider()
    private let calcRateLabel   = UILabel()
    private let costTextField   = UITextField()
    private let calcResultsCard = GlowCard()
    private let cdfChart        = CDFChartView()
    private let expPullsLbl     = UILabel()
    private let p50Lbl          = UILabel()
    private let p90Lbl          = UILabel()
    private let p99Lbl          = UILabel()
    private let expCostLbl      = UILabel()
    private let costRowView     = UIStackView()
    private let calcBtn         = PulseButton()

    // MARK: - A/B Comparator state
    private var configARate:     Double = 0.006
    private var configAHardPity: Int    = 90
    private var configASoftPity: Int    = 74
    private var configAPityOn:   Bool   = true
    private var configBRate:     Double = 0.020
    private var configBHardPity: Int    = 50
    private var configBSoftPity: Int    = 40
    private var configBPityOn:   Bool   = true
    private let configARateLbl    = UILabel()
    private let configARateSlider = UISlider()
    private let configAHardPityLbl     = UILabel()
    private let configAHardPityStepper = UIStepper()
    private let configAPitySwitch      = UISwitch()
    private let configBRateLbl    = UILabel()
    private let configBRateSlider = UISlider()
    private let configBHardPityLbl     = UILabel()
    private let configBHardPityStepper = UIStepper()
    private let configBPitySwitch      = UISwitch()
    private let compareResultsCard = GlowCard()
    private let compareChart       = DistributionChartView()
    private let compareTableStack  = UIStackView()
    private let compareBtn         = PulseButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupScrollView()
        setupHeader()
        setupCostCalculator()
        setupComparator()
        setupMathReference()
        setupKeyboardDismissal()
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
        lbl.setEmojiSafeText("⚗️ Probability Lab", font: AppTheme.Typeface.display(26), color: AppTheme.Pigment.auroraGreen)
        contentStack.addArrangedSubview(lbl)

        let sub = UILabel()
        sub.text = "Interactive probability tools grounded in geometric distribution theory."
        sub.font = AppTheme.Typeface.body(13)
        sub.textColor = AppTheme.Pigment.mistGray
        sub.numberOfLines = 0
        contentStack.addArrangedSubview(sub)
    }

    // MARK: - Expected Cost Calculator
    private func setupCostCalculator() {
        contentStack.addArrangedSubview(makeSectionHeader("Expected Cost Calculator",
            subtitle: "E[X] = 1/p  ·  How many trials until the first success?"))

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

        // Rate slider row
        calcRateLabel.font = AppTheme.Typeface.mono(13)
        calcRateLabel.textColor = AppTheme.Pigment.nebulaViolet
        calcRateSlider.minimumValue = 0.001
        calcRateSlider.maximumValue = 0.20
        calcRateSlider.value = Float(calcRate)
        calcRateSlider.minimumTrackTintColor = AppTheme.Pigment.nebulaViolet
        calcRateSlider.maximumTrackTintColor = AppTheme.Pigment.crystalBorder
        calcRateSlider.addTarget(self, action: #selector(calcRateChanged), for: .valueChanged)
        updateCalcRateLabel()
        inner.addArrangedSubview(makeSliderRow(label: "Drop Rate (p)", valueLabel: calcRateLabel, slider: calcRateSlider))

        // Optional cost field
        let costRow = UIStackView()
        costRow.axis = .vertical
        costRow.spacing = 6
        let costHdr = UIStackView()
        costHdr.axis = .horizontal
        costHdr.distribution = .equalSpacing
        let costTitleLbl = makeLabel("Cost Per Trial (optional)", font: AppTheme.Typeface.body(13), color: AppTheme.Pigment.mistGray)
        let costUnitLbl  = makeLabel("units / gems / currency", font: AppTheme.Typeface.caption(11), color: AppTheme.Pigment.mistGray)
        costHdr.addArrangedSubview(costTitleLbl)
        costHdr.addArrangedSubview(costUnitLbl)
        costRow.addArrangedSubview(costHdr)
        costTextField.placeholder = "e.g. 160   or   0.99"
        costTextField.font = AppTheme.Typeface.mono(14)
        costTextField.textColor = AppTheme.Pigment.glacierWhite
        costTextField.keyboardType = .decimalPad
        costTextField.keyboardAppearance = .dark
        costTextField.backgroundColor = AppTheme.Pigment.crystalBorder.withAlphaComponent(0.3)
        costTextField.layer.cornerRadius = 8
        costTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        costTextField.leftViewMode = .always
        costTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        costRow.addArrangedSubview(costTextField)
        inner.addArrangedSubview(costRow)

        // Calculate button
        calcBtn.setTitle("Calculate", for: .normal)
        calcBtn.titleLabel?.font = AppTheme.Typeface.headline(14)
        calcBtn.gradientColors = [AppTheme.Pigment.nebulaViolet, UIColor(hex: "#3B1A7A")]
        calcBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        calcBtn.addTarget(self, action: #selector(runCostCalculation), for: .touchUpInside)
        inner.addArrangedSubview(calcBtn)

        contentStack.addArrangedSubview(card)

        // Results card (initially hidden)
        setupCalcResultsCard()
    }

    private func setupCalcResultsCard() {
        calcResultsCard.isHidden = true
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 14
        inner.translatesAutoresizingMaskIntoConstraints = false
        calcResultsCard.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: calcResultsCard.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: calcResultsCard.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: calcResultsCard.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: calcResultsCard.trailingAnchor, constant: -16),
        ])

        let resultTitle = makeLabel("Results", font: AppTheme.Typeface.headline(14), color: AppTheme.Pigment.glacierWhite)
        inner.addArrangedSubview(resultTitle)

        // Trials row
        let trialsRow = UIStackView()
        trialsRow.axis = .horizontal
        trialsRow.distribution = .fillEqually
        trialsRow.spacing = 8
        for (lbl, val) in [("E[Trials]", expPullsLbl), ("P50", p50Lbl), ("P90", p90Lbl), ("P99", p99Lbl)] {
            let cell = makeResultCell(header: lbl, valueLabel: val, color: AppTheme.Pigment.nebulaViolet)
            trialsRow.addArrangedSubview(cell)
        }
        inner.addArrangedSubview(trialsRow)

        // Cost row (shown only when cost entered)
        costRowView.axis = .horizontal
        costRowView.distribution = .fillEqually
        costRowView.spacing = 8
        costRowView.isHidden = true
        expCostLbl.font = AppTheme.Typeface.mono(14)
        expCostLbl.textColor = AppTheme.Pigment.ssrGold
        expCostLbl.textAlignment = .center
        let costLabels = [("E[Cost]", expCostLbl)]
        let staticCostLabels: [(String, UILabel)] = [
            ("E[Cost]", expCostLbl)
        ]
        for (title, valueLbl) in staticCostLabels {
            let cell = makeResultCell(header: title, valueLabel: valueLbl, color: AppTheme.Pigment.ssrGold)
            costRowView.addArrangedSubview(cell)
        }
        inner.addArrangedSubview(costRowView)
        let _ = costLabels  // suppress warning

        inner.addArrangedSubview(makeDivider())

        // CDF chart
        let chartHeader = UIStackView()
        chartHeader.axis = .horizontal
        chartHeader.spacing = 4
        let chartTitle = makeLabel("Cumulative Probability Curve", font: AppTheme.Typeface.caption(11), color: AppTheme.Pigment.mistGray)
        chartHeader.addArrangedSubview(chartTitle)
        inner.addArrangedSubview(chartHeader)

        cdfChart.backgroundColor = .clear
        cdfChart.translatesAutoresizingMaskIntoConstraints = false
        cdfChart.heightAnchor.constraint(equalToConstant: 140).isActive = true
        inner.addArrangedSubview(cdfChart)

        let legend = UILabel()
        legend.text = "Dashed markers: P50 (green) · P90 (gold) · P99 (red)"
        legend.font = AppTheme.Typeface.caption(10)
        legend.textColor = AppTheme.Pigment.mistGray
        legend.textAlignment = .center
        inner.addArrangedSubview(legend)

        contentStack.addArrangedSubview(calcResultsCard)
    }

    private func makeResultCell(header: String, valueLabel: UILabel, color: UIColor) -> UIView {
        let v = UIView()
        v.backgroundColor = color.withAlphaComponent(0.08)
        v.layer.cornerRadius = 8
        v.layer.borderWidth = 1
        v.layer.borderColor = color.withAlphaComponent(0.25).cgColor
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        let hdr = UILabel()
        hdr.text = header
        hdr.font = AppTheme.Typeface.caption(10)
        hdr.textColor = AppTheme.Pigment.mistGray
        hdr.textAlignment = .center
        valueLabel.font = AppTheme.Typeface.mono(15)
        valueLabel.textColor = color
        valueLabel.textAlignment = .center
        valueLabel.text = "—"
        stack.addArrangedSubview(hdr)
        stack.addArrangedSubview(valueLabel)
        v.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: v.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: v.bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: v.leadingAnchor, constant: 4),
            stack.trailingAnchor.constraint(equalTo: v.trailingAnchor, constant: -4),
        ])
        return v
    }

    // MARK: - A/B Comparator
    private func setupComparator() {
        contentStack.addArrangedSubview(makeSectionHeader("A/B Configuration Comparator",
            subtitle: "Compare two drop rate designs using exact expected value computation."))

        let outerCard = GlowCard()
        let outer = UIStackView()
        outer.axis = .vertical
        outer.spacing = 14
        outer.translatesAutoresizingMaskIntoConstraints = false
        outerCard.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: outerCard.topAnchor, constant: 16),
            outer.bottomAnchor.constraint(equalTo: outerCard.bottomAnchor, constant: -16),
            outer.leadingAnchor.constraint(equalTo: outerCard.leadingAnchor, constant: 16),
            outer.trailingAnchor.constraint(equalTo: outerCard.trailingAnchor, constant: -16),
        ])

        outer.addArrangedSubview(makeConfigBlock(
            label: "Config A", color: AppTheme.Pigment.nebulaViolet,
            rateLabel: configARateLbl, rateSlider: configARateSlider,
            pitySwitch: configAPitySwitch, hardPityLbl: configAHardPityLbl,
            hardPityStepper: configAHardPityStepper,
            rateSelector: #selector(configARateChanged),
            pitySelector: #selector(configAPityChanged),
            pityStepSelector: #selector(configAHardPityChanged),
            rate: configARate, hardPity: configAHardPity, pityOn: configAPityOn
        ))

        outer.addArrangedSubview(makeDivider())

        outer.addArrangedSubview(makeConfigBlock(
            label: "Config B", color: AppTheme.Pigment.stellarPink,
            rateLabel: configBRateLbl, rateSlider: configBRateSlider,
            pitySwitch: configBPitySwitch, hardPityLbl: configBHardPityLbl,
            hardPityStepper: configBHardPityStepper,
            rateSelector: #selector(configBRateChanged),
            pitySelector: #selector(configBPityChanged),
            pityStepSelector: #selector(configBHardPityChanged),
            rate: configBRate, hardPity: configBHardPity, pityOn: configBPityOn
        ))

        compareBtn.setTitle("Run Comparison", for: .normal)
        compareBtn.titleLabel?.font = AppTheme.Typeface.headline(14)
        compareBtn.gradientColors = [AppTheme.Pigment.nebulaViolet, AppTheme.Pigment.stellarPink]
        compareBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        compareBtn.addTarget(self, action: #selector(runComparison), for: .touchUpInside)
        outer.addArrangedSubview(compareBtn)

        contentStack.addArrangedSubview(outerCard)
        setupCompareResultsCard()
    }

    private func makeConfigBlock(label: String, color: UIColor,
                                  rateLabel: UILabel, rateSlider: UISlider,
                                  pitySwitch: UISwitch, hardPityLbl: UILabel,
                                  hardPityStepper: UIStepper,
                                  rateSelector: Selector, pitySelector: Selector, pityStepSelector: Selector,
                                  rate: Double, hardPity: Int, pityOn: Bool) -> UIView {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 10

        let headerLbl = makeLabel(label, font: AppTheme.Typeface.headline(13), color: color)
        s.addArrangedSubview(headerLbl)

        // Rate
        rateLabel.font = AppTheme.Typeface.mono(12)
        rateLabel.textColor = color
        rateSlider.minimumValue = 0.001
        rateSlider.maximumValue = 0.20
        rateSlider.value = Float(rate)
        rateSlider.minimumTrackTintColor = color
        rateSlider.maximumTrackTintColor = AppTheme.Pigment.crystalBorder
        rateSlider.addTarget(self, action: rateSelector, for: .valueChanged)
        updateRateLabel(rateLabel, rate: rate)
        s.addArrangedSubview(makeSliderRow(label: "Drop Rate", valueLabel: rateLabel, slider: rateSlider))

        // Pity row
        let pityRow = UIStackView()
        pityRow.axis = .horizontal
        pityRow.spacing = 10
        pityRow.alignment = .center
        let pityLbl = makeLabel("Guarantee Threshold", font: AppTheme.Typeface.body(12), color: AppTheme.Pigment.mistGray)
        pitySwitch.isOn = pityOn
        pitySwitch.onTintColor = color
        pitySwitch.addTarget(self, action: pitySelector, for: .valueChanged)
        pityRow.addArrangedSubview(pityLbl)
        pityRow.addArrangedSubview(UIView())  // spacer
        pityRow.addArrangedSubview(pitySwitch)
        s.addArrangedSubview(pityRow)

        // Hard pity stepper
        hardPityLbl.font = AppTheme.Typeface.mono(12)
        hardPityLbl.textColor = color
        hardPityLbl.text = "at \(hardPity) trials"
        hardPityStepper.minimumValue = 10
        hardPityStepper.maximumValue = 200
        hardPityStepper.stepValue = 5
        hardPityStepper.value = Double(hardPity)
        hardPityStepper.tintColor = color
        hardPityStepper.addTarget(self, action: pityStepSelector, for: .valueChanged)
        hardPityStepper.isEnabled = pityOn

        let stepRow = UIStackView(arrangedSubviews: [
            makeLabel("Max Trials", font: AppTheme.Typeface.body(12), color: AppTheme.Pigment.mistGray),
            UIView(),
            hardPityLbl, hardPityStepper
        ])
        stepRow.axis = .horizontal
        stepRow.spacing = 8
        stepRow.alignment = .center
        s.addArrangedSubview(stepRow)
        return s
    }

    private func setupCompareResultsCard() {
        compareResultsCard.isHidden = true
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 12
        inner.translatesAutoresizingMaskIntoConstraints = false
        compareResultsCard.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: compareResultsCard.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: compareResultsCard.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: compareResultsCard.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: compareResultsCard.trailingAnchor, constant: -16),
        ])

        let title = makeLabel("Comparison Results", font: AppTheme.Typeface.headline(14), color: AppTheme.Pigment.glacierWhite)
        inner.addArrangedSubview(title)

        // Color legend
        let legendRow = UIStackView()
        legendRow.axis = .horizontal
        legendRow.spacing = 16
        let legA = makeColorLegend("Config A", color: AppTheme.Pigment.nebulaViolet)
        let legB = makeColorLegend("Config B", color: AppTheme.Pigment.stellarPink)
        legendRow.addArrangedSubview(legA)
        legendRow.addArrangedSubview(legB)
        legendRow.addArrangedSubview(UIView())
        inner.addArrangedSubview(legendRow)

        inner.addArrangedSubview(makeDivider())

        // Table
        compareTableStack.axis = .vertical
        compareTableStack.spacing = 0
        inner.addArrangedSubview(compareTableStack)

        inner.addArrangedSubview(makeDivider())

        // Chart
        let chartLbl = makeLabel("E[X] vs P90 Trials — Shorter is faster for the player",
                                  font: AppTheme.Typeface.caption(10), color: AppTheme.Pigment.mistGray)
        chartLbl.numberOfLines = 0
        inner.addArrangedSubview(chartLbl)
        compareChart.backgroundColor = .clear
        compareChart.translatesAutoresizingMaskIntoConstraints = false
        compareChart.heightAnchor.constraint(equalToConstant: 120).isActive = true
        inner.addArrangedSubview(compareChart)

        contentStack.addArrangedSubview(compareResultsCard)
    }

    // MARK: - Math Reference
    private func setupMathReference() {
        contentStack.addArrangedSubview(makeSectionHeader("Probability Reference",
            subtitle: "Core formulae used in all simulations."))

        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 16
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])

        let formulas: [(String, String, String)] = [
            ("Geometric Distribution PMF",
             "P(X = k) = (1−p)^(k−1) · p",
             "Probability of first success on exactly the k-th trial, where p is the success rate."),
            ("Expected Value",
             "E[X] = 1 / p",
             "Average number of trials needed for one success. For p=0.6%, E[X]=166.7 trials."),
            ("Cumulative Distribution (CDF)",
             "P(X ≤ k) = 1 − (1−p)^k",
             "Probability of success within k trials. Use to find P50, P90, P99 milestones."),
            ("kth Percentile (no pity)",
             "k = ⌈ln(1 − %ile) / ln(1−p)⌉",
             "Inverse CDF. Tells you at which trial you hit a given cumulative probability."),
        ]

        for (title, formula, explanation) in formulas {
            let block = UIStackView()
            block.axis = .vertical
            block.spacing = 6
            let t = makeLabel(title, font: AppTheme.Typeface.caption(11), color: AppTheme.Pigment.mistGray)
            let f = makeLabel(formula, font: AppTheme.Typeface.mono(14), color: AppTheme.Pigment.auroraGreen)
            f.numberOfLines = 0
            let e = makeLabel(explanation, font: AppTheme.Typeface.caption(12), color: AppTheme.Pigment.mistGray)
            e.numberOfLines = 0
            block.addArrangedSubview(t)
            block.addArrangedSubview(f)
            block.addArrangedSubview(e)
            inner.addArrangedSubview(block)
            inner.addArrangedSubview(makeDivider())
        }

        // Gambler's Fallacy warning (prominent)
        let warningCard = UIView()
        warningCard.backgroundColor = AppTheme.Pigment.novaRed.withAlphaComponent(0.1)
        warningCard.layer.cornerRadius = 10
        warningCard.layer.borderWidth = 1
        warningCard.layer.borderColor = AppTheme.Pigment.novaRed.withAlphaComponent(0.4).cgColor
        let warnStack = UIStackView()
        warnStack.axis = .vertical
        warnStack.spacing = 8
        warnStack.translatesAutoresizingMaskIntoConstraints = false
        warningCard.addSubview(warnStack)
        NSLayoutConstraint.activate([
            warnStack.topAnchor.constraint(equalTo: warningCard.topAnchor, constant: 14),
            warnStack.bottomAnchor.constraint(equalTo: warningCard.bottomAnchor, constant: -14),
            warnStack.leadingAnchor.constraint(equalTo: warningCard.leadingAnchor, constant: 14),
            warnStack.trailingAnchor.constraint(equalTo: warningCard.trailingAnchor, constant: -14),
        ])
        let warnTitle = UIStackView()
        warnTitle.axis = .horizontal
        warnTitle.spacing = 8
        warnTitle.alignment = .center
        let warnCfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .bold)
        let warnIco = UIImageView(image: UIImage(systemName: "exclamationmark.triangle.fill", withConfiguration: warnCfg))
        warnIco.tintColor = AppTheme.Pigment.novaRed
        warnIco.contentMode = .scaleAspectFit
        warnIco.widthAnchor.constraint(equalToConstant: 20).isActive = true
        let warnLbl = makeLabel("Gambler's Fallacy", font: AppTheme.Typeface.headline(14), color: AppTheme.Pigment.novaRed)
        warnTitle.addArrangedSubview(warnIco)
        warnTitle.addArrangedSubview(warnLbl)
        warnStack.addArrangedSubview(warnTitle)
        let warnBody = makeLabel(
            "Each trial is a statistically independent event. A prior losing streak does NOT increase the probability of the next trial succeeding (except where a pity/guarantee threshold is mathematically defined). Believing otherwise is the Gambler's Fallacy.",
            font: AppTheme.Typeface.body(13), color: AppTheme.Pigment.mistGray)
        warnBody.numberOfLines = 0
        warnStack.addArrangedSubview(warnBody)
        inner.addArrangedSubview(warningCard)

        contentStack.addArrangedSubview(card)
    }

    // MARK: - Calc actions
    @objc private func calcRateChanged() {
        calcRate = Double(calcRateSlider.value)
        updateCalcRateLabel()
        Haptics.shared.selectItem()
    }

    @objc private func runCostCalculation() {
        view.endEditing(true)
        calcCostPerPull = Double(costTextField.text ?? "") ?? 0
        let p = calcRate

        let expectedPulls = 1.0 / p
        let p50 = Self.percentileGeom(target: 0.50, p: p)
        let p90 = Self.percentileGeom(target: 0.90, p: p)
        let p99 = Self.percentileGeom(target: 0.99, p: p)

        expPullsLbl.text = String(format: "%.0f", expectedPulls)
        p50Lbl.text = "\(p50)"
        p90Lbl.text = "\(p90)"
        p99Lbl.text = "\(p99)"

        if calcCostPerPull > 0 {
            expCostLbl.text = String(format: "%.0f", expectedPulls * calcCostPerPull)
            costRowView.isHidden = false
        } else {
            costRowView.isHidden = true
        }

        // Build CDF data
        let maxK = p99 + max(10, p99 / 5)
        var cdfData: [Double] = []
        let step = max(1, maxK / 120)
        for k in stride(from: 1, through: maxK, by: step) {
            let prob = 1 - pow(1 - p, Double(k))
            cdfData.append(min(1.0, prob))
        }
        cdfChart.setData(cdfData)

        Haptics.shared.successPulse()
        calcBtn.animatePulse()
        calcResultsCard.isHidden = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let offset = CGPoint(x: 0, y: self.calcResultsCard.frame.minY - 16)
            self.scrollView.setContentOffset(offset, animated: true)
        }
    }

    // MARK: - Comparator actions
    @objc private func configARateChanged() {
        configARate = Double(configARateSlider.value)
        updateRateLabel(configARateLbl, rate: configARate)
        Haptics.shared.selectItem()
    }
    @objc private func configAPityChanged() {
        configAPityOn = configAPitySwitch.isOn
        configAHardPityStepper.isEnabled = configAPityOn
    }
    @objc private func configAHardPityChanged() {
        configAHardPity = Int(configAHardPityStepper.value)
        configASoftPity = max(1, configAHardPity - 16)
        configAHardPityLbl.text = "at \(configAHardPity) trials"
    }
    @objc private func configBRateChanged() {
        configBRate = Double(configBRateSlider.value)
        updateRateLabel(configBRateLbl, rate: configBRate)
        Haptics.shared.selectItem()
    }
    @objc private func configBPityChanged() {
        configBPityOn = configBPitySwitch.isOn
        configBHardPityStepper.isEnabled = configBPityOn
    }
    @objc private func configBHardPityChanged() {
        configBHardPity = Int(configBHardPityStepper.value)
        configBSoftPity = max(1, configBHardPity - 16)
        configBHardPityLbl.text = "at \(configBHardPity) trials"
    }

    @objc private func runComparison() {
        view.endEditing(true)
        Haptics.shared.tapHeavy()
        compareBtn.animatePulse()

        let aExp = Self.expectedPullsWithPity(rate: configARate, hardPity: configAHardPity, softPity: configASoftPity, pityEnabled: configAPityOn)
        let aP50 = Self.percentileWithPity(target: 0.50, rate: configARate, hardPity: configAHardPity, softPity: configASoftPity, pityEnabled: configAPityOn)
        let aP90 = Self.percentileWithPity(target: 0.90, rate: configARate, hardPity: configAHardPity, softPity: configASoftPity, pityEnabled: configAPityOn)
        let aP99 = Self.percentileWithPity(target: 0.99, rate: configARate, hardPity: configAHardPity, softPity: configASoftPity, pityEnabled: configAPityOn)

        let bExp = Self.expectedPullsWithPity(rate: configBRate, hardPity: configBHardPity, softPity: configBSoftPity, pityEnabled: configBPityOn)
        let bP50 = Self.percentileWithPity(target: 0.50, rate: configBRate, hardPity: configBHardPity, softPity: configBSoftPity, pityEnabled: configBPityOn)
        let bP90 = Self.percentileWithPity(target: 0.90, rate: configBRate, hardPity: configBHardPity, softPity: configBSoftPity, pityEnabled: configBPityOn)
        let bP99 = Self.percentileWithPity(target: 0.99, rate: configBRate, hardPity: configBHardPity, softPity: configBSoftPity, pityEnabled: configBPityOn)

        // Build table
        compareTableStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        compareTableStack.addArrangedSubview(makeTableHeaderRow())
        let rows: [(String, String, String)] = [
            ("E[Trials]",  String(format: "%.1f", aExp), String(format: "%.1f", bExp)),
            ("P50 Trials", "\(aP50)",                    "\(bP50)"),
            ("P90 Trials", "\(aP90)",                    "\(bP90)"),
            ("P99 Trials", "\(aP99)",                    "\(bP99)"),
            ("Max Guarantee", configAPityOn ? "\(configAHardPity)" : "None", configBPityOn ? "\(configBHardPity)" : "None"),
        ]
        let better = aExp < bExp  // Config A is better for player if fewer expected trials
        for (i, (metric, aVal, bVal)) in rows.enumerated() {
            compareTableStack.addArrangedSubview(makeTableRow(metric: metric, aVal: aVal, bVal: bVal, rowIndex: i))
        }
        let _ = better

        // Chart
        let maxE = max(aExp, bExp)
        compareChart.setEntries([
            .init(label: "A E[X]", value: aExp / maxE, color: AppTheme.Pigment.nebulaViolet),
            .init(label: "B E[X]", value: bExp / maxE, color: AppTheme.Pigment.stellarPink),
            .init(label: "A P90",  value: Double(aP90) / Double(max(aP90, bP90)), color: AppTheme.Pigment.nebulaViolet.withAlphaComponent(0.4)),
            .init(label: "B P90",  value: Double(bP90) / Double(max(aP90, bP90)), color: AppTheme.Pigment.stellarPink.withAlphaComponent(0.4)),
        ])

        compareResultsCard.isHidden = false
        Haptics.shared.successPulse()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            guard let self = self else { return }
            let offset = CGPoint(x: 0, y: self.compareResultsCard.frame.minY - 16)
            self.scrollView.setContentOffset(offset, animated: true)
        }
    }

    private func makeTableHeaderRow() -> UIView {
        let row = makeTableRow(metric: "Metric", aVal: "Config A", bVal: "Config B", rowIndex: -1)
        row.backgroundColor = AppTheme.Pigment.crystalBorder.withAlphaComponent(0.3)
        return row
    }

    private func makeTableRow(metric: String, aVal: String, bVal: String, rowIndex: Int) -> UIView {
        let row = UIView()
        if rowIndex >= 0 {
            row.backgroundColor = rowIndex % 2 == 0
                ? UIColor.clear
                : AppTheme.Pigment.crystalBorder.withAlphaComponent(0.1)
        }
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: row.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: row.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -8),
        ])
        let mLbl = makeLabel(metric, font: AppTheme.Typeface.body(12), color: AppTheme.Pigment.mistGray)
        mLbl.setContentHuggingPriority(.defaultLow, for: .horizontal)
        let aLbl = makeLabel(aVal,   font: AppTheme.Typeface.mono(12), color: rowIndex == -1 ? AppTheme.Pigment.mistGray : AppTheme.Pigment.nebulaViolet)
        aLbl.textAlignment = .center
        aLbl.widthAnchor.constraint(equalToConstant: 72).isActive = true
        let bLbl = makeLabel(bVal,   font: AppTheme.Typeface.mono(12), color: rowIndex == -1 ? AppTheme.Pigment.mistGray : AppTheme.Pigment.stellarPink)
        bLbl.textAlignment = .center
        bLbl.widthAnchor.constraint(equalToConstant: 72).isActive = true
        stack.addArrangedSubview(mLbl)
        stack.addArrangedSubview(aLbl)
        stack.addArrangedSubview(bLbl)
        return row
    }

    // MARK: - Keyboard
    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    @objc private func dismissKeyboard() { view.endEditing(true) }

    // MARK: - Helpers
    private func updateCalcRateLabel() { updateRateLabel(calcRateLabel, rate: calcRate) }
    private func updateRateLabel(_ lbl: UILabel, rate: Double) {
        lbl.text = String(format: "%.2f%%", rate * 100)
    }
    private func makeSectionHeader(_ title: String, subtitle: String) -> UIView {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 4
        let t = makeLabel(title, font: AppTheme.Typeface.headline(16), color: AppTheme.Pigment.glacierWhite)
        let sub = makeLabel(subtitle, font: AppTheme.Typeface.caption(12), color: AppTheme.Pigment.mistGray)
        sub.numberOfLines = 0
        s.addArrangedSubview(t)
        s.addArrangedSubview(sub)
        return s
    }
    private func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let l = UILabel(); l.setEmojiSafeText(text, font: font, color: color); return l
    }
    private func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = AppTheme.Pigment.crystalBorder
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return v
    }
    private func makeSliderRow(label: String, valueLabel: UILabel, slider: UISlider) -> UIView {
        let s = UIStackView()
        s.axis = .vertical
        s.spacing = 6
        let top = UIStackView()
        top.axis = .horizontal
        top.distribution = .equalSpacing
        top.addArrangedSubview(makeLabel(label, font: AppTheme.Typeface.body(13), color: AppTheme.Pigment.mistGray))
        top.addArrangedSubview(valueLabel)
        s.addArrangedSubview(top)
        s.addArrangedSubview(slider)
        return s
    }
    private func makeColorLegend(_ text: String, color: UIColor) -> UIView {
        let s = UIStackView()
        s.axis = .horizontal
        s.spacing = 6
        s.alignment = .center
        let dot = UIView()
        dot.backgroundColor = color
        dot.layer.cornerRadius = 5
        dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 10).isActive = true
        s.addArrangedSubview(dot)
        s.addArrangedSubview(makeLabel(text, font: AppTheme.Typeface.caption(11), color: AppTheme.Pigment.mistGray))
        return s
    }

    // MARK: - Probability Math
    static func percentileGeom(target: Double, p: Double) -> Int {
        let k = log(1 - target) / log(1 - p)
        return max(1, Int(ceil(k)))
    }

    static func expectedPullsWithPity(rate p: Double, hardPity: Int, softPity: Int, pityEnabled: Bool) -> Double {
        if !pityEnabled { return 1.0 / p }
        var expected = 0.0
        var remaining = 1.0
        for k in 1...hardPity {
            var ep = p
            if k >= softPity {
                ep = min(1.0, p + Double(k - softPity) * 0.06)
            }
            let prob = k == hardPity ? remaining : remaining * ep
            expected += Double(k) * prob
            remaining -= prob
            if remaining <= 0 { break }
        }
        return expected
    }

    static func percentileWithPity(target: Double, rate p: Double, hardPity: Int, softPity: Int, pityEnabled: Bool) -> Int {
        if !pityEnabled { return percentileGeom(target: target, p: p) }
        var cumProb = 0.0
        var remaining = 1.0
        for k in 1...hardPity {
            var ep = p
            if k >= softPity {
                ep = min(1.0, p + Double(k - softPity) * 0.06)
            }
            let prob = k == hardPity ? remaining : remaining * ep
            cumProb += prob
            remaining -= prob
            if cumProb >= target { return k }
        }
        return hardPity
    }
}
