import UIKit

// MARK: - Symbol Frequency Chart (horizontal bars)
final class SymbolFrequencyChartView: UIView {
    struct SymEntry {
        let identifier: String
        let emoji: String
        let name: String
        let hits: Int
        let weight: Int
        let color: UIColor
    }

    private var entries: [SymEntry] = []
    private var totalHits: Int = 1
    private var animProgress: CGFloat = 0
    private var displayLink: CADisplayLink?

    func setEntries(_ e: [SymEntry], total: Int) {
        entries = e
        totalHits = max(1, total)
        animProgress = 0
        displayLink?.invalidate()
        let dl = CADisplayLink(target: self, selector: #selector(tick))
        dl.add(to: .main, forMode: .common)
        displayLink = dl
    }

    @objc private func tick() {
        animProgress = min(1, animProgress + 0.04)
        setNeedsDisplay()
        if animProgress >= 1 { displayLink?.invalidate() }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: CGFloat(max(1, entries.count)) * 32)
    }

    override func draw(_ rect: CGRect) {
        guard !entries.isEmpty else { return }
        let rowH: CGFloat = rect.height / CGFloat(entries.count)
        let labelW: CGFloat = 108
        let countW: CGFloat = 50    // hit count
        let barArea = rect.width - labelW - countW - 8
        let maxHits = entries.map { $0.hits }.max() ?? 1

        let valueAttrs: [NSAttributedString.Key: Any] = [
            .font: AppTheme.Typeface.mono(10),
            .foregroundColor: AppTheme.Pigment.glacierWhite
        ]

        for (i, entry) in entries.enumerated() {
            let y = CGFloat(i) * rowH
            let barY = y + rowH * 0.25
            let barH = rowH * 0.5

            if let image = ReelSymbolArtwork.image(for: entry.identifier, pointSize: 11, weight: .semibold) {
                entry.color.set()
                image.draw(in: CGRect(x: 0, y: y + (rowH - 12) / 2, width: 12, height: 12))
            }
            let label = "\(ReelSymbolArtwork.style(for: entry.identifier).shortLabel) \(entry.name)"
            (label as NSString).draw(
                in: CGRect(x: 18, y: y + (rowH - 14) / 2, width: labelW - 22, height: 14),
                withAttributes: [
                    .font: AppTheme.Typeface.caption(11),
                    .foregroundColor: AppTheme.Pigment.mistGray
                ])

            // bar
            let ratio = maxHits > 0 ? CGFloat(entry.hits) / CGFloat(maxHits) * animProgress : 0
            let barW = barArea * ratio
            if barW > 0 {
                let path = UIBezierPath(roundedRect: CGRect(x: labelW, y: barY, width: barW, height: barH),
                                        cornerRadius: 3)
                entry.color.withAlphaComponent(0.85).setFill()
                path.fill()
                // glow
                let ctx = UIGraphicsGetCurrentContext()
                ctx?.setShadow(offset: .zero, blur: 6, color: entry.color.withAlphaComponent(0.4).cgColor)
                path.fill()
                ctx?.setShadow(offset: .zero, blur: 0, color: nil)
            }

            // count + pct
            let pct = totalHits > 0 ? Double(entry.hits) / Double(totalHits) * 100 : 0
            let countStr = entry.hits > 0
                ? String(format: "%d\n%.1f%%", entry.hits, pct)
                : "0"
            (countStr as NSString).draw(
                in: CGRect(x: labelW + barArea + 4, y: y + 2, width: countW, height: rowH - 4),
                withAttributes: valueAttrs)
        }
    }
}

// MARK: - Distribution Bar Chart
final class DistributionChartView: UIView {
    struct BarEntry {
        let label: String
        let value: Double
        let color: UIColor
    }

    private var entries: [BarEntry] = []
    private var animationProgress: CGFloat = 0
    private var displayLink: CADisplayLink?

    func setEntries(_ e: [BarEntry]) {
        entries = e
        animationProgress = 0
        setNeedsDisplay()
        displayLink?.invalidate()
        let dl = CADisplayLink(target: self, selector: #selector(tick))
        dl.add(to: .main, forMode: .common)
        displayLink = dl
    }

    private func animateIn() {}

    @objc private func tick() {
        animationProgress = min(1, animationProgress + 0.04)
        setNeedsDisplay()
        if animationProgress >= 1 { displayLink?.invalidate() }
    }

    override func draw(_ rect: CGRect) {
        guard !entries.isEmpty else { return }
        let maxVal = entries.map { $0.value }.max() ?? 1
        let barW = (rect.width - CGFloat(entries.count + 1) * 12) / CGFloat(entries.count)
        let labelH: CGFloat = 36
        let chartH = rect.height - labelH

        for (i, entry) in entries.enumerated() {
            let x = 12 + CGFloat(i) * (barW + 12)
            let fillRatio = maxVal > 0 ? CGFloat(entry.value / maxVal) * animationProgress : 0
            let barH = chartH * fillRatio
            let barY = chartH - barH

            let path = UIBezierPath(roundedRect: CGRect(x: x, y: barY, width: barW, height: barH),
                                    byRoundingCorners: [.topLeft, .topRight],
                                    cornerRadii: CGSize(width: 6, height: 6))
            entry.color.withAlphaComponent(0.85).setFill()
            path.fill()

            // glow
            let ctx = UIGraphicsGetCurrentContext()
            ctx?.setShadow(offset: .zero, blur: 8, color: entry.color.withAlphaComponent(0.5).cgColor)
            entry.color.setFill()
            path.fill()
            ctx?.setShadow(offset: .zero, blur: 0, color: nil)

            // label
            let pct = String(format: "%.1f%%", entry.value * 100)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: AppTheme.Typeface.caption(10),
                .foregroundColor: AppTheme.Pigment.mistGray
            ]
            let str = NSAttributedString(string: "\(entry.label)\n\(pct)", attributes: attrs)
            let strSize = str.boundingRect(with: CGSize(width: barW, height: labelH),
                                           options: .usesLineFragmentOrigin, context: nil)
            str.draw(in: CGRect(x: x, y: chartH + 4,
                                width: barW, height: strSize.height))
        }
    }
}

// MARK: - Convergence Wave Chart
final class ConvergenceWaveView: UIView {
    private var dataPoints: [(Int, Double)] = []
    private var theoreticalRate: Double = 0.01
    private var animProgress: CGFloat = 0
    private var displayLink: CADisplayLink?

    func setData(points: [(Int, Double)], theoretical: Double) {
        dataPoints = points
        theoreticalRate = theoretical
        animProgress = 0
        displayLink?.invalidate()
        let dl = CADisplayLink(target: self, selector: #selector(animTick))
        dl.add(to: .main, forMode: .common)
        displayLink = dl
    }

    @objc private func animTick() {
        animProgress = min(1, animProgress + 0.03)
        setNeedsDisplay()
        if animProgress >= 1 { displayLink?.invalidate() }
    }

    override func draw(_ rect: CGRect) {
        guard dataPoints.count > 1 else { return }
        let pad: CGFloat = 40
        let chartRect = CGRect(x: pad, y: 8, width: rect.width - pad - 8, height: rect.height - 32)
        let maxX = CGFloat(dataPoints.last?.0 ?? 1)
        let maxY = max(theoreticalRate * 3, dataPoints.map { $0.1 }.max() ?? 0.1)

        func pt(_ d: (Int, Double)) -> CGPoint {
            CGPoint(x: chartRect.minX + CGFloat(d.0) / maxX * chartRect.width,
                    y: chartRect.maxY - CGFloat(d.1) / maxY * chartRect.height)
        }

        // theoretical line
        let thY = chartRect.maxY - CGFloat(theoreticalRate) / maxY * chartRect.height
        let dashPath = UIBezierPath()
        dashPath.move(to: CGPoint(x: chartRect.minX, y: thY))
        dashPath.addLine(to: CGPoint(x: chartRect.maxX, y: thY))
        dashPath.setLineDash([6, 4], count: 2, phase: 0)
        AppTheme.Pigment.solarGold.withAlphaComponent(0.6).setStroke()
        dashPath.lineWidth = 1.5
        dashPath.stroke()

        // actual curve
        let visibleCount = max(2, Int(CGFloat(dataPoints.count) * animProgress))
        let visible = Array(dataPoints.prefix(visibleCount))
        guard visible.count > 1 else { return }

        let path = UIBezierPath()
        path.move(to: pt(visible[0]))
        for d in visible.dropFirst() { path.addLine(to: pt(d)) }
        path.lineWidth = 2.5
        path.lineCapStyle = .round
        AppTheme.Pigment.prismaticBlue.setStroke()
        path.stroke()

        // fill under
        let fill = path.copy() as! UIBezierPath
        fill.addLine(to: CGPoint(x: pt(visible.last!).x, y: chartRect.maxY))
        fill.addLine(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
        fill.close()
        AppTheme.Pigment.prismaticBlue.withAlphaComponent(0.12).setFill()
        fill.fill()

        // Y axis labels
        let attrs: [NSAttributedString.Key: Any] = [
            .font: AppTheme.Typeface.caption(9),
            .foregroundColor: AppTheme.Pigment.mistGray
        ]
        for i in 0...3 {
            let val = maxY * Double(i) / 3
            let y = chartRect.maxY - CGFloat(val) / maxY * chartRect.height
            let lbl = String(format: "%.1f%%", val * 100)
            (lbl as NSString).draw(at: CGPoint(x: 0, y: y - 6), withAttributes: attrs)
        }
    }
}

// MARK: - CDF Cumulative Probability Chart
final class CDFChartView: UIView {
    private var cdfPoints: [Double] = []   // index = pull count, value = cumulative prob
    private var p50idx: Int = 0
    private var p90idx: Int = 0
    private var p99idx: Int = 0
    private var animProgress: CGFloat = 0
    private var displayLink: CADisplayLink?

    /// Pass in array where cdfPoints[i] = probability of getting SSR within i+1 pulls
    func setData(_ points: [Double]) {
        cdfPoints = points
        p50idx = points.firstIndex(where: { $0 >= 0.50 }) ?? 0
        p90idx = points.firstIndex(where: { $0 >= 0.90 }) ?? 0
        p99idx = points.firstIndex(where: { $0 >= 0.99 }) ?? 0
        animProgress = 0
        displayLink?.invalidate()
        let dl = CADisplayLink(target: self, selector: #selector(animTick))
        dl.add(to: .main, forMode: .common)
        displayLink = dl
    }

    @objc private func animTick() {
        animProgress = min(1, animProgress + 0.025)
        setNeedsDisplay()
        if animProgress >= 1 { displayLink?.invalidate() }
    }

    override func draw(_ rect: CGRect) {
        guard cdfPoints.count > 1 else { return }
        let padL: CGFloat = 44, padB: CGFloat = 24, padT: CGFloat = 8, padR: CGFloat = 8
        let chartRect = CGRect(x: padL, y: padT,
                               width: rect.width - padL - padR,
                               height: rect.height - padT - padB)

        let visibleCount = max(2, Int(CGFloat(cdfPoints.count) * animProgress))
        let visible = Array(cdfPoints.prefix(visibleCount))

        func pt(_ i: Int) -> CGPoint {
            CGPoint(
                x: chartRect.minX + CGFloat(i) / CGFloat(cdfPoints.count - 1) * chartRect.width,
                y: chartRect.maxY - CGFloat(visible[i]) * chartRect.height
            )
        }

        // fill under curve
        if visible.count > 1 {
            let fill = UIBezierPath()
            fill.move(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
            for i in 0..<visible.count { fill.addLine(to: pt(i)) }
            fill.addLine(to: CGPoint(x: pt(visible.count - 1).x, y: chartRect.maxY))
            fill.close()
            AppTheme.Pigment.nebulaViolet.withAlphaComponent(0.15).setFill()
            fill.fill()
        }

        // curve
        if visible.count > 1 {
            let path = UIBezierPath()
            path.move(to: pt(0))
            for i in 1..<visible.count { path.addLine(to: pt(i)) }
            path.lineWidth = 2.5
            path.lineCapStyle = .round
            AppTheme.Pigment.nebulaViolet.setStroke()
            path.stroke()
        }

        // percentile markers (only after animation reaches that point)
        let pctMarkers: [(Int, UIColor, String)] = [
            (p50idx, AppTheme.Pigment.auroraGreen,  "P50"),
            (p90idx, AppTheme.Pigment.ssrGold,      "P90"),
            (p99idx, AppTheme.Pigment.novaRed,       "P99"),
        ]
        let attrs: [NSAttributedString.Key: Any] = [
            .font: AppTheme.Typeface.caption(9),
        ]
        for (idx, color, label) in pctMarkers {
            guard idx > 0, idx < cdfPoints.count,
                  Double(visibleCount) / Double(cdfPoints.count) > Double(idx) / Double(cdfPoints.count)
            else { continue }
            let x = chartRect.minX + CGFloat(idx) / CGFloat(cdfPoints.count - 1) * chartRect.width
            let vLine = UIBezierPath()
            vLine.move(to: CGPoint(x: x, y: chartRect.minY))
            vLine.addLine(to: CGPoint(x: x, y: chartRect.maxY))
            vLine.setLineDash([3, 3], count: 2, phase: 0)
            vLine.lineWidth = 1
            color.withAlphaComponent(0.7).setStroke()
            vLine.stroke()
            let lblStr = NSAttributedString(string: "\(label):\(idx+1)", attributes: attrs.merging([.foregroundColor: color]) { $1 })
            lblStr.draw(at: CGPoint(x: max(chartRect.minX, x - 14), y: chartRect.minY + 2))
        }

        // Y axis
        let yAttrs: [NSAttributedString.Key: Any] = [
            .font: AppTheme.Typeface.caption(9),
            .foregroundColor: AppTheme.Pigment.mistGray
        ]
        for pct in [0.25, 0.50, 0.75, 1.0] {
            let y = chartRect.maxY - CGFloat(pct) * chartRect.height
            let lbl = String(format: "%.0f%%", pct * 100)
            (lbl as NSString).draw(at: CGPoint(x: 0, y: y - 6), withAttributes: yAttrs)
        }
    }
}

// MARK: - Streak Flame View
final class StreakFlameView: UIView {
    private var streakData: [Int] = []
    private var animProgress: CGFloat = 0
    private var displayLink: CADisplayLink?

    func setStreaks(_ data: [Int]) {
        streakData = data
        animProgress = 0
        displayLink?.invalidate()
        let dl = CADisplayLink(target: self, selector: #selector(animTick))
        dl.add(to: .main, forMode: .common)
        displayLink = dl
    }

    @objc private func animTick() {
        animProgress = min(1, animProgress + 0.03)
        setNeedsDisplay()
        if animProgress >= 1 { displayLink?.invalidate() }
    }

    override func draw(_ rect: CGRect) {
        guard !streakData.isEmpty else { return }
        let pad: CGFloat = 8
        let maxVal = CGFloat(streakData.max() ?? 1)
        let barW = max(4, (rect.width - pad * 2) / CGFloat(streakData.count) - 2)

        for (i, val) in streakData.enumerated() {
            let x = pad + CGFloat(i) * (barW + 2)
            let ratio = CGFloat(val) / maxVal * animProgress
            let barH = (rect.height - 20) * ratio
            let barY = rect.height - 20 - barH
            let intensity = CGFloat(val) / maxVal
            let color = UIColor(
                red: 0.9 * intensity + 0.2,
                green: 0.3 * (1 - intensity),
                blue: 0.1,
                alpha: 0.85
            )
            let path = UIBezierPath(roundedRect: CGRect(x: x, y: barY, width: barW, height: barH),
                                    cornerRadius: 3)
            color.setFill()
            path.fill()
        }
    }
}
