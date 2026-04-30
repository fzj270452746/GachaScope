import UIKit

final class GachaViewController: UIViewController {
    // MARK: - State
    private var ssrRate: Double = AppStorage.shared.ssrRate
    private var srRate: Double  = AppStorage.shared.srRate
    private var hardPity: Int   = AppStorage.shared.hardPity
    private var softPity: Int   = AppStorage.shared.softPity
    private var pityEnabled: Bool = AppStorage.shared.pityEnabled
    private var simCount: Int   = AppStorage.shared.simulationCount
    private var lastResult: GachaResult?
    var onGachaResult: ((GachaResult) -> Void)?

    // MARK: - UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let headerLabel = UILabel()
    private let ssrSlider = UISlider()
    private let srSlider  = UISlider()
    private let ssrValueLabel = UILabel()
    private let srValueLabel  = UILabel()
    private let pityToggle = UISwitch()
    private let hardPityLabel = UILabel()
    private let softPityLabel = UILabel()
    private let hardPityStepper = UIStepper()
    private let softPityStepper = UIStepper()
    private let simSegment = UISegmentedControl(items: ["1K", "10K", "100K"])
    private let simulateBtn = PulseButton()
    private let statsContainer = UIView()
    private let ssrBadge  = StatBadgeView(title: "SSR Count",  value: "—", accentColor: AppTheme.Pigment.ssrGold)
    private let avgBadge  = StatBadgeView(title: "Avg Pulls",  value: "—", accentColor: AppTheme.Pigment.nebulaViolet)
    private let luckBadge = StatBadgeView(title: "Luck Index", value: "—", accentColor: AppTheme.Pigment.auroraGreen)
    private let droughtBadge = StatBadgeView(title: "Bad Luck", value: "—", accentColor: AppTheme.Pigment.novaRed)
    private let chartCard = GlowCard()
    private let distChart = DistributionChartView()
    private let convCard  = GlowCard()
    private let convChart = ConvergenceWaveView()
    private let streakCard = GlowCard()
    private let streakChart = StreakFlameView()
    private let insightCard  = GlowCard()
    private let insightStack = UIStackView()
    private let plannerCard = GlowCard()
    private let plannerStack = UIStackView()
    private let costField = UITextField()
    private let budgetField = UITextField()
    private let targetField = UITextField()
    private let loadingOverlay = UIView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupScrollView()
        setupHeader()
        setupParamCard()
        setupSimControl()
        setupSimulateButton()
        setupStatsGrid()
        setupCharts()
        setupInsightCard()
        setupPlannerCard()
        setupLoadingOverlay()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadPersistedParameters()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }

    // MARK: - Layout
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
        headerLabel.setEmojiSafeText("✦ Gacha Simulator", font: AppTheme.Typeface.display(26), color: AppTheme.Pigment.glacierWhite)
        contentStack.addArrangedSubview(headerLabel)
    }

    private func setupParamCard() {
        let card = GlowCard()
        card.translatesAutoresizingMaskIntoConstraints = false
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

        let cardTitle = makeLabel("Parameters", font: AppTheme.Typeface.headline(15), color: AppTheme.Pigment.glacierWhite)
        inner.addArrangedSubview(cardTitle)
        inner.addArrangedSubview(makeDivider())

        // SSR Rate
        ssrValueLabel.font = AppTheme.Typeface.mono(13)
        ssrValueLabel.textColor = AppTheme.Pigment.ssrGold
        ssrSlider.minimumValue = 0.001
        ssrSlider.maximumValue = 0.2
        ssrSlider.value = Float(ssrRate)
        ssrSlider.minimumTrackTintColor = AppTheme.Pigment.ssrGold
        ssrSlider.maximumTrackTintColor = AppTheme.Pigment.crystalBorder
        ssrSlider.addTarget(self, action: #selector(ssrSliderChanged), for: .valueChanged)
        inner.addArrangedSubview(makeSliderRow(label: "SSR Rate", valueLabel: ssrValueLabel, slider: ssrSlider))
        updateSSRLabel()

        // SR Rate
        srValueLabel.font = AppTheme.Typeface.mono(13)
        srValueLabel.textColor = AppTheme.Pigment.srPurple
        srSlider.minimumValue = 0.01
        srSlider.maximumValue = 0.5
        srSlider.value = Float(srRate)
        srSlider.minimumTrackTintColor = AppTheme.Pigment.srPurple
        srSlider.maximumTrackTintColor = AppTheme.Pigment.crystalBorder
        srSlider.addTarget(self, action: #selector(srSliderChanged), for: .valueChanged)
        inner.addArrangedSubview(makeSliderRow(label: "SR Rate", valueLabel: srValueLabel, slider: srSlider))
        updateSRLabel()

        inner.addArrangedSubview(makeDivider())

        // Pity toggle
        let pityRow = UIStackView()
        pityRow.axis = .horizontal
        pityRow.distribution = .equalSpacing
        let pityLbl = makeLabel("Pity System", font: AppTheme.Typeface.body(14), color: AppTheme.Pigment.glacierWhite)
        pityToggle.isOn = pityEnabled
        pityToggle.onTintColor = AppTheme.Pigment.nebulaViolet
        pityToggle.addTarget(self, action: #selector(pityToggled), for: .valueChanged)
        pityRow.addArrangedSubview(pityLbl)
        pityRow.addArrangedSubview(pityToggle)
        inner.addArrangedSubview(pityRow)

        // Hard pity stepper
        hardPityLabel.font = AppTheme.Typeface.mono(13)
        hardPityLabel.textColor = AppTheme.Pigment.novaRed
        hardPityStepper.minimumValue = 20
        hardPityStepper.maximumValue = 200
        hardPityStepper.stepValue = 5
        hardPityStepper.value = Double(hardPity)
        hardPityStepper.addTarget(self, action: #selector(hardPityChanged), for: .valueChanged)
        inner.addArrangedSubview(makeStepperRow(label: "Hard Pity", valueLabel: hardPityLabel, stepper: hardPityStepper))
        updatePityLabels()

        // Soft pity stepper
        softPityLabel.font = AppTheme.Typeface.mono(13)
        softPityLabel.textColor = AppTheme.Pigment.solarGold
        softPityStepper.minimumValue = 10
        softPityStepper.maximumValue = 150
        softPityStepper.stepValue = 5
        softPityStepper.value = Double(softPity)
        softPityStepper.addTarget(self, action: #selector(softPityChanged), for: .valueChanged)
        inner.addArrangedSubview(makeStepperRow(label: "Soft Pity", valueLabel: softPityLabel, stepper: softPityStepper))

        inner.addArrangedSubview(makeDivider())

        let planRow = UIStackView()
        planRow.axis = .horizontal
        planRow.spacing = 10
        planRow.distribution = .fillEqually
        let saveButton = makeSecondaryButton(title: "Save Plan", action: #selector(savePlanTapped))
        let loadButton = makeSecondaryButton(title: "Load Plan", action: #selector(loadPlanTapped))
        planRow.addArrangedSubview(saveButton)
        planRow.addArrangedSubview(loadButton)
        inner.addArrangedSubview(planRow)

        contentStack.addArrangedSubview(card)
    }

    private func setupSimControl() {
        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 10
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
        simSegment.selectedSegmentTintColor = AppTheme.Pigment.nebulaViolet
        simSegment.setTitleTextAttributes([.foregroundColor: AppTheme.Pigment.glacierWhite,
                                           .font: AppTheme.Typeface.body(13)], for: .normal)
        simSegment.setTitleTextAttributes([.foregroundColor: UIColor.white,
                                           .font: AppTheme.Typeface.headline(13)], for: .selected)
        simSegment.addTarget(self, action: #selector(simCountChanged), for: .valueChanged)
        inner.addArrangedSubview(simSegment)
        contentStack.addArrangedSubview(card)
    }

    private func setupSimulateButton() {
        simulateBtn.setTitle("▶  SIMULATE", for: .normal)
        simulateBtn.gradientColors = AppTheme.Pigment.gradientAccent
        simulateBtn.translatesAutoresizingMaskIntoConstraints = false
        simulateBtn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        simulateBtn.addTarget(self, action: #selector(simulateTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(simulateBtn)
    }

    private func setupStatsGrid() {
        statsContainer.translatesAutoresizingMaskIntoConstraints = false
        let grid = UIStackView(arrangedSubviews: [
            makeStatRow([ssrBadge, avgBadge]),
            makeStatRow([luckBadge, droughtBadge])
        ])
        grid.axis = .vertical
        grid.spacing = 10
        grid.translatesAutoresizingMaskIntoConstraints = false
        statsContainer.addSubview(grid)
        NSLayoutConstraint.activate([
            grid.topAnchor.constraint(equalTo: statsContainer.topAnchor),
            grid.bottomAnchor.constraint(equalTo: statsContainer.bottomAnchor),
            grid.leadingAnchor.constraint(equalTo: statsContainer.leadingAnchor),
            grid.trailingAnchor.constraint(equalTo: statsContainer.trailingAnchor),
        ])
        statsContainer.isHidden = true
        contentStack.addArrangedSubview(statsContainer)
    }

    private func setupCharts() {
        // Distribution
        let distTitle = makeLabel("Rarity Distribution", font: AppTheme.Typeface.headline(15), color: AppTheme.Pigment.glacierWhite)
        distChart.backgroundColor = .clear
        distChart.translatesAutoresizingMaskIntoConstraints = false
        distChart.heightAnchor.constraint(equalToConstant: 160).isActive = true
        let distInner = UIStackView(arrangedSubviews: [distTitle, distChart])
        distInner.axis = .vertical
        distInner.spacing = 10
        distInner.translatesAutoresizingMaskIntoConstraints = false
        chartCard.addSubview(distInner)
        NSLayoutConstraint.activate([
            distInner.topAnchor.constraint(equalTo: chartCard.topAnchor, constant: 16),
            distInner.bottomAnchor.constraint(equalTo: chartCard.bottomAnchor, constant: -16),
            distInner.leadingAnchor.constraint(equalTo: chartCard.leadingAnchor, constant: 16),
            distInner.trailingAnchor.constraint(equalTo: chartCard.trailingAnchor, constant: -16),
        ])
        chartCard.isHidden = true
        contentStack.addArrangedSubview(chartCard)

        // Convergence
        let convTitle = makeLabel("Convergence Curve", font: AppTheme.Typeface.headline(15), color: AppTheme.Pigment.glacierWhite)
        convChart.backgroundColor = .clear
        convChart.translatesAutoresizingMaskIntoConstraints = false
        convChart.heightAnchor.constraint(equalToConstant: 160).isActive = true
        let convInner = UIStackView(arrangedSubviews: [convTitle, convChart])
        convInner.axis = .vertical
        convInner.spacing = 10
        convInner.translatesAutoresizingMaskIntoConstraints = false
        convCard.addSubview(convInner)
        NSLayoutConstraint.activate([
            convInner.topAnchor.constraint(equalTo: convCard.topAnchor, constant: 16),
            convInner.bottomAnchor.constraint(equalTo: convCard.bottomAnchor, constant: -16),
            convInner.leadingAnchor.constraint(equalTo: convCard.leadingAnchor, constant: 16),
            convInner.trailingAnchor.constraint(equalTo: convCard.trailingAnchor, constant: -16),
        ])
        convCard.isHidden = true
        contentStack.addArrangedSubview(convCard)

        // Streak
        let streakTitle = makeLabel("Drought Analysis", font: AppTheme.Typeface.headline(15), color: AppTheme.Pigment.glacierWhite)
        streakChart.backgroundColor = .clear
        streakChart.translatesAutoresizingMaskIntoConstraints = false
        streakChart.heightAnchor.constraint(equalToConstant: 140).isActive = true
        let streakInner = UIStackView(arrangedSubviews: [streakTitle, streakChart])
        streakInner.axis = .vertical
        streakInner.spacing = 10
        streakInner.translatesAutoresizingMaskIntoConstraints = false
        streakCard.addSubview(streakInner)
        NSLayoutConstraint.activate([
            streakInner.topAnchor.constraint(equalTo: streakCard.topAnchor, constant: 16),
            streakInner.bottomAnchor.constraint(equalTo: streakCard.bottomAnchor, constant: -16),
            streakInner.leadingAnchor.constraint(equalTo: streakCard.leadingAnchor, constant: 16),
            streakInner.trailingAnchor.constraint(equalTo: streakCard.trailingAnchor, constant: -16),
        ])
        streakCard.isHidden = true
        contentStack.addArrangedSubview(streakCard)
    }

    private func setupInsightCard() {
        insightStack.axis = .vertical
        insightStack.spacing = 10
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

    private func setupPlannerCard() {
        plannerStack.axis = .vertical
        plannerStack.spacing = 10
        plannerStack.translatesAutoresizingMaskIntoConstraints = false
        plannerCard.addSubview(plannerStack)
        NSLayoutConstraint.activate([
            plannerStack.topAnchor.constraint(equalTo: plannerCard.topAnchor, constant: 14),
            plannerStack.bottomAnchor.constraint(equalTo: plannerCard.bottomAnchor, constant: -14),
            plannerStack.leadingAnchor.constraint(equalTo: plannerCard.leadingAnchor, constant: 16),
            plannerStack.trailingAnchor.constraint(equalTo: plannerCard.trailingAnchor, constant: -16),
        ])

        let title = makeLabel("Budget & Target Planner", font: AppTheme.Typeface.headline(14), color: AppTheme.Pigment.glacierWhite)
        plannerStack.addArrangedSubview(title)
        plannerStack.addArrangedSubview(makeDivider())

        configureNumberField(costField, placeholder: "Cost per pull")
        configureNumberField(budgetField, placeholder: "Budget")
        configureNumberField(targetField, placeholder: "Target hit rate % (e.g. 90)")
        targetField.text = "90"
        plannerStack.addArrangedSubview(costField)
        plannerStack.addArrangedSubview(budgetField)
        plannerStack.addArrangedSubview(targetField)

        let calculate = makeSecondaryButton(title: "Run Planner", action: #selector(runPlannerTapped))
        plannerStack.addArrangedSubview(calculate)
        plannerCard.isHidden = false
        contentStack.addArrangedSubview(plannerCard)
    }

    private func populateInsightCard(result: GachaResult) {
        insightStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let header = UILabel()
        header.text = "Statistical Insights"
        header.font = AppTheme.Typeface.headline(14)
        header.textColor = AppTheme.Pigment.glacierWhite
        insightStack.addArrangedSubview(header)

        let divider = UIView()
        divider.backgroundColor = AppTheme.Pigment.crystalBorder
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        insightStack.addArrangedSubview(divider)

        // E[X] theory vs actual
        let theory = ProbabilityViewController.expectedPullsWithPity(
            rate: result.theoreticalSSRRate, hardPity: hardPity,
            softPity: softPity, pityEnabled: pityEnabled)
        let deviation = ((result.avgPullsPerSSR - theory) / theory) * 100
        let deviationSign = deviation < 0 ? "fewer" : "more"
        let deviationColor: UIColor = deviation < 0 ? AppTheme.Pigment.auroraGreen : AppTheme.Pigment.novaRed
        insightStack.addArrangedSubview(makeInsightRow(
            icon: "chart.line.uptrend.xyaxis",
            iconColor: AppTheme.Pigment.nebulaViolet,
            text: "Expected trials/SSR: \(String(format: "%.1f", theory))  ·  Simulated: \(String(format: "%.1f", result.avgPullsPerSSR))",
            subtext: String(format: "%.1f%% %@ trials than theoretical mean", abs(deviation), deviationSign),
            subtextColor: deviationColor
        ))

        // Luck index
        let luckDesc = result.luckIndex >= 1.0
            ? String(format: "%.2fx above expected rate — this run was fortunate", result.luckIndex)
            : String(format: "%.2fx below expected rate — this run was unlucky", result.luckIndex)
        insightStack.addArrangedSubview(makeInsightRow(
            icon: "star.fill",
            iconColor: AppTheme.Pigment.ssrGold,
            text: "Luck Index: \(String(format: "%.3f", result.luckIndex))× (1.000 = exactly on rate)",
            subtext: luckDesc,
            subtextColor: result.luckIndex >= 1 ? AppTheme.Pigment.auroraGreen : AppTheme.Pigment.novaRed
        ))

        // P99 drought
        let p99Drought = ProbabilityViewController.percentileWithPity(
            target: 0.99, rate: result.theoreticalSSRRate,
            hardPity: hardPity, softPity: softPity, pityEnabled: pityEnabled)
        let droughtColor: UIColor = result.badLuckIndex > p99Drought
            ? AppTheme.Pigment.novaRed : AppTheme.Pigment.mistGray
        insightStack.addArrangedSubview(makeInsightRow(
            icon: "bolt.trianglebadge.exclamationmark",
            iconColor: AppTheme.Pigment.novaRed,
            text: "Longest trial gap: \(result.badLuckIndex)  ·  P99 gap at this rate: \(p99Drought)",
            subtext: result.badLuckIndex > p99Drought
                ? "⚠️ Observed drought exceeds the 99th percentile threshold"
                : "Drought within expected statistical range",
            subtextColor: droughtColor
        ))

        // Convergence note
        insightStack.addArrangedSubview(makeInsightRow(
            icon: "arrow.triangle.2.circlepath",
            iconColor: AppTheme.Pigment.prismaticBlue,
            text: "Law of Large Numbers: rate converges to p=\(String(format: "%.2f%%", result.theoreticalSSRRate * 100))",
            subtext: "Observed: \(String(format: "%.3f%%", result.actualSSRRate * 100)) over \(result.totalPulls) trials",
            subtextColor: AppTheme.Pigment.mistGray
        ))

        insightCard.isHidden = false
    }

    private func populatePlannerResult(_ result: BudgetPlannerResult) {
        while plannerStack.arrangedSubviews.count > 6 {
            let view = plannerStack.arrangedSubviews.last!
            plannerStack.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        plannerStack.addArrangedSubview(makeInsightRow(
            icon: "wallet.pass.fill",
            iconColor: AppTheme.Pigment.ssrGold,
            text: "Budget supports \(result.maxPulls) pulls with current cost assumptions",
            subtext: "Hit probability under budget: \(ProbabilityResearchKit.formatPercent(result.hitProbability))",
            subtextColor: AppTheme.Pigment.auroraGreen
        ))
        plannerStack.addArrangedSubview(makeInsightRow(
            icon: "target",
            iconColor: AppTheme.Pigment.prismaticBlue,
            text: "Target requires ~\(result.requiredPullsForTarget) pulls",
            subtext: "Estimated budget needed: \(ProbabilityResearchKit.formatCurrency(result.requiredBudgetForTarget))",
            subtextColor: AppTheme.Pigment.prismaticBlue
        ))
        plannerStack.addArrangedSubview(makeInsightRow(
            icon: "chart.bar.doc.horizontal.fill",
            iconColor: AppTheme.Pigment.nebulaViolet,
            text: "Risk zones — Lucky P25: \(result.riskBand.p25), Typical P50: \(result.riskBand.p50), Worst P95: \(result.riskBand.p95)",
            subtext: "Expected pulls \(String(format: "%.1f", result.riskBand.expectedPulls)) · Tail risk compresses once pity ramps up",
            subtextColor: AppTheme.Pigment.mistGray
        ))
    }

    private func makeInsightRow(icon: String, iconColor: UIColor, text: String, subtext: String, subtextColor: UIColor) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10
        row.alignment = .top
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let ico = UIImageView(image: UIImage(systemName: icon, withConfiguration: cfg))
        ico.tintColor = iconColor
        ico.contentMode = .scaleAspectFit
        ico.widthAnchor.constraint(equalToConstant: 18).isActive = true
        ico.heightAnchor.constraint(equalToConstant: 20).isActive = true
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2
        let mainLbl = UILabel()
        mainLbl.setEmojiSafeText(text, font: AppTheme.Typeface.body(12), color: AppTheme.Pigment.glacierWhite)
        mainLbl.numberOfLines = 0
        let subLbl = UILabel()
        subLbl.setEmojiSafeText(subtext, font: AppTheme.Typeface.caption(11), color: subtextColor)
        subLbl.numberOfLines = 0
        textStack.addArrangedSubview(mainLbl)
        textStack.addArrangedSubview(subLbl)
        row.addArrangedSubview(ico)
        row.addArrangedSubview(textStack)
        return row
    }

    private func setupLoadingOverlay() {
        loadingOverlay.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        loadingOverlay.isHidden = true
        activityIndicator.color = AppTheme.Pigment.nebulaViolet
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingOverlay.addSubview(activityIndicator)
        loadingOverlay.translatesAutoresizingMaskIntoConstraints = false
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
    @objc private func ssrSliderChanged() {
        ssrRate = Double(ssrSlider.value)
        updateSSRLabel()
        Haptics.shared.selectItem()
    }
    @objc private func srSliderChanged() {
        srRate = Double(srSlider.value)
        updateSRLabel()
        Haptics.shared.selectItem()
    }
    @objc private func pityToggled() {
        pityEnabled = pityToggle.isOn
        hardPityStepper.isEnabled = pityEnabled
        softPityStepper.isEnabled = pityEnabled
        Haptics.shared.tapLight()
    }
    @objc private func hardPityChanged() {
        hardPity = Int(hardPityStepper.value)
        if softPity >= hardPity { softPity = hardPity - 10; softPityStepper.value = Double(softPity) }
        updatePityLabels()
    }
    @objc private func softPityChanged() {
        softPity = Int(softPityStepper.value)
        if softPity >= hardPity { softPity = hardPity - 5; softPityStepper.value = Double(softPity) }
        updatePityLabels()
    }
    @objc private func simCountChanged() {
        simCount = [1000, 10000, 100000][simSegment.selectedSegmentIndex]
    }

    @objc private func savePlanTapped() {
        let alert = UIAlertController(title: "Save Current Plan", message: "Store this gacha configuration for future comparison.", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Plan name"; $0.text = "Plan \(AppStorage.shared.savedGachaPlans().count + 1)" }
        alert.addTextField { $0.placeholder = "Cost per pull"; $0.keyboardType = .decimalPad; $0.text = self.costField.text }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines)
            let cost = Double(alert.textFields?.dropFirst().first?.text ?? "") ?? 0
            let plan = GachaPlan(
                name: name?.isEmpty == false ? name! : "Untitled Plan",
                ssrRate: self.ssrRate,
                srRate: self.srRate,
                hardPity: self.hardPity,
                softPity: self.softPity,
                pityEnabled: self.pityEnabled,
                costPerPull: cost
            )
            AppStorage.shared.appendGachaPlan(plan)
            self.costField.text = cost > 0 ? String(format: "%.2f", cost) : nil
            Haptics.shared.successPulse()
        })
        present(alert, animated: true)
    }

    @objc private func loadPlanTapped() {
        let plans = AppStorage.shared.savedGachaPlans()
        guard !plans.isEmpty else {
            showSimpleAlert(title: "No Saved Plans", message: "Save a plan first to load or compare it later.")
            return
        }
        let sheet = UIAlertController(title: "Load Plan", message: nil, preferredStyle: .actionSheet)
        for plan in plans {
            sheet.addAction(UIAlertAction(title: plan.name, style: .default) { _ in
                self.apply(plan: plan)
            })
        }
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }

    @objc private func runPlannerTapped() {
        let cost = Double(costField.text ?? "") ?? 0
        let budget = Double(budgetField.text ?? "") ?? 0
        let target = min(max((Double(targetField.text ?? "") ?? 90) / 100, 0.1), 0.99)
        let plan = currentPlan(name: "Current Plan", costPerPull: cost)
        let result = ProbabilityResearchKit.budgetPlanner(plan: plan, budget: budget, targetProbability: target)
        populatePlannerResult(result)
        Haptics.shared.successPulse()
    }

    @objc private func simulateTapped() {
        AppStorage.shared.ssrRate = ssrRate
        AppStorage.shared.srRate  = srRate
        AppStorage.shared.hardPity = hardPity
        AppStorage.shared.softPity = softPity
        AppStorage.shared.pityEnabled = pityEnabled
        AppStorage.shared.simulationCount = simCount

        loadingOverlay.isHidden = false
        activityIndicator.startAnimating()
        simulateBtn.isEnabled = false

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            let result = GachaEngine.shared.runSimulation(
                ssrRate: self.ssrRate, srRate: self.srRate,
                hardPity: self.hardPity, softPity: self.softPity,
                pityEnabled: self.pityEnabled, totalPulls: self.simCount)
            DispatchQueue.main.async { self.displayResult(result) }
        }
    }

    private func displayResult(_ result: GachaResult) {
        lastResult = result
        loadingOverlay.isHidden = true
        activityIndicator.stopAnimating()
        simulateBtn.isEnabled = true
        simulateBtn.animatePulse()
        Haptics.shared.ssrBurst()

        // Stats
        ssrBadge.updateValue("\(result.ssrCount)")
        avgBadge.updateValue(String(format: "%.1f", result.avgPullsPerSSR))
        let luckStr = String(format: "%.2fx", result.luckIndex)
        luckBadge.updateValue(luckStr)
        droughtBadge.updateValue("\(result.badLuckIndex)")
        statsContainer.isHidden = false

        // Distribution chart
        distChart.setEntries([
            .init(label: "SSR", value: result.actualSSRRate, color: AppTheme.Pigment.ssrGold),
            .init(label: "SR",  value: result.actualSRRate,  color: AppTheme.Pigment.srPurple),
            .init(label: "R",   value: 1 - result.actualSSRRate - result.actualSRRate, color: AppTheme.Pigment.rBlue),
        ])
        chartCard.isHidden = false

        // Convergence
        convChart.setData(points: result.convergenceData, theoretical: result.theoreticalSSRRate)
        convCard.isHidden = false

        // Streak
        let intervals = zip(result.ssrPullIndices, result.ssrPullIndices.dropFirst()).map { $1 - $0 }
        streakChart.setStreaks(intervals)
        streakCard.isHidden = false

        // Save history
        let summary = "SSR:\(result.ssrCount) Avg:\(String(format:"%.1f",result.avgPullsPerSSR)) Luck:\(String(format:"%.2f",result.luckIndex))x"
        AppStorage.shared.appendGachaHistory(summary)
        onGachaResult?(result)
        populateInsightCard(result: result)

        // Scroll to stats
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let offset = CGPoint(x: 0, y: self.statsContainer.frame.minY - 20)
            self.scrollView.setContentOffset(offset, animated: true)
        }
    }

    // MARK: - Helpers
    private func updateSSRLabel() {
        ssrValueLabel.text = String(format: "%.2f%%", ssrRate * 100)
    }
    private func updateSRLabel() {
        srValueLabel.text = String(format: "%.1f%%", srRate * 100)
    }
    private func updatePityLabels() {
        hardPityLabel.text = "\(hardPity) pulls"
        softPityLabel.text = "\(softPity) pulls"
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

    private func makeSecondaryButton(title: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(AppTheme.Pigment.glacierWhite, for: .normal)
        button.titleLabel?.font = AppTheme.Typeface.body(13)
        button.backgroundColor = AppTheme.Pigment.crystalBorder.withAlphaComponent(0.5)
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    private func currentPlan(name: String, costPerPull: Double) -> GachaPlan {
        GachaPlan(
            name: name,
            ssrRate: ssrRate,
            srRate: srRate,
            hardPity: hardPity,
            softPity: softPity,
            pityEnabled: pityEnabled,
            costPerPull: costPerPull
        )
    }

    private func apply(plan: GachaPlan) {
        ssrRate = plan.ssrRate
        srRate = plan.srRate
        hardPity = plan.hardPity
        softPity = plan.softPity
        pityEnabled = plan.pityEnabled
        costField.text = plan.costPerPull > 0 ? String(format: "%.2f", plan.costPerPull) : nil
        ssrSlider.value = Float(plan.ssrRate)
        srSlider.value = Float(plan.srRate)
        hardPityStepper.value = Double(plan.hardPity)
        softPityStepper.value = Double(plan.softPity)
        pityToggle.isOn = plan.pityEnabled
        hardPityStepper.isEnabled = plan.pityEnabled
        softPityStepper.isEnabled = plan.pityEnabled
        updateSSRLabel()
        updateSRLabel()
        updatePityLabels()
        Haptics.shared.successPulse()
    }

    private func reloadPersistedParameters() {
        let plan = GachaPlan(
            name: "Current",
            ssrRate: AppStorage.shared.ssrRate,
            srRate: AppStorage.shared.srRate,
            hardPity: AppStorage.shared.hardPity,
            softPity: AppStorage.shared.softPity,
            pityEnabled: AppStorage.shared.pityEnabled,
            costPerPull: Double(costField.text ?? "") ?? 0
        )
        apply(plan: plan)
    }

    private func showSimpleAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func makeLabel(_ text: String, font: UIFont, color: UIColor) -> UILabel {
        let l = UILabel(); l.setEmojiSafeText(text, font: font, color: color); return l
    }
    private func makeDivider() -> UIView {
        let v = UIView(); v.backgroundColor = AppTheme.Pigment.crystalBorder
        v.heightAnchor.constraint(equalToConstant: 1).isActive = true; return v
    }
    private func makeSliderRow(label: String, valueLabel: UILabel, slider: UISlider) -> UIView {
        let row = UIStackView()
        row.axis = .vertical; row.spacing = 6
        let top = UIStackView()
        top.axis = .horizontal; top.distribution = .equalSpacing
        let lbl = makeLabel(label, font: AppTheme.Typeface.body(13), color: AppTheme.Pigment.mistGray)
        top.addArrangedSubview(lbl); top.addArrangedSubview(valueLabel)
        row.addArrangedSubview(top); row.addArrangedSubview(slider)
        return row
    }
    private func makeStepperRow(label: String, valueLabel: UILabel, stepper: UIStepper) -> UIView {
        let row = UIStackView()
        row.axis = .horizontal; row.distribution = .equalSpacing; row.alignment = .center
        let lbl = makeLabel(label, font: AppTheme.Typeface.body(13), color: AppTheme.Pigment.mistGray)
        let right = UIStackView(arrangedSubviews: [valueLabel, stepper])
        right.axis = .horizontal; right.spacing = 10; right.alignment = .center
        row.addArrangedSubview(lbl); row.addArrangedSubview(right)
        return row
    }
    private func makeStatRow(_ badges: [UIView]) -> UIStackView {
        let row = UIStackView(arrangedSubviews: badges)
        row.axis = .horizontal; row.distribution = .fillEqually; row.spacing = 10
        return row
    }
}
