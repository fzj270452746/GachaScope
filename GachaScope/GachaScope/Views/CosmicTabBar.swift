import UIKit

final class MainTabBar: UIView {
    enum TabItem: Int, CaseIterable {
        case gacha = 0, slot, analytics, lab, settings

        var title: String {
            switch self {
            case .gacha:     return "Gacha"
            case .slot:      return "Slot"
            case .analytics: return "Analysis"
            case .lab:       return "Lab"
            case .settings:  return "Settings"
            }
        }
        var iconName: String {
            switch self {
            case .gacha:     return "sparkles"
            case .slot:      return "dial.high.fill"
            case .analytics: return "chart.bar.xaxis"
            case .lab:       return "function"
            case .settings:  return "gearshape.fill"
            }
        }
        var accentColor: UIColor {
            switch self {
            case .gacha:     return AppTheme.Pigment.ssrGold
            case .slot:      return AppTheme.Pigment.stellarPink
            case .analytics: return AppTheme.Pigment.prismaticBlue
            case .lab:       return AppTheme.Pigment.auroraGreen
            case .settings:  return AppTheme.Pigment.mistGray
            }
        }
    }

    var onTabSelected: ((TabItem) -> Void)?
    private(set) var selectedTab: TabItem = .gacha
    private var itemViews: [TabItemView] = []
    private let indicatorView = UIView()
    private let blurBg = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialLight))

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        layer.cornerRadius = 28
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true
        layer.borderWidth = 1
        layer.borderColor = AppTheme.Pigment.crystalBorder.cgColor

        blurBg.translatesAutoresizingMaskIntoConstraints = false
        addSubview(blurBg)
        NSLayoutConstraint.activate([
            blurBg.topAnchor.constraint(equalTo: topAnchor),
            blurBg.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurBg.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurBg.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        indicatorView.backgroundColor = AppTheme.Pigment.nebulaViolet.withAlphaComponent(0.12)
        indicatorView.layer.cornerRadius = 20
        addSubview(indicatorView)

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
        ])

        for tab in TabItem.allCases {
            let item = TabItemView(tab: tab)
            item.isSelected = (tab == .gacha)
            let tap = UITapGestureRecognizer(target: self, action: #selector(itemTapped(_:)))
            item.addGestureRecognizer(tap)
            item.tag = tab.rawValue
            stack.addArrangedSubview(item)
            itemViews.append(item)
        }
    }

    @objc private func itemTapped(_ gr: UITapGestureRecognizer) {
        guard let tag = gr.view?.tag, let tab = TabItem(rawValue: tag) else { return }
        selectTab(tab, animated: true)
        Haptics.shared.selectItem()
        onTabSelected?(tab)
    }

    func selectTab(_ tab: TabItem, animated: Bool) {
        selectedTab = tab
        itemViews.forEach { $0.isSelected = ($0.tag == tab.rawValue) }
        guard let targetView = itemViews.first(where: { $0.tag == tab.rawValue }) else { return }
        let targetFrame = targetView.convert(targetView.bounds, to: self)
        let indicatorFrame = CGRect(x: targetFrame.minX + 4, y: targetFrame.minY + 4,
                                    width: targetFrame.width - 8, height: targetFrame.height - 8)
        if animated {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7,
                           initialSpringVelocity: 5, options: []) {
                self.indicatorView.frame = indicatorFrame
            }
        } else {
            indicatorView.frame = indicatorFrame
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        selectTab(selectedTab, animated: false)
    }
}

// MARK: - Tab Item View
private final class TabItemView: UIView {
    private let iconView  = UIImageView()
    private let labelView = UILabel()
    private let tab: MainTabBar.TabItem

    var isSelected: Bool = false {
        didSet { updateAppearance() }
    }

    init(tab: MainTabBar.TabItem) {
        self.tab = tab
        super.init(frame: .zero)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        iconView.image = UIImage(systemName: tab.iconName, withConfiguration: cfg)
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = AppTheme.Pigment.mistGray

        labelView.text = tab.title
        labelView.font = AppTheme.Typeface.caption(10)
        labelView.textColor = AppTheme.Pigment.mistGray
        labelView.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [iconView, labelView])
        stack.axis = .vertical
        stack.spacing = 3
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    private func updateAppearance() {
        let color = isSelected ? tab.accentColor : AppTheme.Pigment.mistGray
        UIView.animate(withDuration: 0.2) {
            self.iconView.tintColor  = color
            self.labelView.textColor = color
            self.iconView.transform  = self.isSelected ? CGAffineTransform(scaleX: 1.15, y: 1.15) : .identity
        }
    }
}
