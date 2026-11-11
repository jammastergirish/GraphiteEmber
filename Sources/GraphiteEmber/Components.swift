import SwiftUI

// MARK: - Status badge (READY / RECORDING)

public struct StatusBadge: View {
    var text: String
    var color: Color
    var tint: Color

    public init(text: String, color: Color = Theme.emberText, tint: Color = Theme.emberTint) {
        self.text = text
        self.color = color
        self.tint = tint
    }

    public var body: some View {
        Text(text.uppercased())
            .font(.mono(10, weight: .semibold))
            .tracking(0.5)
            .foregroundStyle(color)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(tint, in: RoundedRectangle(cornerRadius: 4))
    }
}

// MARK: - Logo squircle

/// Near-black rounded square with an app's mark drawn on top. `mark` gets the
/// squircle's side length so the mark can scale with it.
public struct LogoSquircle<Mark: View>: View {
    var side: CGFloat
    var mark: (CGFloat) -> Mark

    public init(side: CGFloat = 24, @ViewBuilder mark: @escaping (CGFloat) -> Mark) {
        self.side = side
        self.mark = mark
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: side * 0.23, style: .continuous)
            .fill(Theme.squircleBG)
            .frame(width: side, height: side)
            .overlay(mark(side))
    }
}

// MARK: - Ember spinner

public struct EmberSpinner: View {
    var size: CGFloat
    @State private var angle: Double = 0

    public init(size: CGFloat = 14) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            Circle().stroke(Theme.ember.opacity(0.35), lineWidth: 2)
            Circle().trim(from: 0, to: 0.3)
                .stroke(Theme.ember, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(angle))
        }
        .frame(width: size, height: size)
        .onAppear {
            withAnimation(.linear(duration: 0.85).repeatForever(autoreverses: false)) { angle = 360 }
        }
    }
}

// MARK: - Ghost/bordered button style ("Settings…", "Quit")

public struct GraphiteButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13))
            .foregroundStyle(Theme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(Theme.buttonBG, in: RoundedRectangle(cornerRadius: 7))
            .overlay(RoundedRectangle(cornerRadius: 7).stroke(Theme.fieldBorder, lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 1, y: 1)
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Main-window title bar

/// App name in mono capitals with the status badge on the right, sized to sit
/// just below the traffic lights of a `.hiddenTitleBar` window.
public struct WindowTitleBar: View {
    var title: String
    var badge: String

    public init(title: String, badge: String) {
        self.title = title
        self.badge = badge
    }

    public var body: some View {
        HStack(spacing: 10) {
            MonoLabel(text: title, size: 12, tracking: 0.8, color: Theme.textPrimary)
            Spacer()
            StatusBadge(text: badge)
        }
        .padding(.horizontal, 20)   // aligned with the content below
        .padding(.top, 30)          // sits just below the traffic lights
        .padding(.bottom, 12)
    }
}

// MARK: - Menu-bar panel header and rows

/// Top of a menu-bar panel: logo, app name, status badge, a one-line
/// subtitle, then a divider.
public struct MenuPanelHeader<Logo: View>: View {
    var title: String
    var badge: String
    var subtitle: String
    var logo: Logo

    public init(title: String, badge: String, subtitle: String, @ViewBuilder logo: () -> Logo) {
        self.title = title
        self.badge = badge
        self.subtitle = subtitle
        self.logo = logo()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 9) {
                logo
                Text(title)
                    .font(.system(size: 12.5, weight: .semibold))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
                StatusBadge(text: badge)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 7)

            Text(subtitle)
                .font(.system(size: 11.5))
                .foregroundStyle(Theme.textTertiary)
                .padding(.horizontal, 12)
                .padding(.bottom, 10)

            Divider().overlay(Theme.divider)
        }
    }
}

/// One clickable row in a menu-bar panel: icon and title, tinted on hover.
public struct MenuRow: View {
    let title: String
    let systemImage: String
    let action: () -> Void
    @State private var hover = false

    public init(title: String, systemImage: String, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.system(size: 12))
                    .frame(width: 16)
                    .foregroundStyle(hover ? Theme.emberText : Theme.textSecondary)
                Text(title)
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.textPrimary)
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(hover ? Theme.emberTint : Color.clear, in: RoundedRectangle(cornerRadius: 6))
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hover = $0 }
    }
}

// MARK: - Notice banner

/// Ember-tinted warning box with an optional close button.
public struct NoticeBanner: View {
    var message: String
    var dismiss: (() -> Void)?

    public init(_ message: String, dismiss: (() -> Void)? = nil) {
        self.message = message
        self.dismiss = dismiss
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 11)).foregroundStyle(Theme.emberText)
            Text(message)
                .font(.system(size: 11.5)).foregroundStyle(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            if let dismiss {
                Spacer(minLength: 4)
                Button(action: dismiss) {
                    Image(systemName: "xmark").font(.system(size: 9, weight: .bold))
                        .foregroundStyle(Theme.textTertiary)
                }
                .buttonStyle(.plain)
                .help("Dismiss")
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.emberTint, in: RoundedRectangle(cornerRadius: 8))
    }
}
