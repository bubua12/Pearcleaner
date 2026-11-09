//
//  ControlGroupChrome.swift
//  Pearcleaner
//
//  Created by Alin Lupascu on 8/8/25.
//

import SwiftUI

public enum ControlGroupLevel: Int {
    case primary
    case secondary
}

public struct ControlGroupMetrics {
    static let primaryGroupRadius: Double = 14
    static let secondaryGroupRadius: Double = 8
}

public extension ControlGroupLevel {
    var cornerRadius: Double {
        switch self {
        case .primary: ControlGroupMetrics.primaryGroupRadius
        case .secondary: ControlGroupMetrics.secondaryGroupRadius
        }
    }
}

public extension View {
    func controlGroup(level: ControlGroupLevel = .primary) -> some View {
        modifier(ControlGroupChrome(level: level, shapeBuilder: {
            RoundedRectangle(cornerRadius: level.cornerRadius, style: .continuous)
        }))
    }

    func controlGroup<S>(_ shape: S, level: ControlGroupLevel = .primary) -> some View where S: InsettableShape {
        modifier(ControlGroupChrome<S>(level: level, shapeBuilder: { shape }))
    }
}

private struct ControlGroupChrome<Shape: InsettableShape>: ViewModifier {
    @Environment(\.colorScheme)
    private var colorScheme

    var level: ControlGroupLevel
    var shapeBuilder: () -> Shape

    var dark: Bool { colorScheme == .dark }

    private var innerRimOpacity: Double {
        switch level {
        case .primary:
            return dark ? 0.15 : 0
        case .secondary:
            return dark ? 0.1 : 0
        }
    }

    private var outerRimOpacity: Double {
        switch level {
        case .primary:
            return dark ? 0.5 : 0.8
        case .secondary:
            return dark ? 0.4 : 0.7
        }
    }

    private var shadowOpacity: Double {
        switch level {
        case .primary:
            return dark ? 0.2 : 0.1
        case .secondary:
            return dark ? 0.1 : 0.05
        }
    }

    private var material: Material {
        switch level {
        case .primary:
            return .thin
        case .secondary:
            return .regular
        }
    }

    func body(content: Content) -> some View {
        content
            .background(material, in: shape)
            .clipShape(shape)
            // macOS 27 flat look: a single hairline border instead of stacked rim/drop shadows
            .overlay {
                shape
                    .strokeBorder(Color.primary.opacity(dark ? 0.12 : 0.1), lineWidth: 1)
            }
            .chromeBorder(shape: shape, highlightEnabled: false, rimEnabled: false, shadowEnabled: false)
            .containerShape(shape)
    }

    private var shape: Shape {
        shapeBuilder()
    }
}
