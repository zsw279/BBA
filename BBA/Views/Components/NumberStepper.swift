//
//  NumberStepper.swift
//  BBA
//
//  数字步进器
//

import SwiftUI

struct NumberStepper: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    var step: Double = 1
    var unit: String = ""
    var label: String? = nil
    var precision: Int = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let label = label {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            HStack(spacing: 12) {
                Button {
                    HapticService.light()
                    value = max(range.lowerBound, value - step)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title)
                }
                .disabled(value <= range.lowerBound)

                Spacer()

                Text(formattedValue + (unit.isEmpty ? "" : " \(unit)"))
                    .font(.title2.bold())
                    .monospacedDigit()
                    .frame(minWidth: 100)

                Spacer()

                Button {
                    HapticService.light()
                    value = min(range.upperBound, value + step)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title)
                }
                .disabled(value >= range.upperBound)
            }
        }
    }

    private var formattedValue: String {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = precision
        f.minimumFractionDigits = 0
        return f.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}

#Preview {
    @Previewable @State var value: Double = 65.5
    return NumberStepper(
        value: $value,
        range: 30...120,
        step: 0.5,
        unit: "cm",
        label: "身高",
        precision: 1
    )
    .padding()
}
