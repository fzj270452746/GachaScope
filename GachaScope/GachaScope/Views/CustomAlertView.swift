import UIKit

// MARK: - Custom Alert
final class AlertView: UIView {
    private let blurView   = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
    private let container  = GlowCard()
    private let titleLbl   = UILabel()
    private let messageLbl = UILabel()
    private let stackView  = UIStackView()
    private var actions: [(title: String, style: AlertActionStyle, handler: (() -> Void)?)] = []

    enum AlertActionStyle { case primary, secondary, destructive }

    static func show(on vc: UIViewController, title: String, message: String,
                     actions: [(title: String, style: AlertActionStyle, handler: (() -> Void)?)]) {
        let alert = AlertView()
        alert.configure(title: title, message: message, actions: actions)
        alert.presentOn(vc.view)
    }

    private func configure(title: String, message: String,
                            actions: [(title: String, style: AlertActionStyle, handler: (() -> Void)?)]) {
        self.actions = actions
        titleLbl.text   = title
        messageLbl.text = message
        buildButtons()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        addSubview(blurView)
        addSubview(container)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        container.translatesAutoresizingMaskIntoConstraints = false

        titleLbl.font = AppTheme.Typeface.headline(20)
        titleLbl.textColor = AppTheme.Pigment.glacierWhite
        titleLbl.textAlignment = .center
        titleLbl.numberOfLines = 0

        messageLbl.font = AppTheme.Typeface.body(14)
        messageLbl.textColor = AppTheme.Pigment.mistGray
        messageLbl.textAlignment = .center
        messageLbl.numberOfLines = 0

        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually

        let content = UIStackView(arrangedSubviews: [titleLbl, messageLbl, stackView])
        content.axis = .vertical
        content.spacing = 16
        content.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20),
            container.centerYAnchor.constraint(equalTo: centerYAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    private func buildButtons() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (idx, action) in actions.enumerated() {
            let btn = PulseButton()
            btn.setTitle(action.title, for: .normal)
            btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
            switch action.style {
            case .primary:
                btn.gradientColors = AppTheme.Pigment.gradientAccent
            case .secondary:
                btn.gradientColors = [AppTheme.Pigment.crystalBorder, AppTheme.Pigment.obsidianCard]
            case .destructive:
                btn.gradientColors = [AppTheme.Pigment.novaRed, UIColor(hex: "#B91C1C")]
            }
            btn.tag = idx
            btn.addTarget(self, action: #selector(actionTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(btn)
        }
    }

    @objc private func actionTapped(_ sender: UIButton) {
        let handler = actions[sender.tag].handler
        dismiss { handler?() }
    }

    private func presentOn(_ parent: UIView) {
        frame = parent.bounds
        parent.addSubview(self)
        alpha = 0
        container.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 5, options: []) {
            self.alpha = 1
            self.container.transform = .identity
        }
    }

    private func dismiss(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.2, animations: {
            self.alpha = 0
            self.container.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            self.removeFromSuperview()
            completion?()
        }
    }
}
