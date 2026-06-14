//
//  PreferencesView.swift
//  BBA
//

import SwiftUI
import SwiftData

struct PreferencesView: View {
    let baby: Baby
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Form {
            Section("单位") {
                Picker("身高 / 头围", selection: Binding(
                    get: { baby.preferredHeightUnit },
                    set: { newValue in
                        baby.preferredHeightUnit = newValue
                        try? modelContext.save()
                    }
                )) {
                    Text("厘米 (cm)").tag("cm")
                    Text("英寸 (in)").tag("inch")
                }

                Picker("体重", selection: Binding(
                    get: { baby.preferredWeightUnit },
                    set: { newValue in
                        baby.preferredWeightUnit = newValue
                        try? modelContext.save()
                    }
                )) {
                    Text("千克 (kg)").tag("kg")
                    Text("磅 (lb)").tag("lb")
                }
            }
            Section {
                Text("这些单位仅影响显示。所有数据在内部以 cm / kg 存储,切换单位不会丢失精度。")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("偏好设置")
    }
}
