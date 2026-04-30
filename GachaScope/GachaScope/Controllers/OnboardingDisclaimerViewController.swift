import UIKit

final class OnboardingViewController: UIViewController {
    private let gradLayer = CAGradientLayer()
    private let scrollView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupContent()
        setupCTA()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradLayer.frame = view.bounds
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    private func setupBackground() {
        gradLayer.colors = [
            AppTheme.Pigment.voidBlack.cgColor,
            AppTheme.Pigment.cosmicPurple.cgColor,
            AppTheme.Pigment.abyssNavy.cgColor
        ]
        gradLayer.locations = [0, 0.6, 1]
        gradLayer.startPoint = CGPoint(x: 0.1, y: 0)
        gradLayer.endPoint   = CGPoint(x: 0.9, y: 1)
        view.layer.insertSublayer(gradLayer, at: 0)
    }

    private func setupContent() {
        let ctaHeight: CGFloat = 90
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -ctaHeight),
        ])

        let outer = UIStackView()
        outer.axis = .vertical
        outer.spacing = 20
        outer.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(outer)
        NSLayoutConstraint.activate([
            outer.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 36),
            outer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            outer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            outer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
        ])

        // Icon + title
        let iconCfg = UIImage.SymbolConfiguration(pointSize: 54, weight: .light)
        let iconView = UIImageView(image: UIImage(systemName: "function", withConfiguration: iconCfg))
        iconView.tintColor = AppTheme.Pigment.prismaticBlue
        iconView.contentMode = .scaleAspectFit
        iconView.heightAnchor.constraint(equalToConstant: 72).isActive = true
        outer.addArrangedSubview(iconView)

        let titleLbl = UILabel()
        titleLbl.text = "Probability Analysis Tool"
        titleLbl.font = AppTheme.Typeface.display(28)
        titleLbl.textColor = AppTheme.Pigment.glacierWhite
        titleLbl.textAlignment = .center
        titleLbl.numberOfLines = 2
        outer.addArrangedSubview(titleLbl)

        let subtitleLbl = UILabel()
        subtitleLbl.text = "For game designers, probability students,\nand curious researchers"
        subtitleLbl.font = AppTheme.Typeface.body(14)
        subtitleLbl.textColor = AppTheme.Pigment.mistGray
        subtitleLbl.textAlignment = .center
        subtitleLbl.numberOfLines = 0
        outer.addArrangedSubview(subtitleLbl)

        // What this IS
        outer.addArrangedSubview(makeInfoCard(
            icon: "checkmark.circle.fill", iconColor: AppTheme.Pigment.auroraGreen,
            heading: "What GachaScope Is",
            items: [
                "A Monte Carlo probability simulator built on rigorous statistical methods",
                "A game design research tool for evaluating and comparing drop rate configurations",
                "An educational platform visualizing geometric distribution, expected value, and the Law of Large Numbers"
            ]
        ))

        // What this IS NOT
        outer.addArrangedSubview(makeInfoCard(
            icon: "xmark.circle.fill", iconColor: AppTheme.Pigment.novaRed,
            heading: "What GachaScope Is Not",
            items: [
                "Not a gambling app — contains no real money, no wagering, and no prizes",
                "Not affiliated with or endorsed by any game publisher or studio",
                "Not an incentive to spend money on games or in-app purchases"
            ]
        ))

        // Technical disclaimer card
        outer.addArrangedSubview(makeTechDisclaimerCard())
    }

    private func makeInfoCard(icon: String, iconColor: UIColor, heading: String, items: [String]) -> UIView {
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

        let headRow = UIStackView()
        headRow.axis = .horizontal
        headRow.spacing = 10
        headRow.alignment = .center
        let cfg = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        let ico = UIImageView(image: UIImage(systemName: icon, withConfiguration: cfg))
        ico.tintColor = iconColor
        ico.contentMode = .scaleAspectFit
        ico.widthAnchor.constraint(equalToConstant: 22).isActive = true
        let headLbl = UILabel()
        headLbl.text = heading
        headLbl.font = AppTheme.Typeface.headline(15)
        headLbl.textColor = AppTheme.Pigment.glacierWhite
        headRow.addArrangedSubview(ico)
        headRow.addArrangedSubview(headLbl)
        inner.addArrangedSubview(headRow)

        let divider = UIView()
        divider.backgroundColor = AppTheme.Pigment.crystalBorder
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true
        inner.addArrangedSubview(divider)

        for text in items {
            let row = UIStackView()
            row.axis = .horizontal
            row.spacing = 8
            row.alignment = .top
            let dot = UILabel()
            dot.text = "•"
            dot.font = AppTheme.Typeface.body(13)
            dot.textColor = iconColor
            dot.setContentHuggingPriority(.required, for: .horizontal)
            let lbl = UILabel()
            lbl.text = text
            lbl.font = AppTheme.Typeface.body(13)
            lbl.textColor = AppTheme.Pigment.mistGray
            lbl.numberOfLines = 0
            row.addArrangedSubview(dot)
            row.addArrangedSubview(lbl)
            inner.addArrangedSubview(row)
        }
        return card
    }

    private func makeTechDisclaimerCard() -> UIView {
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

        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 8
        row.alignment = .center
        let cfg = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let ico = UIImageView(image: UIImage(systemName: "info.circle", withConfiguration: cfg))
        ico.tintColor = AppTheme.Pigment.prismaticBlue
        ico.contentMode = .scaleAspectFit
        ico.widthAnchor.constraint(equalToConstant: 18).isActive = true
        let headLbl = UILabel()
        headLbl.text = "Technical Disclaimer"
        headLbl.font = AppTheme.Typeface.headline(13)
        headLbl.textColor = AppTheme.Pigment.glacierWhite
        row.addArrangedSubview(ico)
        row.addArrangedSubview(headLbl)
        inner.addArrangedSubview(row)

        let bodyLbl = UILabel()
        bodyLbl.text = "All simulations use seedless pseudorandom number generation (PRNG). Results reflect statistical distributions only and will not predict real-world outcomes. Each trial is mathematically independent — prior results do not influence future probabilities."
        bodyLbl.font = AppTheme.Typeface.caption(12)
        bodyLbl.textColor = AppTheme.Pigment.mistGray
        bodyLbl.numberOfLines = 0
        inner.addArrangedSubview(bodyLbl)
        return card
    }

    private func setupCTA() {
        let btn = PulseButton()
        btn.setTitle("I Understand — Launch App", for: .normal)
        btn.titleLabel?.font = AppTheme.Typeface.headline(15)
        btn.gradientColors = AppTheme.Pigment.gradientAccent
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 56).isActive = true
        btn.addTarget(self, action: #selector(launchApp), for: .touchUpInside)
        view.addSubview(btn)
        NSLayoutConstraint.activate([
            btn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
        ])
    }

    @objc private func launchApp() {
        Haptics.shared.successPulse()
        AppStorage.shared.onboardingDone = true
        let main = DashboardViewController()
        main.modalTransitionStyle = .crossDissolve
        main.modalPresentationStyle = .fullScreen
        present(main, animated: true)
    }
}
