//
//  ExportView.swift
//  BBA
//
//  导出 / 备份入口
//

import SwiftUI
import SwiftData

struct ExportView: View {
    @Bindable var baby: Baby
    @State private var viewModel: ExportViewModel?
    @State private var showShareSheet = false
    @State private var showSuccessAlert = false

    var body: some View {
        Group {
            if let vm = viewModel {
                Form {
                    Section {
                        DatePicker(
                            "选择月份",
                            selection: Binding(
                                get: { vm.selectedMonth },
                                set: { vm.selectedMonth = $0 }
                            ),
                            displayedComponents: .date
                        )
                    } header: {
                        Text("月报 PDF")
                    } footer: {
                        Text("生成该月的成长报告,包含统计、里程碑、记录等")
                    }

                    Section {
                        Button {
                            Task { await exportPDF(vm: vm) }
                        } label: {
                            HStack {
                                if vm.isExporting {
                                    ProgressView()
                                } else {
                                    Image(systemName: "doc.fill")
                                }
                                Text(vm.isExporting ? "正在导出..." : "导出 PDF 月报")
                            }
                        }
                        .disabled(vm.isExporting)
                    }

                    Section {
                        Button {
                            exportJSON()
                        } label: {
                            HStack {
                                Image(systemName: "tray.and.arrow.down.fill")
                                Text("数据备份 (JSON)")
                            }
                        }
                    } header: {
                        Text("完整数据备份")
                    } footer: {
                        Text("导出所有记录为 JSON 文件,可用于数据迁移或备份")
                    }

                    if let error = vm.errorMessage {
                        Section {
                            Label(error, systemImage: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .navigationTitle("导出 / 备份")
        .onAppear {
            if viewModel == nil {
                viewModel = ExportViewModel(baby: baby)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let vm = viewModel, let url = vm.lastExportURL {
                ShareSheet(items: [url])
            }
        }
        .alert("导出成功", isPresented: $showSuccessAlert) {
            Button("好") {}
        } message: {
            Text("文件已保存到 APP 文档目录")
        }
    }

    private func exportPDF(vm: ExportViewModel) async {
        await vm.exportPDF()
        if vm.errorMessage == nil, vm.lastExportURL != nil {
            showShareSheet = true
        }
    }

    private func exportJSON() {
        do {
            let url = try ExportService.shared.exportJSON(baby: baby)
            viewModel?.lastExportURL = url
            showShareSheet = true
        } catch {
            viewModel?.errorMessage = error.localizedDescription
        }
    }
}
