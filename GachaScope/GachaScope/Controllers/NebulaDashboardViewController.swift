import UIKit

final class DashboardViewController: UIViewController {
    private let tabBar = MainTabBar()
    private let containerView = UIView()
    private var currentVC: UIViewController?

    private lazy var gachaVC: GachaViewController = {
        let vc = GachaViewController()
        vc.onGachaResult = { [weak self] result in
            self?.analyticsVC.loadGachaResult(result)
        }
        return vc
    }()
    private lazy var slotVC: SlotsViewController = {
        let vc = SlotsViewController()
        vc.onSlotResult = { [weak self] result in
            self?.analyticsVC.loadSlotResult(result)
        }
        return vc
    }()
    private lazy var analyticsVC = AnalyticsViewController()
    private lazy var labVC       = ProbabilityViewController()
    private lazy var settingsVC  = SettingsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.Pigment.voidBlack
        setupBackground()
        setupLayout()
        switchTo(.gacha)
        Haptics.shared.primeAll()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }

    private func setupBackground() {
        let grad = CAGradientLayer()
        grad.colors = [AppTheme.Pigment.voidBlack.cgColor,
                       AppTheme.Pigment.cosmicPurple.withAlphaComponent(0.3).cgColor,
                       AppTheme.Pigment.abyssNavy.cgColor]
        grad.locations = [0, 0.5, 1]
        grad.frame = view.bounds
        view.layer.insertSublayer(grad, at: 0)
    }

    private func setupLayout() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        view.addSubview(tabBar)

        let tabBarHeight: CGFloat = 72

        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -tabBarHeight),

            containerView.topAnchor.constraint(equalTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: tabBar.topAnchor),
        ])

        tabBar.onTabSelected = { [weak self] tab in
            self?.switchTo(tab)
        }
    }

    private func switchTo(_ tab: MainTabBar.TabItem) {
        let target: UIViewController
        switch tab {
        case .gacha:     target = gachaVC
        case .slot:      target = slotVC
        case .analytics: target = analyticsVC
        case .lab:       target = labVC
        case .settings:  target = settingsVC
        }
        guard target !== currentVC else { return }

        currentVC?.willMove(toParent: nil)
        currentVC?.view.removeFromSuperview()
        currentVC?.removeFromParent()

        addChild(target)
        target.view.frame = containerView.bounds
        target.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(target.view)
        target.didMove(toParent: self)

        target.view.alpha = 0
        target.view.transform = CGAffineTransform(translationX: 0, y: 12)
        UIView.animate(withDuration: 0.28, delay: 0, options: .curveEaseOut) {
            target.view.alpha = 1
            target.view.transform = .identity
        }
        currentVC = target
        tabBar.selectTab(tab, animated: true)
    }
}
