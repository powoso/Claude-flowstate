import SwiftUI

// MARK: - Tag Chip
// Color-coded tag pill used across task rows and filters.

public enum TagChipStyle {
    case standard   // Full size with background
    case compact    // Smaller, inline in task rows
    case filter     // Toggleable filter chip
}

public struct TagChip: View {
    let label: String
    let color: Color
    let style: TagChipStyle
    var isSelected: Bool
    var onTap: (() -> Void)?

    public init(
        label: String,
        color: Color = FlowColors.accentFallback,
        style: TagChipStyle = .standard,
        isSelected: Bool = false,
        onTap: (() -> Void)? = nil
    ) {
        self.label = label
        self.color = color
        self.style = style
        self.isSelected = isSelected
        self.onTap = onTap
    }

    public var body: some View {
        Group {
            if let onTap {
                Button(action: onTap) { chipContent }
                    .buttonStyle(.plain)
            } else {
                chipContent
            }
        }
        .accessibilityLabel("Tag: \(label)")
        .accessibilityAddTraits(onTap != nil ? .isButton : [])
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private var chipContent: some View {
        switch style {
        case .standard:
            standardChip
        case .compact:
            compactChip
        case .filter:
            filterChip
        }
    }

    private var standardChip: some View {
        HStack(spacing: FlowSpacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 6, height: 6)
            Text(label)
                .font(FlowTypography.caption)
                .foregroundStyle(FlowColors.textPrimary)
        }
        .padding(.horizontal, FlowSpacing.xs)
        .padding(.vertical, FlowSpacing.xxs)
        .background(color.opacity(0.12), in: Capsule())
    }

    private var compactChip: some View {
        Text("#\(label)")
            .font(FlowTypography.caption)
            .foregroundStyle(color)
    }

    private var filterChip: some View {
        HStack(spacing: FlowSpacing.xxs) {
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
            }
            Text(label)
                .font(FlowTypography.subheadline)
        }
        .padding(.horizontal, FlowSpacing.sm)
        .padding(.vertical, FlowSpacing.xs)
        .foregroundStyle(isSelected ? .white : FlowColors.textPrimary)
        .background(
            isSelected ? AnyShapeStyle(color) : AnyShapeStyle(FlowColors.tertiaryBackground),
            in: Capsule()
        )
    }
}

#Preview("Tag Chips") {
    VStack(spacing: 16) {
        HStack {
            TagChip(label: "work")
            TagChip(label: "personal", color: .green)
            TagChip(label: "design", color: .purple)
        }

        HStack {
            TagChip(label: "work", style: .compact)
            TagChip(label: "urgent", color: .red, style: .compact)
        }

        HStack {
            TagChip(label: "All", style: .filter, isSelected: true) {}
            TagChip(label: "Work", style: .filter) {}
            TagChip(label: "Personal", style: .filter) {}
        }
    }
    .padding()
}
