//
//  MilestoneTemplatePicker.swift
//  BBA
//

import SwiftUI
import SwiftData

struct MilestoneTemplatePicker: View {
    @Environment(\.dismiss) private var dismiss
    let baby: Baby
    @State private var selectedTemplate: MilestoneTemplate?

    var body: some View {
        NavigationStack {
            List {
                ForEach(MilestoneCategory.allCases) { category in
                    let templates = MilestoneTemplateLoader.grouped()[category] ?? []
                    if !templates.isEmpty {
                        Section {
                            ForEach(templates) { template in
                                Button {
                                    selectedTemplate = template
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(template.title)
                                                .font(.subheadline)
                                            if template.suggestedMonths > 0 {
                                                Text("建议月龄:\(template.suggestedMonths)个月")
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            Label(category.displayName, systemImage: category.iconName)
                                .foregroundColor(Color.fromName(category.colorName))
                        }
                    }
                }
            }
            .navigationTitle("选择模板")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
        }
        .sheet(item: $selectedTemplate) { template in
            AddMilestoneView(baby: baby, template: template)
        }
    }
}
