import UIKit

final class AnalyticsViewController: UIViewController {
    private let scrollView   = UIScrollView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        setupScrollView()
        setupHeader()
        setupEmptyState()
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
        lbl.text = "◉ Analysis"
        lbl.font = AppTheme.Typeface.display(26)
        lbl.textColor = AppTheme.Pigment.prismaticBlue
        contentStack.addArrangedSubview(lbl)

        let sub = UILabel()
        sub.text = "Run a simulation in Gacha or Slot tab to see detailed analysis here."
        sub.font = AppTheme.Typeface.body(13)
        sub.textColor = AppTheme.Pigment.mistGray
        sub.numberOfLines = 0
        contentStack.addArrangedSubview(sub)
    }

    private func setupEmptyState() {
        // Educational content shown when no simulation has been run yet
        let introLbl = UILabel()
        introLbl.text = "Run a simulation in the Gacha or Slot tab to load results here. While you wait, explore the probability concepts below."
        introLbl.font = AppTheme.Typeface.body(13)
        introLbl.textColor = AppTheme.Pigment.mistGray
        introLbl.numberOfLines = 0
        contentStack.addArrangedSubview(introLbl)

        addEducationalContent()
    }

    private func addEducationalContent() {
        let concepts: [(String, String, String, String)] = [
            ("The Law of Large Numbers",
             "textformat.abc",
             AppTheme.Pigment.prismaticBlue.description,
             "As the number of independent trials increases, the observed frequency of an event converges to its true probability p. A short simulation may show significant variance; a 100K-trial simulation will be very close to the theoretical rate."),
            ("Expected Value  E[X] = 1/p",
             "function",
             AppTheme.Pigment.auroraGreen.description,
             "For a geometric distribution (each trial independent with probability p), the average number of trials until the first success is 1/p. If p = 0.6%, then E[X] = 166.7 trials. This is the theoretical 'fair' average — not a guarantee."),
            ("Pity / Guarantee Thresholds",
             "shield.fill",
             AppTheme.Pigment.nebulaViolet.description,
             "A hard pity at trial k means the event is guaranteed to trigger by trial k, regardless of prior results. This compresses the right tail of the distribution and reduces the expected value below 1/p. Soft pity linearly increases the success probability from a given trial onward."),
            ("Variance and Standard Deviation",
             "waveform.path.ecg",
             AppTheme.Pigment.ssrGold.description,
             "For a geometric distribution, Var(X) = (1−p)/p². High-variance scenarios (very low p) produce wide distributions — meaning some runs will be extremely lucky and others extremely unlucky, even when the mean is consistent."),
        ]

        let colors: [UIColor] = [
            AppTheme.Pigment.prismaticBlue,
            AppTheme.Pigment.auroraGreen,
            AppTheme.Pigment.nebulaViolet,
            AppTheme.Pigment.ssrGold
        ]

        for (i, (title, icon, _, body)) in concepts.enumerated() {
            let card = GlowCard()
            let inner = UIStackView()
            inner.axis = .vertical
            inner.spacing = 10
            inner.translatesAutoresizingMaskIntoConstraints = false
            card.addSubview(inner)
            NSLayoutConstraint.activate([
                inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
                inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
                inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            ])

            let color = colors[i]
            let headRow = UIStackView()
            headRow.axis = .horizontal
            headRow.spacing = 8
            headRow.alignment = .center
            let cfg = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
            let ico = UIImageView(image: UIImage(systemName: icon, withConfiguration: cfg))
            ico.tintColor = color
            ico.contentMode = .scaleAspectFit
            ico.widthAnchor.constraint(equalToConstant: 20).isActive = true
            let titleLbl = UILabel()
            titleLbl.text = title
            titleLbl.font = AppTheme.Typeface.headline(13)
            titleLbl.textColor = color
            titleLbl.numberOfLines = 0
            headRow.addArrangedSubview(ico)
            headRow.addArrangedSubview(titleLbl)
            inner.addArrangedSubview(headRow)

            let bodyLbl = UILabel()
            bodyLbl.text = body
            bodyLbl.font = AppTheme.Typeface.body(13)
            bodyLbl.textColor = AppTheme.Pigment.mistGray
            bodyLbl.numberOfLines = 0
            inner.addArrangedSubview(bodyLbl)
            contentStack.addArrangedSubview(card)
        }
    }

    func loadGachaResult(_ result: GachaResult) {
        contentStack.arrangedSubviews.dropFirst(2).forEach { $0.removeFromSuperview() }
        addSectionTitle("Gacha Distribution")
        addGachaDistChart(result)
        addSectionTitle("Convergence Curve")
        addConvergenceChart(result)
        addSectionTitle("Mechanic Insights")
        addMechanicInsightsCard(result)
        addSectionTitle("Drought Analysis")
        addDroughtCard(result)
        addSectionTitle("Tutorial Cases")
        addCaseStudyCard(result)
        addSectionTitle("History")
        addHistoryCard()
    }

    func loadSlotResult(_ result: ReelSlotResult) {
        contentStack.arrangedSubviews.dropFirst(2).forEach { $0.removeFromSuperview() }
        addSectionTitle("Balance Curve")
        addBalanceCurveCard(result)
        addSectionTitle("Win Distribution")
        addSlotDistCard(result)
        addSectionTitle("History")
        addHistoryCard()
    }

    private func addSectionTitle(_ text: String) {
        let lbl = UILabel()
        lbl.text = text
        lbl.font = AppTheme.Typeface.headline(14)
        lbl.textColor = AppTheme.Pigment.mistGray
        contentStack.addArrangedSubview(lbl)
    }

    private func addGachaDistChart(_ r: GachaResult) {
        let card = GlowCard()
        let chart = DistributionChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chart)
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            chart.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            chart.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            chart.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            chart.heightAnchor.constraint(equalToConstant: 160),
        ])
        chart.setEntries([
            .init(label: "SSR", value: r.actualSSRRate, color: AppTheme.Pigment.ssrGold),
            .init(label: "SR",  value: r.actualSRRate,  color: AppTheme.Pigment.srPurple),
            .init(label: "R",   value: 1 - r.actualSSRRate - r.actualSRRate, color: AppTheme.Pigment.rBlue),
            .init(label: "Theory SSR", value: r.theoreticalSSRRate, color: AppTheme.Pigment.ssrGold.withAlphaComponent(0.4)),
        ])
        contentStack.addArrangedSubview(card)
    }

    private func addConvergenceChart(_ r: GachaResult) {
        let card = GlowCard()
        let chart = ConvergenceWaveView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chart)
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            chart.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            chart.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            chart.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            chart.heightAnchor.constraint(equalToConstant: 160),
        ])
        chart.setData(points: r.convergenceData, theoretical: r.theoreticalSSRRate)
        contentStack.addArrangedSubview(card)
    }

    private func addDroughtCard(_ r: GachaResult) {
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
        let rows: [(String, String, UIColor)] = [
            ("Bad Luck Index",    "\(r.badLuckIndex) pulls",                    AppTheme.Pigment.novaRed),
            ("Best Streak",       "\(r.shortestSSRStreak) pulls",               AppTheme.Pigment.auroraGreen),
            ("Luck Index",        String(format: "%.2fx", r.luckIndex),         r.luckIndex >= 1 ? AppTheme.Pigment.auroraGreen : AppTheme.Pigment.novaRed),
            ("Avg Pulls / SSR",   String(format: "%.1f", r.avgPullsPerSSR),     AppTheme.Pigment.nebulaViolet),
        ]
        for (title, value, color) in rows {
            let row = UIStackView()
            row.axis = .horizontal
            row.distribution = .equalSpacing
            let t = UILabel(); t.text = title; t.font = AppTheme.Typeface.body(13); t.textColor = AppTheme.Pigment.mistGray
            let v = UILabel(); v.text = value; v.font = AppTheme.Typeface.mono(13); v.textColor = color
            row.addArrangedSubview(t)
            row.addArrangedSubview(v)
            inner.addArrangedSubview(row)
        }
        contentStack.addArrangedSubview(card)
    }

    private func addMechanicInsightsCard(_ result: GachaResult) {
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

        let baseRate = result.theoreticalSSRRate
        let p50 = ProbabilityViewController.percentileWithPity(target: 0.5, rate: baseRate, hardPity: AppStorage.shared.hardPity, softPity: AppStorage.shared.softPity, pityEnabled: AppStorage.shared.pityEnabled)
        let p90 = ProbabilityViewController.percentileWithPity(target: 0.9, rate: baseRate, hardPity: AppStorage.shared.hardPity, softPity: AppStorage.shared.softPity, pityEnabled: AppStorage.shared.pityEnabled)
        let noPityP90 = ProbabilityViewController.percentileWithPity(target: 0.9, rate: baseRate, hardPity: AppStorage.shared.hardPity, softPity: AppStorage.shared.softPity, pityEnabled: false)

        inner.addArrangedSubview(makeInsightRow(
            title: "Why pity compresses the right tail",
            body: "At the current settings, typical success lands around draw \(p50), but the 90th percentile lands near draw \(p90). Without pity, that 90th percentile would drift to roughly \(noPityP90), so pity mainly reduces extreme unlucky runs rather than average luck."
        ))
        inner.addArrangedSubview(makeInsightRow(
            title: "Why low-rate systems feel harsher than the mean suggests",
            body: "The simulated average is \(String(format: "%.1f", result.avgPullsPerSSR)), but the longest drought hit \(result.badLuckIndex). High variance makes subjective experience noisier than the expected value, especially when players track streaks more than averages."
        ))
        inner.addArrangedSubview(makeInsightRow(
            title: "Design implication",
            body: "If you want retention-friendly systems, reduce long-tail pressure before raising headline odds. A stronger pity curve often improves player trust more than a small increase in base probability."
        ))

        contentStack.addArrangedSubview(card)
    }

    private func addCaseStudyCard(_ result: GachaResult) {
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

        let cases = [
            ("Case A · Pure RNG", "When pity is disabled, every draw repeats the same chance. This keeps the math simple but pushes frustration into the long tail."),
            ("Case B · Soft pity", "Soft pity gradually increases hit chance after a threshold. This preserves early uncertainty while giving late-session relief."),
            ("Case C · Hard pity", "Hard pity caps the maximum failure streak. It is the cleanest tool for budget predictability and the clearest safeguard for unlucky users.")
        ]

        for item in cases {
            inner.addArrangedSubview(makeInsightRow(title: item.0, body: item.1))
        }

        let footer = UILabel()
        footer.setEmojiSafeText("Current simulation takeaway: actual SSR rate settled at \(String(format: "%.2f%%", result.actualSSRRate * 100)), while subjective pain was driven more by the \(result.badLuckIndex)-pull drought than by the mean itself.", font: AppTheme.Typeface.caption(12), color: AppTheme.Pigment.mistGray)
        footer.numberOfLines = 0
        inner.addArrangedSubview(footer)

        contentStack.addArrangedSubview(card)
    }

    private func addBalanceCurveCard(_ r: ReelSlotResult) {
        let card = GlowCard()
        let chart = BalanceCurveView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chart)
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            chart.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            chart.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            chart.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            chart.heightAnchor.constraint(equalToConstant: 180),
        ])
        chart.setData(r.balanceCurve)
        contentStack.addArrangedSubview(card)
    }

    private func addSlotDistCard(_ r: ReelSlotResult) {
        let card = GlowCard()
        let chart = DistributionChartView()
        chart.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(chart)
        NSLayoutConstraint.activate([
            chart.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            chart.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),
            chart.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            chart.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            chart.heightAnchor.constraint(equalToConstant: 160),
        ])
        chart.setEntries([
            .init(label: "Win",     value: r.winRateActual,    color: AppTheme.Pigment.auroraGreen),
            .init(label: "Big Win", value: r.bigWinRateActual, color: AppTheme.Pigment.ssrGold),
            .init(label: "Loss",    value: 1 - r.winRateActual, color: AppTheme.Pigment.novaRed),
        ])
        contentStack.addArrangedSubview(card)
    }

    private func addHistoryCard() {
        let card = GlowCard()
        let inner = UIStackView()
        inner.axis = .vertical
        inner.spacing = 8
        inner.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(inner)
        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            inner.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            inner.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
        ])
        let title = UILabel()
        title.text = "Recent Sessions"
        title.font = AppTheme.Typeface.headline(14)
        title.textColor = AppTheme.Pigment.glacierWhite
        inner.addArrangedSubview(title)

        let gHistory = AppStorage.shared.gachaHistory()
        let sHistory = AppStorage.shared.slotHistory()
        let all = (gHistory + sHistory).suffix(8)
        if all.isEmpty {
            let empty = UILabel()
            empty.text = "No history yet"
            empty.font = AppTheme.Typeface.caption(12)
            empty.textColor = AppTheme.Pigment.mistGray
            inner.addArrangedSubview(empty)
        } else {
            for entry in all.reversed() {
                let lbl = UILabel()
                lbl.text = "• \(entry)"
                lbl.font = AppTheme.Typeface.caption(12)
                lbl.textColor = AppTheme.Pigment.mistGray
                lbl.numberOfLines = 0
                inner.addArrangedSubview(lbl)
            }
        }
        contentStack.addArrangedSubview(card)
    }

    private func makeInsightRow(title: String, body: String) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AppTheme.Typeface.headline(13)
        titleLabel.textColor = AppTheme.Pigment.glacierWhite
        let bodyLabel = UILabel()
        bodyLabel.text = body
        bodyLabel.font = AppTheme.Typeface.caption(12)
        bodyLabel.textColor = AppTheme.Pigment.mistGray
        bodyLabel.numberOfLines = 0
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(bodyLabel)
        return stack
    }
}
