import SwiftUI

// MARK: - Task Completion Celebration
// Subtle checkmark burst animation — Things 3 level of polish, not obnoxious.
// Respects Reduce Motion with a simple crossfade fallback.

public struct CompletionCelebration: View {
    @Binding var isShowing: Bool

    @State private var particles: [Particle] = []
    @State private var checkScale: CGFloat = 0
    @State private var checkOpacity: CGFloat = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public init(isShowing: Binding<Bool>) {
        self._isShowing = isShowing
    }

    public var body: some View {
        if isShowing {
            ZStack {
                // Particles
                if !reduceMotion {
                    ForEach(particles) { particle in
                        Circle()
                            .fill(particle.color)
                            .frame(width: particle.size, height: particle.size)
                            .offset(particle.offset)
                            .opacity(particle.opacity)
                    }
                }

                // Central checkmark
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(FlowColors.success)
                    .scaleEffect(checkScale)
                    .opacity(checkOpacity)
            }
            .onAppear { animate() }
        }
    }

    private func animate() {
        guard !reduceMotion else {
            // Reduced motion: simple fade in/out
            withAnimation(.easeIn(duration: 0.2)) {
                checkScale = 1.0
                checkOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.6)) {
                checkOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                isShowing = false
            }
            return
        }

        // Generate particles
        particles = (0..<8).map { i in
            let angle = Double(i) * (360.0 / 8.0) * .pi / 180
            return Particle(
                id: i,
                color: [FlowColors.accentFallback, FlowColors.success, FlowColors.warning].randomElement()!,
                size: CGFloat.random(in: 3...6),
                finalOffset: CGSize(
                    width: cos(angle) * CGFloat.random(in: 20...35),
                    height: sin(angle) * CGFloat.random(in: 20...35)
                )
            )
        }

        // Checkmark pop
        withAnimation(FlowAnimation.bouncy) {
            checkScale = 1.0
            checkOpacity = 1.0
        }

        // Particles burst
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
            for i in particles.indices {
                particles[i].offset = particles[i].finalOffset
                particles[i].opacity = 1.0
            }
        }

        // Fade out
        withAnimation(.easeOut(duration: 0.3).delay(0.5)) {
            for i in particles.indices {
                particles[i].opacity = 0
            }
            checkOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            isShowing = false
        }
    }
}

private struct Particle: Identifiable {
    let id: Int
    let color: Color
    let size: CGFloat
    let finalOffset: CGSize
    var offset: CGSize = .zero
    var opacity: CGFloat = 0
}

#Preview("Completion Celebration") {
    struct PreviewWrapper: View {
        @State private var showCelebration = false
        var body: some View {
            VStack {
                Button("Celebrate!") { showCelebration = true }
                ZStack {
                    CompletionCelebration(isShowing: $showCelebration)
                }
                .frame(width: 100, height: 100)
            }
        }
    }
    return PreviewWrapper()
}
