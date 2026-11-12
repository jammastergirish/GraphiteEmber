import SwiftUI

// Interactive controls in the Graphite & Ember style: checkboxes, chips,
// segmented pickers, drop-down menus and the small ember link button.

// MARK: - Checkbox

/// The ember checkbox square: filled ember with a tick when on, a faint
/// outlined square when off.
public struct CheckSquare: View {
    var isOn: Bool
    var side: CGFloat

    public init(isOn: Bool, side: CGFloat = 16) {
        self.isOn = isOn
        self.side = side
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: side * 0.25)
            .fill(isOn ? Theme.ember : Theme.checkboxOff)
            .frame(width: side, height: side)
            .overlay(RoundedRectangle(cornerRadius: side * 0.25)
                .stroke(Theme.fieldBorder, lineWidth: isOn ? 0 : 1))
            .overlay(Image(systemName: "checkmark")
                .font(.system(size: side * 0.56, weight: .bold))
                .foregroundStyle(.white)
                .opacity(isOn ? 1 : 0))
    }
}

/// `Toggle("Label", isOn: $x).toggleStyle(EmberCheckboxStyle())`
public struct EmberCheckboxStyle: ToggleStyle {
    var fontSize: CGFloat

    public init(fontSize: CGFloat = 13) {
        self.fontSize = fontSize
    }

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                CheckSquare(isOn: configuration.isOn, side: fontSize + 3)
                    .offset(y: 2)
                configuration.label
                    .font(.system(size: fontSize))
                    .foregroundStyle(Theme.textPrimary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Chips (segmented pickers and tick-box groups)

extension View {
    /// The look of one chip in a `ChipGroup`: card background and ember text
    /// when selected, plain secondary text when not.
    public func chipStyle(selected: Bool, compact: Bool = false) -> some View {
        self
            .foregroundStyle(selected ? Theme.emberText : Theme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, compact ? 4 : 6)
            .background(selected ? Theme.cardBG : Color.clear, in: RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(selected ? Theme.fieldBorder : Color.clear, lineWidth: 1))
            .contentShape(Rectangle())
    }
}

/// The recessed tray that holds a row of chips.
public struct ChipGroup<Content: View>: View {
    var disabled: Bool
    let content: Content

    public init(disabled: Bool = false, @ViewBuilder content: () -> Content) {
        self.disabled = disabled
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 2) { content }
            .padding(2)
            .background(Theme.checkboxOff, in: RoundedRectangle(cornerRadius: 8))
            .disabled(disabled)
            .opacity(disabled ? 0.55 : 1)
    }
}

public struct Segment<Value: Hashable>: Identifiable {
    public let value: Value
    public let title: String
    public let systemImage: String?
    public var id: Value { value }

    public init(value: Value, title: String, systemImage: String? = nil) {
        self.value = value
        self.title = title
        self.systemImage = systemImage
    }
}

/// Pick exactly one of several options.
public struct SegmentPicker<Value: Hashable>: View {
    let segments: [Segment<Value>]
    @Binding var selection: Value
    var disabled: Bool
    var compact: Bool

    public init(segments: [Segment<Value>], selection: Binding<Value>, disabled: Bool = false, compact: Bool = false) {
        self.segments = segments
        self._selection = selection
        self.disabled = disabled
        self.compact = compact
    }

    public var body: some View {
        ChipGroup(disabled: disabled) {
            ForEach(segments) { seg in
                let selected = seg.value == selection
                Button { selection = seg.value } label: {
                    HStack(spacing: 6) {
                        if let icon = seg.systemImage {
                            Image(systemName: icon).font(.system(size: compact ? 10 : 11, weight: .medium))
                        }
                        Text(seg.title).font(.system(size: compact ? 11.5 : 12.5, weight: selected ? .semibold : .regular))
                    }
                    .chipStyle(selected: selected, compact: compact)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

/// A chip you tick on and off independently of its neighbours (put several in
/// a `ChipGroup` to pick any combination).
public struct ToggleChip: View {
    let title: String
    let systemImage: String?
    @Binding var isOn: Bool

    public init(_ title: String, systemImage: String? = nil, isOn: Binding<Bool>) {
        self.title = title
        self.systemImage = systemImage
        self._isOn = isOn
    }

    public var body: some View {
        Button { isOn.toggle() } label: {
            HStack(spacing: 7) {
                CheckSquare(isOn: isOn, side: 14)
                if let systemImage {
                    Image(systemName: systemImage).font(.system(size: 11, weight: .medium))
                }
                Text(title).font(.system(size: 12.5, weight: isOn ? .semibold : .regular))
            }
            .chipStyle(selected: isOn)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Drop-down menu

/// A field-styled drop-down. Each option pairs a value with its label.
public struct OptionMenu<Value: Hashable>: View {
    public struct Option {
        public let value: Value
        public let label: String
        public init(_ value: Value, _ label: String) {
            self.value = value
            self.label = label
        }
    }

    let options: [Option]
    @Binding var selection: Value
    var disabled: Bool

    public init(options: [Option], selection: Binding<Value>, disabled: Bool = false) {
        self.options = options
        self._selection = selection
        self.disabled = disabled
    }

    public var body: some View {
        Menu {
            ForEach(options.indices, id: \.self) { i in
                let option = options[i]
                Button {
                    selection = option.value
                } label: {
                    if option.value == selection {
                        Label(option.label, systemImage: "checkmark")
                    } else {
                        Text(option.label)
                    }
                }
            }
        } label: {
            HStack(spacing: 6) {
                Text(options.first(where: { $0.value == selection })?.label ?? "—")
                    .font(.system(size: 12))
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Spacer(minLength: 4)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(Theme.textTertiary)
            }
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background(Theme.fieldBG, in: RoundedRectangle(cornerRadius: 6))
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Theme.fieldBorder, lineWidth: 1))
            .contentShape(Rectangle())
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .disabled(disabled)
        .opacity(disabled ? 0.55 : 1)
    }
}

// MARK: - Link button

/// Small ember-text button on an ember tint ("Grant", "Relaunch").
public struct EmberLinkButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(Theme.emberText)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Theme.emberTint, in: RoundedRectangle(cornerRadius: 5))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}
