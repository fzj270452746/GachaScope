import UIKit

final class ProbabilityViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let distributionSegment = UISegmentedControl(items: DistributionMode.allCases.map { $0.title })
    private let distributionChart = DistributionChartView()
    private let distributionSummary = UILabel()
    private let rateSlider = UISlider()
    private let rateLabel = UILabel()
    private let trialSlider = UISlider()
    private let trialLabel = UILabel()
    private let lambdaSlider = UISlider()
    private let lambdaLabel = UILabel()

    private let pityCurveChart = CDFChartView()
    private let pityCompareChart = DistributionChartView()
    private let curveSummary = UILabel()
    private let pityRateSlider = UISlider()
    private let pityRateLabel = UILabel()
    private let softPityStepper = UIStepper()
    private let softPityLabel = UILabel()
    private let hardPityStepper = UIStepper()
    private let hardPityLabel = UILabel()
    private let pityIncrementSlider = UISlider()
    private let pityIncrementLabel = UILabel()

    private let tenPullSummary = UILabel()

    private let saveCurrentPlanButton = UIButton(type: .system)
    private let planAButton = UIButton(type: .system)
    private let planBButton = UIButton(type: .system)
    private let compareBudgetField = UITextField()
    private let comparisonStack = UIStackView()
    private let reportLabel = UILabel()

    private var selectedMode: DistributionMode = .geometric
    private var selectedPlanA: GachaPlan?
    private var selectedPlanB: GachaPlan?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupScrollView()
        setupHeader()
        setupDistributionWorkbench()
        setupPityResearchWorkbench()
        setupSingleVsTenSection()
        setupPlanVault()
        setupKeyboardDismissal()
        refreshAll()
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
        let title = UILabel()
        title.setEmojiSafeText("⚗️ Probability Lab", font: AppTheme.Typeface.display(26), color: AppTheme.Pigment.auroraGreen)
        contentStack.addArrangedSubview(title)

        let subtitle = UILabel()
        subtitle.text = "A compact research workbench for distribution modeling, pity tuning, plan comparison, and player decision support."
        subtitle.font = AppTheme.Typeface.body(13)
        subtitle.textColor = AppTheme.Pigment.mistGray
        subtitle.numberOfLines = 0
        contentStack.addArrangedSubview(subtitle)
    }

    private func setupDistributionWorkbench() {
        contentStack.addArrangedSubview(makeSectionHeader("Distribution Workbench", subtitle: "Explore geometric, binomial, and Poisson behavior with one parameter set."))
        let card = makeCardContainer()
        let inner = card.1

        distributionSegment.selectedSegmentIndex = selectedMode.rawValue
        distributionSegment.selectedSegmentTintColor = AppTheme.Pigment.auroraGreen
        distributionSegment.setTitleTextAttributes([.foregroundColor: AppTheme.Pigment.glacierWhite], for: .normal)
        distributionSegment.addTarget(self, action: #selector(distributionModeChanged), for: .valueChanged)
        inner.addArrangedSubview(distributionSegment)

        configureRateSlider(rateSlider, min: 0.005, max: 0.25, value: 0.06, color: AppTheme.Pigment.auroraGreen)
        rateSlider.addTarget(self, action: #selector(refreshAll), for: .valueChanged)
        trialSlider.minimumValue = 1
        trialSlider.maximumValue = 50
        trialSlider.value = 10
        trialSlider.minimumTrackTintColor = AppTheme.Pigment.prismaticBlue
        trialSlider.maximumTrackTintColor = AppTheme.Pigment.crystalBorder
        trialSlider.addTarget(self, action: #selector(refreshAll), for: .valueChanged)
        lambdaSlider.minimumValue = 0.5
        lambdaSlider.maximumValue = 12
        lambdaSlider.value = 4
        lambdaSlider.minimumTrackTintColor = AppTheme.Pigment.stellarPink
        lambdaSlider.maximumTrackTintColor = AppTheme.Pigment.crystalBorder
        lambdaSlider.addTarget(self, action: #selector(refreshAll), for: .valueChanged)

        inner.addArrangedSubview(makeSliderRow(label: "Event Rate (p)", valueLabel: rateLabel, slider: rateSlider))
        inner.addArrangedSubview(makeSliderRow(label: "Trials / Sample Window", valueLabel: trialLabel, slider: trialSlider))
        inner.addArrangedSubview(makeSliderRow(label: "Poisson λ", valueLabel: lambdaLabel, slider: lambdaSlider))

        distributionChart.translatesAutoresizingMaskIntoConstraints = false
        distributionChart.heightAnchor.constraint(equalToConstant: 180).isActive = true
        inner.addArrangedSubview(distributionChart)

        distributionSummary.font = AppTheme.Typeface.caption(12)
        distributionSummary.textColor = AppTheme.Pigment.mistGray
        distributionSummary.numberOfLines = 0
        inner.addArrangedSubview(distributionSummary)

        contentStack.addArrangedSubview(card.0)
    }

    private func setupPityResearchWorkbench() {
        contentStack.addArrangedSubview(makeSectionHeader("Pity Model Research", subtitle: "Tune pity curves, compare baseline vs pity, and inspect right-tail compression."))
        let card = makeCardContainer()
        let inner = card.1

        configureRateSlider(pityRateSlider, min: 0.002, max: 0.08, value: Float(AppStorage.shared.ssrRate), color: AppTheme.Pigment.ssrGold)
        pityRateSlider.addTarget(self, action: #selector(refreshAll), for: .valueChanged)
        pityIncrementSlider.minimumValue = 0.005
        pityIncrementSlider.maximumValue = 0.12
        pityIncrementSlider.value = 0.06
        pityIncrementSlider.minimumTrackTintColor = AppTheme.Pigment.nebulaViolet
        pityIncrementSlider.maximumTrackTintColor = AppTheme.Pigment.crystalBorder
        pityIncrementSlider.addTarget(self, action: #selector(refreshAll), for: .valueChanged)

        softPityStepper.minimumValue = 10
        softPityStepper.maximumValue = 150
        softPityStepper.stepValue = 1
        softPityStepper.value = Double(AppStorage.shared.softPity)
        softPityStepper.addTarget(self, action: #selector(refreshAll), for: .valueChanged)

        hardPityStepper.minimumValue = 20
        hardPityStepper.maximumValue = 200
        hardPityStepper.stepValue = 1
        hardPityStepper.value = Double(AppStorage.shared.hardPity)
        hardPityStepper.addTarget(self, action: #selector(refreshAll), for: .valueChanged)

        inner.addArrangedSubview(makeSliderRow(label: "Base SSR Rate", valueLabel: pityRateLabel, slider: pityRateSlider))
        inner.addArrangedSubview(makeStepperRow(label: "Soft Pity Start", valueLabel: softPityLabel, stepper: softPityStepper))
        inner.addArrangedSubview(makeStepperRow(label: "Hard Pity", valueLabel: hardPityLabel, stepper: hardPityStepper))
        inner.addArrangedSubview(makeSliderRow(label: "Soft Pity Increment", valueLabel: pityIncrementLabel, slider: pityIncrementSlider))

        pityCurveChart.translatesAutoresizingMaskIntoConstraints = false
        pityCurveChart.heightAnchor.constraint(equalToConstant: 180).isActive = true
        inner.addArrangedSubview(pityCurveChart)

        pityCompareChart.translatesAutoresizingMaskIntoConstraints = false
        pityCompareChart.heightAnchor.constraint(equalToConstant: 170).isActive = true
        inner.addArrangedSubview(pityCompareChart)

        curveSummary.font = AppTheme.Typeface.caption(12)
        curveSummary.textColor = AppTheme.Pigment.mistGray
        curveSummary.numberOfLines = 0
        inner.addArrangedSubview(curveSummary)

        contentStack.addArrangedSubview(card.0)
    }

    private func setupSingleVsTenSection() {
        contentStack.addArrangedSubview(makeSectionHeader("Single vs Ten-Pull", subtitle: "Show players the same math in a more decision-oriented format."))
        let card = makeCardContainer()
        let inner = card.1

        tenPullSummary.font = AppTheme.Typeface.body(12)
        tenPullSummary.textColor = AppTheme.Pigment.glacierWhite
        tenPullSummary.numberOfLines = 0
        inner.addArrangedSubview(tenPullSummary)

        contentStack.addArrangedSubview(card.0)
    }

    private func setupPlanVault() {
        contentStack.addArrangedSubview(makeSectionHeader("Plan Vault & Reports", subtitle: "Save multiple pools, compare budget efficiency, and export a research summary."))
        let card = makeCardContainer()
        let inner = card.1

        _ = configureSecondaryButton(saveCurrentPlanButton, title: "Save Current Defaults", action: #selector(saveCurrentDefaultsPlan))
        _ = configureSecondaryButton(planAButton, title: "Select Plan A", action: #selector(selectPlanA))
        _ = configureSecondaryButton(planBButton, title: "Select Plan B", action: #selector(selectPlanB))
        let compareButton = configureSecondaryButton(UIButton(type: .system), title: "Compare Plans", action: #selector(comparePlans))
        let shareButton = configureSecondaryButton(UIButton(type: .system), title: "Share Text Report", action: #selector(shareReport))

        configureNumberField(compareBudgetField, placeholder: "Budget for comparison")
        compareBudgetField.text = "100"

        inner.addArrangedSubview(saveCurrentPlanButton)
        inner.addArrangedSubview(planAButton)
        inner.addArrangedSubview(planBButton)
        inner.addArrangedSubview(compareBudgetField)
        inner.addArrangedSubview(compareButton)

        comparisonStack.axis = .vertical
        comparisonStack.spacing = 8
        inner.addArrangedSubview(comparisonStack)

        reportLabel.font = AppTheme.Typeface.caption(12)
        reportLabel.textColor = AppTheme.Pigment.mistGray
        reportLabel.numberOfLines = 0
        inner.addArrangedSubview(reportLabel)
        inner.addArrangedSubview(shareButton)

        contentStack.addArrangedSubview(card.0)
    }

    @objc private func distributionModeChanged() {
        selectedMode = DistributionMode(rawValue: distributionSegment.selectedSegmentIndex) ?? .geometric
        refreshDistributionSection()
    }

    @objc private func refreshAll() {
        refreshDistributionSection()
        refreshPitySection()
        refreshSingleVsTenSection()
    }

    private func refreshDistributionSection() {
        let rate = Double(rateSlider.value)
        let trials = max(1, Int(trialSlider.value.rounded()))
        let lambda = Double(lambdaSlider.value)

        rateLabel.text = ProbabilityResearchKit.formatPercent(rate)
        trialLabel.text = "\(trials)"
        lambdaLabel.text = String(format: "%.1f", lambda)

        switch selectedMode {
        case .geometric:
            let pmf = ProbabilityResearchKit.geometricPMF(rate: rate, maxTrials: min(trials, 12))
            distributionChart.setEntries(pmf.enumerated().map { .init(label: "\($0.offset + 1)", value: $0.element, color: AppTheme.Pigment.auroraGreen) })
            let p50 = ProbabilityResearchKit.drawsNeeded(rate: rate, targetProbability: 0.5)
            distributionSummary.text = "Geometric first-success model. E[X] = \(String(format: "%.2f", 1 / rate)); P50 hit arrives around draw \(p50)."
        case .binomial:
            let dist = ProbabilityResearchKit.binomialDistribution(trials: trials, rate: rate)
            let sampled = Array(dist.enumerated().prefix(10))
            distributionChart.setEntries(sampled.map { .init(label: "\($0.offset)", value: $0.element, color: AppTheme.Pigment.prismaticBlue) })
            distributionSummary.text = "Binomial model over \(trials) trials. Mean successes = np = \(String(format: "%.2f", Double(trials) * rate)). Useful for multi-copy targets and pack openings."
        case .poisson:
            let dist = ProbabilityResearchKit.poissonApproximation(lambda: lambda, maxK: 9)
            distributionChart.setEntries(dist.enumerated().map { .init(label: "\($0.offset)", value: $0.element, color: AppTheme.Pigment.stellarPink) })
            distributionSummary.text = "Poisson approximation with λ = \(String(format: "%.1f", lambda)). Helpful for rare-event approximations when trial count is large and p is small."
        }
    }

    private func refreshPitySection() {
        let baseRate = Double(pityRateSlider.value)
        let softPity = Int(softPityStepper.value)
        let hardPity = max(Int(hardPityStepper.value), softPity + 1)
        if Int(hardPityStepper.value) != hardPity { hardPityStepper.value = Double(hardPity) }
        let increment = Double(pityIncrementSlider.value)

        pityRateLabel.text = ProbabilityResearchKit.formatPercent(baseRate)
        softPityLabel.text = "\(softPity)"
        hardPityLabel.text = "\(hardPity)"
        pityIncrementLabel.text = ProbabilityResearchKit.formatPercent(increment)

        let noPityCDF = ProbabilityResearchKit.firstSuccessCDF(baseRate: baseRate, hardPity: hardPity, softPity: softPity, pityEnabled: false, maxPulls: hardPity)
        let pityCDF = ProbabilityResearchKit.firstSuccessCDF(baseRate: baseRate, hardPity: hardPity, softPity: softPity, pityEnabled: true, increment: increment, maxPulls: hardPity)
        pityCurveChart.setData(pityCDF)

        let noPityStats = ProbabilityResearchKit.quantiles(from: noPityCDF)
        let pityStats = ProbabilityResearchKit.quantiles(from: pityCDF)
        pityCompareChart.setEntries([
            .init(label: "No Pity EV", value: min(noPityStats.expectedPulls / Double(hardPity), 1), color: AppTheme.Pigment.mistGray),
            .init(label: "Pity EV", value: min(pityStats.expectedPulls / Double(hardPity), 1), color: AppTheme.Pigment.nebulaViolet),
            .init(label: "No Pity P90", value: min(Double(noPityStats.p90) / Double(hardPity), 1), color: AppTheme.Pigment.prismaticBlue.withAlphaComponent(0.45)),
            .init(label: "Pity P90", value: min(Double(pityStats.p90) / Double(hardPity), 1), color: AppTheme.Pigment.ssrGold),
        ])

        let preSoftProbability = pityCDF[max(0, min(softPity - 1, pityCDF.count - 1))]
        curveSummary.text = "Custom rate curve editor: before soft pity, success chance follows the base rate; after draw \(softPity), it increases by \(ProbabilityResearchKit.formatPercent(increment)) per pull until hard pity at \(hardPity).\n\nBy draw \(softPity), cumulative hit rate is \(ProbabilityResearchKit.formatPercent(preSoftProbability)). Pity compresses the right tail from P90 \(noPityStats.p90) → \(pityStats.p90), which makes unlucky runs more predictable for players and more controllable for system designers."
    }

    private func refreshSingleVsTenSection() {
        let rate = Double(pityRateSlider.value)
        let single = ProbabilityResearchKit.probabilityOfAtLeastOneHit(rate: rate, draws: 1)
        let ten = ProbabilityResearchKit.probabilityOfAtLeastOneHit(rate: rate, draws: 10)
        let p90 = ProbabilityResearchKit.drawsNeeded(rate: rate, targetProbability: 0.9)
        tenPullSummary.text = "Single draw hit rate: \(ProbabilityResearchKit.formatPercent(single)). Ten-pull hit rate: \(ProbabilityResearchKit.formatPercent(ten)).\n\nThe expected value per draw stays identical in an independent model, but ten-pulls feel better because the session-level success probability is much higher. To reach 90% certainty without pity, players need about \(p90) draws at the current base rate."
    }

    @objc private func saveCurrentDefaultsPlan() {
        let alert = UIAlertController(title: "Save Current Defaults", message: "Store the current Gacha settings as a reusable plan.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Plan name"; $0.text = "Pool \(AppStorage.shared.savedGachaPlans().count + 1)" }
        alert.addTextField { $0.placeholder = "Cost per pull"; $0.keyboardType = .decimalPad }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let cost = Double(alert.textFields?.dropFirst().first?.text ?? "") ?? 0
            let plan = GachaPlan(
                name: name?.isEmpty == false ? name! : "Untitled Plan",
                ssrRate: AppStorage.shared.ssrRate,
                srRate: AppStorage.shared.srRate,
                hardPity: AppStorage.shared.hardPity,
                softPity: AppStorage.shared.softPity,
                pityEnabled: AppStorage.shared.pityEnabled,
                costPerPull: cost
            )
            AppStorage.shared.appendGachaPlan(plan)
            Haptics.shared.successPulse()
        })
        present(alert, animated: true)
    }

    @objc private func selectPlanA() { selectPlan(side: "A") }
    @objc private func selectPlanB() { selectPlan(side: "B") }

    private func selectPlan(side: String) {
        let plans = AppStorage.shared.savedGachaPlans()
        guard !plans.isEmpty else {
            reportLabel.text = "No saved plans yet. Save current defaults first."
            return
        }
        let sheet = UIAlertController(title: "Select Plan \(side)", message: nil, preferredStyle: .actionSheet)
        for plan in plans {
            sheet.addAction(UIAlertAction(title: plan.name, style: .default) { _ in
                if side == "A" {
                    self.selectedPlanA = plan
                    self.planAButton.setTitle("Plan A: \(plan.name)", for: .normal)
                } else {
                    self.selectedPlanB = plan
                    self.planBButton.setTitle("Plan B: \(plan.name)", for: .normal)
                }
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func comparePlans() {
        comparisonStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        guard let planA = selectedPlanA, let planB = selectedPlanB else {
            reportLabel.text = "Choose two plans to compare budget efficiency and target acquisition cost."
            return
        }
        let budget = Double(compareBudgetField.text ?? "") ?? 100
        let result = ProbabilityResearchKit.compare(planA: planA, planB: planB, budget: budget)
        comparisonStack.addArrangedSubview(makeComparisonRow(metric: "Budget hit rate", aValue: ProbabilityResearchKit.formatPercent(result.hitRateA), bValue: ProbabilityResearchKit.formatPercent(result.hitRateB)))
        comparisonStack.addArrangedSubview(makeComparisonRow(metric: "Expected pulls", aValue: String(format: "%.1f", result.expectedPullsA), bValue: String(format: "%.1f", result.expectedPullsB)))
        comparisonStack.addArrangedSubview(makeComparisonRow(metric: "Expected cost", aValue: ProbabilityResearchKit.formatCurrency(result.expectedCostA), bValue: ProbabilityResearchKit.formatCurrency(result.expectedCostB)))
        reportLabel.text = ProbabilityResearchKit.report(for: result)
    }

    @objc private func shareReport() {
        guard let text = reportLabel.text, !text.isEmpty else { return }
        present(UIActivityViewController(activityItems: [text], applicationActivities: nil), animated: true)
    }

    private func makeCardContainer() -> (GlowCard, UIStackView) {
        let card = GlowCard()
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])
        return (card, stack)
    }

    private func makeSectionHeader(_ title: String, subtitle: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        let titleLabel = makeLabel(title, font: AppTheme.Typeface.headline(16), color: AppTheme.Pigment.glacierWhite)
        let subtitleLabel = makeLabel(subtitle, font: AppTheme.Typeface.caption(12), color: AppTheme.Pigment.mistGray)
        subtitleLabel.numberOfLines = 0
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(subtitleLabel)
        return stack
    }

    private func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let label = UILabel()
        label.setEmojiSafeText(text, font: font, color: color)
        return label
    }

    private func makeSliderRow(label: String, valueLabel: UILabel, slider: UISlider) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        let top = UIStackView()
        top.axis = .horizontal
        top.distribution = .equalSpacing
        top.addArrangedSubview(makeLabel(label, font: AppTheme.Typeface.body(13), color: AppTheme.Pigment.mistGray))
        valueLabel.font = AppTheme.Typeface.mono(13)
        valueLabel.textColor = AppTheme.Pigment.glacierWhite
        top.addArrangedSubview(valueLabel)
        stack.addArrangedSubview(top)
        stack.addArrangedSubview(slider)
        return stack
    }

    private func makeStepperRow(label: String, valueLabel: UILabel, stepper: UIStepper) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing
        row.alignment = .center
        row.addArrangedSubview(makeLabel(label, font: AppTheme.Typeface.body(13), color: AppTheme.Pigment.mistGray))
        let right = UIStackView(arrangedSubviews: [valueLabel, stepper])
        right.axis = .horizontal
        right.spacing = 10
        valueLabel.font = AppTheme.Typeface.mono(13)
        valueLabel.textColor = AppTheme.Pigment.glacierWhite
        row.addArrangedSubview(right)
        return row
    }

    private func configureRateSlider(_ slider: UISlider, min: Float, max: Float, value: Float, color: UIColor) {
        slider.minimumValue = min
        slider.maximumValue = max
        slider.value = value
        slider.minimumTrackTintColor = color
        slider.maximumTrackTintColor = AppTheme.Pigment.crystalBorder
    }

    private func configureSecondaryButton(_ button: UIButton, title: String, action: Selector) -> UIButton {
        button.setTitle(title, for: .normal)
        button.setTitleColor(AppTheme.Pigment.glacierWhite, for: .normal)
        button.backgroundColor = AppTheme.Pigment.crystalBorder.withAlphaComponent(0.5)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = AppTheme.Typeface.body(13)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func configureNumberField(_ field: UITextField, placeholder: String) {
        field.placeholder = placeholder
        field.font = AppTheme.Typeface.mono(13)
        field.textColor = AppTheme.Pigment.glacierWhite
        field.backgroundColor = AppTheme.Pigment.crystalBorder.withAlphaComponent(0.35)
        field.layer.cornerRadius = 8
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
        field.leftViewMode = .always
        field.keyboardType = .decimalPad
        field.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }

    private func makeComparisonRow(metric: String, aValue: String, bValue: String) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing
        row.addArrangedSubview(makeLabel(metric, font: AppTheme.Typeface.body(12), color: AppTheme.Pigment.mistGray))
        row.addArrangedSubview(makeLabel(aValue, font: AppTheme.Typeface.mono(12), color: AppTheme.Pigment.nebulaViolet))
        row.addArrangedSubview(makeLabel(bValue, font: AppTheme.Typeface.mono(12), color: AppTheme.Pigment.stellarPink))
        return row
    }

    private func setupKeyboardDismissal() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    static func percentileGeom(target: Double, p: Double) -> Int {
        ProbabilityResearchKit.drawsNeeded(rate: p, targetProbability: target)
    }

    static func expectedPullsWithPity(rate p: Double, hardPity: Int, softPity: Int, pityEnabled: Bool) -> Double {
        let cdf = ProbabilityResearchKit.firstSuccessCDF(baseRate: p, hardPity: hardPity, softPity: softPity, pityEnabled: pityEnabled, maxPulls: hardPity)
        return ProbabilityResearchKit.quantiles(from: cdf).expectedPulls
    }

    static func percentileWithPity(target: Double, rate p: Double, hardPity: Int, softPity: Int, pityEnabled: Bool) -> Int {
        let cdf = ProbabilityResearchKit.firstSuccessCDF(baseRate: p, hardPity: hardPity, softPity: softPity, pityEnabled: pityEnabled, maxPulls: hardPity)
        return (cdf.firstIndex(where: { $0 >= target }) ?? max(cdf.count - 1, 0)) + 1
    }
}
