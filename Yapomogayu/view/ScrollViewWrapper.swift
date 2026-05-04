import SwiftUI
import UIKit
import QuartzCore

struct ScrollViewDecelerationModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ScrollViewFinder()
            )
    }
}

class SmoothScrollDelegate: NSObject, UIScrollViewDelegate {
    private var shouldAnimateManually = false
    private var manualTargetOffset: CGFloat = 0
    private var manualStartOffset: CGFloat = 0
    private var animationStartTime: CFTimeInterval = 0
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let pageHeight = scrollView.bounds.height
        guard pageHeight > 0 else { return }
        
        let targetY = targetContentOffset.pointee.y
        let currentPage = Int(round(targetY / pageHeight))
        let targetOffset = CGFloat(currentPage) * pageHeight
        
        // For short swipes (high velocity), cancel system animation and use custom smooth animation
        // This makes short swipes behave exactly like long swipes
        if abs(velocity.y) > 1.5 {
            // Short/fast swipe - cancel system deceleration and animate manually with fixed duration
            manualStartOffset = scrollView.contentOffset.y
            manualTargetOffset = targetOffset
            shouldAnimateManually = true
            
            // Set target to current position to cancel system animation
            targetContentOffset.pointee.y = scrollView.contentOffset.y
            
            // Start custom smooth animation (same duration as long swipes would naturally have)
            animationStartTime = CACurrentMediaTime()
            animateToTarget(scrollView: scrollView)
        } else {
            // Long/slow swipe - normal behavior (works fine)
            targetContentOffset.pointee.y = targetOffset
            shouldAnimateManually = false
        }
        
        // Always use normal deceleration rate
        scrollView.decelerationRate = .normal
    }
    
    private func animateToTarget(scrollView: UIScrollView) {
        guard shouldAnimateManually else { return }
        
        let currentTime = CACurrentMediaTime()
        let elapsed = currentTime - animationStartTime
        let duration: CFTimeInterval = 0.35 // Same smooth duration as long swipes
        
        if elapsed < duration {
            // Ease out curve (similar to natural deceleration)
            let progress = CGFloat(elapsed / duration)
            let easedProgress = 1 - pow(1 - progress, 3) // Cubic ease out
            
            let currentOffset = manualStartOffset + (manualTargetOffset - manualStartOffset) * easedProgress
            scrollView.setContentOffset(CGPoint(x: 0, y: currentOffset), animated: false)
            
            // Continue animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) { // ~60fps
                self.animateToTarget(scrollView: scrollView)
            }
        } else {
            // Animation complete
            scrollView.setContentOffset(CGPoint(x: 0, y: manualTargetOffset), animated: false)
            shouldAnimateManually = false
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        shouldAnimateManually = false
    }
}

struct ScrollViewFinder: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = false
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // Find parent UIScrollView and adjust settings
        DispatchQueue.main.async {
            var parent = uiView.superview
            var attempts = 0
            let maxAttempts = 10
            
            func findScrollView() {
                while parent != nil && attempts < maxAttempts {
                    if let scrollView = parent as? UIScrollView {
                        // Use normal deceleration (same as long swipes that work fine)
                        scrollView.decelerationRate = .normal
                        // Set delegate to control scroll animation for all swipes
                        // Create new delegate instance if needed
                        if scrollView.delegate == nil || !(scrollView.delegate is SmoothScrollDelegate) {
                            scrollView.delegate = SmoothScrollDelegate()
                        }
                        return
                    }
                    parent = parent?.superview
                    attempts += 1
                }
                
                // Retry if not found
                if attempts < maxAttempts {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        findScrollView()
                    }
                }
            }
            
            findScrollView()
        }
    }
}

extension View {
    func adjustScrollDeceleration() -> some View {
        modifier(ScrollViewDecelerationModifier())
    }
}

