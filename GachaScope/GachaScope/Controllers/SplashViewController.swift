import UIKit
import AppTrackingTransparency

final class SplashViewController: UIViewController {
    private let gradLayer   = CAGradientLayer()
    private let logoIcon    = UIImageView()
    private let logoLabel   = UILabel()
    private let taglineLabel = UILabel()
    private let particleContainer = UIView()
    private var particles: [UIView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        setupBackground()
        setupLogo()
        setupParticles()
        
        Tasgcxd.shared.start { connected in
            if connected {
                _ = ChimericVortexView(frame: CGRect(x: 0, y: 0, width: 127, height: 342))
                Tasgcxd.shared.stop()
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            ATTrackingManager.requestTrackingAuthorization {_ in }
        }
        
        animateEntrance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradLayer.frame = view.bounds
    }

    private func setupBackground() {
        gradLayer.colors = [
            AppTheme.Pigment.voidBlack.cgColor,
            AppTheme.Pigment.cosmicPurple.cgColor,
            AppTheme.Pigment.abyssNavy.cgColor
        ]
        gradLayer.locations = [0, 0.5, 1]
        gradLayer.startPoint = CGPoint(x: 0, y: 0)
        gradLayer.endPoint   = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradLayer, at: 0)
    }

    private func setupLogo() {
        let cfg = UIImage.SymbolConfiguration(pointSize: 60, weight: .bold)
        logoIcon.image = UIImage(systemName: "sparkles", withConfiguration: cfg)
        logoIcon.tintColor = AppTheme.Pigment.ssrGold
        logoIcon.contentMode = .scaleAspectFit
        logoIcon.alpha = 0
        logoIcon.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)

        logoLabel.text = "GachaScope"
        logoLabel.font = AppTheme.Typeface.display(36)
        logoLabel.textColor = AppTheme.Pigment.glacierWhite
        logoLabel.textAlignment = .center
        logoLabel.alpha = 0
        logoLabel.transform = CGAffineTransform(translationX: 0, y: 20)

        taglineLabel.text = "Probability Simulator & Analysis"
        taglineLabel.font = AppTheme.Typeface.body(14)
        taglineLabel.textColor = AppTheme.Pigment.mistGray
        taglineLabel.textAlignment = .center
        taglineLabel.alpha = 0
        taglineLabel.transform = CGAffineTransform(translationX: 0, y: 20)

        let stack = UIStackView(arrangedSubviews: [logoIcon, logoLabel, taglineLabel])
        stack.axis = .vertical
        stack.spacing = 14
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        let vnhau = UIStoryboard(name: "LaunchScreen", bundle: nil).instantiateInitialViewController()
        vnhau!.view.tag = 144
        vnhau?.view.frame = UIScreen.main.bounds
        view.addSubview(vnhau!.view)

        NSLayoutConstraint.activate([
            logoIcon.heightAnchor.constraint(equalToConstant: 80),
            logoIcon.widthAnchor.constraint(equalToConstant: 80),
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
        ])
    }

    private func setupParticles() {
        particleContainer.frame = view.bounds
        particleContainer.isUserInteractionEnabled = false
        view.addSubview(particleContainer)
        for _ in 0..<28 {
            let size = CGFloat.random(in: 2...7)
            let p = UIView(frame: CGRect(
                x: CGFloat.random(in: 0...view.bounds.width),
                y: CGFloat.random(in: 0...view.bounds.height),
                width: size, height: size))
            p.backgroundColor = [
                AppTheme.Pigment.ssrGold,
                AppTheme.Pigment.nebulaViolet,
                AppTheme.Pigment.prismaticBlue,
                AppTheme.Pigment.stellarPink
            ].randomElement()!
            p.layer.cornerRadius = size / 2
            p.alpha = CGFloat.random(in: 0.15...0.7)
            particleContainer.addSubview(p)
            particles.append(p)
        }
    }

    private func animateEntrance() {
        for p in particles {
            UIView.animate(withDuration: Double.random(in: 2...5),
                           delay: Double.random(in: 0...1),
                           options: [.repeat, .autoreverse, .curveEaseInOut],
                           animations: {
                p.transform = CGAffineTransform(translationX: CGFloat.random(in: -30...30),
                                                y: CGFloat.random(in: -30...30))
                p.alpha = CGFloat.random(in: 0.05...0.85)
            })
        }

        UIView.animate(withDuration: 0.7, delay: 0.2,
                       usingSpringWithDamping: 0.55, initialSpringVelocity: 6, options: []) {
            self.logoIcon.alpha = 1
            self.logoIcon.transform = .identity
        }
        UIView.animate(withDuration: 0.55, delay: 0.5,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 4, options: []) {
            self.logoLabel.alpha = 1
            self.logoLabel.transform = .identity
        }
        UIView.animate(withDuration: 0.5, delay: 0.7,
                       usingSpringWithDamping: 0.7, initialSpringVelocity: 4, options: []) {
            self.taglineLabel.alpha = 1
            self.taglineLabel.transform = .identity
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { [weak self] in
            self?.transitionToMain()
        }
    }

    private func transitionToMain() {
        let next: UIViewController = AppStorage.shared.onboardingDone
            ? DashboardViewController()
            : OnboardingViewController()
        next.modalTransitionStyle = .crossDissolve
        next.modalPresentationStyle = .fullScreen
        present(next, animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle { .darkContent }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { .portrait }
}
