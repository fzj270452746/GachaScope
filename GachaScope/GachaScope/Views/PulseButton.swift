import UIKit

// MARK: - Pulse Button
final class PulseButton: UIButton {
    private let gradLayer = CAGradientLayer()
    private let glowLayer = CALayer()
    var gradientColors: [UIColor] = AppTheme.Pigment.gradientAccent {
        didSet { updateGradient() }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setupLayers() }

    private func setupLayers() {
        layer.cornerRadius = AppTheme.Radius.lg
        clipsToBounds = false
        gradLayer.cornerRadius = AppTheme.Radius.lg
        gradLayer.startPoint = CGPoint(x: 0, y: 0)
        gradLayer.endPoint   = CGPoint(x: 1, y: 1)
        layer.insertSublayer(gradLayer, at: 0)

        glowLayer.cornerRadius = AppTheme.Radius.lg
        glowLayer.shadowColor  = AppTheme.Pigment.nebulaViolet.cgColor
        glowLayer.shadowOffset = .zero
        glowLayer.shadowRadius = 12
        glowLayer.shadowOpacity = 0.7
        glowLayer.backgroundColor = UIColor.clear.cgColor
        layer.insertSublayer(glowLayer, at: 0)

        titleLabel?.font = AppTheme.Typeface.headline(16)
        setTitleColor(.white, for: .normal)
        updateGradient()
        addTarget(self, action: #selector(touchDown), for: .touchDown)
        addTarget(self, action: #selector(touchUp),   for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    private func updateGradient() {
        gradLayer.colors = gradientColors.map { $0.cgColor }
        glowLayer.shadowColor = gradientColors.first?.cgColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradLayer.frame = bounds
        glowLayer.frame = bounds
    }

    @objc private func touchDown() {
        UIView.animate(withDuration: 0.1) { self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96) }
        Haptics.shared.tapMedium()
    }
    @objc private func touchUp() {
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 6, options: []) {
            self.transform = .identity
        }
    }

    func animatePulse() {
        let pulse = CABasicAnimation(keyPath: "shadowRadius")
        pulse.fromValue = 12
        pulse.toValue   = 24
        pulse.duration  = 0.4
        pulse.autoreverses = true
        pulse.repeatCount = 2
        glowLayer.add(pulse, forKey: "pulse")
    }
}

// MARK: - Glow Card
final class GlowCard: UIView {
    private let borderLayer = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) { super.init(coder: coder); setup() }

    private func setup() {
        backgroundColor = AppTheme.Pigment.obsidianCard
        layer.cornerRadius = AppTheme.Radius.lg
        clipsToBounds = false

        layer.shadowColor   = AppTheme.Pigment.nebulaViolet.withAlphaComponent(0.3).cgColor
        layer.shadowOffset  = CGSize(width: 0, height: 4)
        layer.shadowRadius  = 12
        layer.shadowOpacity = 1

        borderLayer.colors = AppTheme.Pigment.gradientAccent.map { $0.cgColor }
        borderLayer.startPoint = CGPoint(x: 0, y: 0)
        borderLayer.endPoint   = CGPoint(x: 1, y: 1)
        borderLayer.cornerRadius = AppTheme.Radius.lg
        layer.borderWidth = 0
    }

    func applyGradientBorder(width: CGFloat = 1.5) {
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: AppTheme.Radius.lg).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width
        borderLayer.frame = bounds
        borderLayer.mask = mask
        if borderLayer.superlayer == nil { layer.addSublayer(borderLayer) }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyGradientBorder()
    }
}

// MARK: - Stat Badge
final class StatBadgeView: UIView {
    private let titleLbl = UILabel()
    private let valueLbl = UILabel()

    init(title: String, value: String, accentColor: UIColor = AppTheme.Pigment.nebulaViolet) {
        super.init(frame: .zero)
        backgroundColor = AppTheme.Pigment.obsidianCard
        layer.cornerRadius = AppTheme.Radius.md
        layer.borderWidth = 1
        layer.borderColor = accentColor.withAlphaComponent(0.4).cgColor

        titleLbl.text = title
        titleLbl.font = AppTheme.Typeface.caption(11)
        titleLbl.textColor = AppTheme.Pigment.mistGray
        titleLbl.textAlignment = .center

        valueLbl.text = value
        valueLbl.font = AppTheme.Typeface.mono(20)
        valueLbl.textColor = accentColor
        valueLbl.textAlignment = .center
        valueLbl.adjustsFontSizeToFitWidth = true
        valueLbl.minimumScaleFactor = 0.6

        let stack = UIStackView(arrangedSubviews: [valueLbl, titleLbl])
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func updateValue(_ v: String) { valueLbl.text = v }
}
