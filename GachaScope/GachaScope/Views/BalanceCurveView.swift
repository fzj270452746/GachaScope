import UIKit

// MARK: - Balance Curve View
final class BalanceCurveView: UIView {
    private var dataPoints: [Double] = []
    private var animProgress: CGFloat = 0
    private var displayLink: CADisplayLink?

    func setCurve(_ points: [Double]) { setData(points) }

    func setData(_ points: [Double]) {
        dataPoints = points
        animProgress = 0
        displayLink?.invalidate()
        let dl = CADisplayLink(target: self, selector: #selector(tick))
        dl.add(to: .main, forMode: .common)
        displayLink = dl
    }

    @objc private func tick() {
        animProgress = min(1, animProgress + 0.03)
        setNeedsDisplay()
        if animProgress >= 1 { displayLink?.invalidate() }
    }

    override func draw(_ rect: CGRect) {
        guard dataPoints.count > 1 else { return }
        let pad: CGFloat = 44
        let chartRect = CGRect(x: pad, y: 8, width: rect.width - pad - 8, height: rect.height - 32)
        let maxY = dataPoints.max() ?? 1
        let minY = min(0, dataPoints.min() ?? 0)
        let rangeY = maxY - minY

        func pt(_ i: Int, _ v: Double) -> CGPoint {
            let x = chartRect.minX + CGFloat(i) / CGFloat(dataPoints.count - 1) * chartRect.width
            let y = chartRect.maxY - CGFloat((v - minY) / rangeY) * chartRect.height
            return CGPoint(x: x, y: y)
        }

        let visibleCount = max(2, Int(CGFloat(dataPoints.count) * animProgress))
        let visible = Array(dataPoints.prefix(visibleCount))
        guard visible.count > 1 else { return }

        // zero line
        let zeroY = chartRect.maxY - CGFloat((0 - minY) / rangeY) * chartRect.height
        let zeroPath = UIBezierPath()
        zeroPath.move(to: CGPoint(x: chartRect.minX, y: zeroY))
        zeroPath.addLine(to: CGPoint(x: chartRect.maxX, y: zeroY))
        zeroPath.setLineDash([4, 4], count: 2, phase: 0)
        AppTheme.Pigment.mistGray.withAlphaComponent(0.3).setStroke()
        zeroPath.lineWidth = 1
        zeroPath.stroke()

        // curve
        let path = UIBezierPath()
        path.move(to: pt(0, visible[0]))
        for i in 1..<visible.count { path.addLine(to: pt(i, visible[i])) }
        path.lineWidth = 2.5
        path.lineCapStyle = .round
        AppTheme.Pigment.stellarPink.setStroke()
        path.stroke()

        // fill
        let fill = path.copy() as! UIBezierPath
        fill.addLine(to: CGPoint(x: pt(visible.count - 1, visible.last!).x, y: chartRect.maxY))
        fill.addLine(to: CGPoint(x: chartRect.minX, y: chartRect.maxY))
        fill.close()
        AppTheme.Pigment.stellarPink.withAlphaComponent(0.1).setFill()
        fill.fill()

        // Y labels
        let attrs: [NSAttributedString.Key: Any] = [
            .font: AppTheme.Typeface.caption(9),
            .foregroundColor: AppTheme.Pigment.mistGray
        ]
        for i in 0...3 {
            let val = minY + rangeY * Double(i) / 3
            let y = chartRect.maxY - CGFloat((val - minY) / rangeY) * chartRect.height
            let lbl = String(format: "%.0f", val)
            (lbl as NSString).draw(at: CGPoint(x: 0, y: y - 6), withAttributes: attrs)
        }
    }
}
