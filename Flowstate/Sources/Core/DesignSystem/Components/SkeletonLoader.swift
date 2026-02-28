import SwiftUI

// MARK: - Skeleton Loader
// Shimmering placeholder for loading states. Never use spinners.

public struct SkeletonShape: View {
    let width: CGFloat?
    let height: CGFloat

    @State private var shimmerOffset: CGFloat = -1.0

    public init(width: CGFloat? = nil, height: CGFloat = 16) {
        self.width = width
        self.height = height
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: FlowRadius.xs)
            .fill(FlowColors.tertiaryBackground)
            .frame(width: width, height: height)
            .overlay {
                GeometryReader { geo in
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.3), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.6)
                    .offset(x: shimmerOffset * geo.size.width)
                }
                .clipped()
            }
            .clipShape(RoundedRectangle(cornerRadius: FlowRadius.xs))
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    shimmerOffset = 1.5
                }
            }
            .accessibilityLabel("Loading")
    }
}

// MARK: - Skeleton Task Row

public struct SkeletonTaskRow: View {
    public init() {}

    public var body: some View {
        HStack(spacing: FlowSpacing.xs) {
            // Checkbox placeholder
            Circle()
                .fill(FlowColors.tertiaryBackground)
                .frame(width: FlowSize.checkbox, height: FlowSize.checkbox)

            VStack(alignment: .leading, spacing: FlowSpacing.xs) {
                SkeletonShape(height: 14)
                SkeletonShape(width: 140, height: 10)
            }
        }
        .padding(.vertical, FlowSpacing.xs)
        .padding(.horizontal, FlowSpacing.md)
        .frame(minHeight: FlowSize.taskRowMinHeight)
    }
}

// MARK: - Skeleton List

public struct SkeletonTaskList: View {
    let count: Int

    public init(count: Int = 5) {
        self.count = count
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<count, id: \.self) { index in
                SkeletonTaskRow()
                    .opacity(1.0 - Double(index) * 0.15)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Loading tasks")
    }
}

#Preview("Skeleton Loaders") {
    VStack(spacing: 24) {
        SkeletonShape(width: 200, height: 20)
        SkeletonShape(height: 14)
        Divider()
        SkeletonTaskList(count: 4)
    }
    .padding()
}
