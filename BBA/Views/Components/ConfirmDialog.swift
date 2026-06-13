//
//  ConfirmDialog.swift
//  BBA
//
//  确认对话框
//

import SwiftUI

struct ConfirmDialog: ViewModifier {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let confirmTitle: String
    var isDestructive: Bool = false
    let onConfirm: () -> Void

    func body(content: Content) -> some View {
        content
            .confirmationDialog(title, isPresented: $isPresented) {
                Button(confirmTitle, role: isDestructive ? .destructive : nil) {
                    onConfirm()
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text(message)
            }
    }
}

extension View {
    func confirmDialog(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmTitle: String = "确定",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(ConfirmDialog(
            isPresented: isPresented,
            title: title,
            message: message,
            confirmTitle: confirmTitle,
            isDestructive: isDestructive,
            onConfirm: onConfirm
        ))
    }
}
