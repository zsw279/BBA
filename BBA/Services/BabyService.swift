//
//  BabyService.swift
//  BBA
//
//  宝宝档案服务
//

import Foundation
import SwiftData
import UIKit

@MainActor
final class BabyService {
    static let shared = BabyService()

    private init() {}

    // MARK: - CRUD

    /// 创建宝宝
    @discardableResult
    func createBaby(
        in context: ModelContext,
        name: String,
        birthDate: Date,
        gender: Gender,
        bloodType: String? = nil,
        avatarData: Data? = nil
    ) -> Baby {
        let baby = Baby(
            name: name,
            birthDate: birthDate,
            gender: gender,
            bloodType: bloodType,
            avatarData: avatarData
        )
        context.insert(baby)
        try? context.save()
        return baby
    }

    /// 更新宝宝信息
    func updateBaby(
        _ baby: Baby,
        name: String? = nil,
        birthDate: Date? = nil,
        gender: Gender? = nil,
        bloodType: String?? = nil,
        avatarData: Data?? = nil,
        heightUnit: String? = nil,
        weightUnit: String? = nil
    ) {
        if let name = name { baby.name = name }
        if let birthDate = birthDate { baby.birthDate = birthDate }
        if let gender = gender { baby.gender = gender }
        if let bloodType = bloodType { baby.bloodType = bloodType }
        if let avatarData = avatarData { baby.avatarData = avatarData }
        if let heightUnit = heightUnit { baby.preferredHeightUnit = heightUnit }
        if let weightUnit = weightUnit { baby.preferredWeightUnit = weightUnit }
        baby.updatedAt = Date()
    }

    /// 删除宝宝(以及所有关联数据)
    func deleteBaby(_ baby: Baby, in context: ModelContext) {
        // 清理媒体文件
        for media in baby.mediaItems {
            MediaStorage.shared.deleteMedia(fileName: media.fileName)
            if let thumb = media.thumbnailFileName {
                MediaStorage.shared.deleteMedia(fileName: thumb, in: .thumbnail)
            }
        }
        // 取消所有提醒
        for reminder in baby.reminders where reminder.isEnabled {
            NotificationService.shared.cancelReminder(notificationID: reminder.notificationID)
        }
        context.delete(baby)
        try? context.save()
    }

    // MARK: - 头像

    /// 加载头像
    func loadAvatar(_ baby: Baby) -> UIImage? {
        guard let data = baby.avatarData else { return nil }
        return UIImage(data: data)
    }
}
