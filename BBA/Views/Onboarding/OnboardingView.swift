//
//  OnboardingView.swift
//  BBA
//
//  首次启动引导 - 创建宝宝档案
//

import SwiftUI
import SwiftData
import PhotosUI

struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var step: OnboardingStep = .welcome
    @State private var name: String = ""
    @State private var gender: Gender = .other
    @State private var birthDate: Date = Date()
    @State private var bloodType: String = ""
    @State private var avatarItem: PhotosPickerItem? = nil
    @State private var avatarImage: Image? = nil
    @State private var avatarData: Data? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color.appPink.opacity(0.15), Color.appBlue.opacity(0.15)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()
                    Group {
                        switch step {
                        case .welcome: welcomeStep
                        case .profile: profileStep
                        case .birthday: birthdayStep
                        }
                    }
                    .transition(.opacity)
                    Spacer()
                    bottomButtons
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("BBA")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Steps

    @ViewBuilder
    private var welcomeStep: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.appPink, .appPurple],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text("欢迎使用 BBA")
                .font(.largeTitle.bold())
            Text("记录宝宝成长的每一个珍贵瞬间")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            VStack(alignment: .leading, spacing: 12) {
                featureRow(icon: "chart.line.uptrend.xyaxis", title: "成长曲线", subtitle: "追踪身高体重头围")
                featureRow(icon: "drop.fill", title: "日常记录", subtitle: "喂养 / 睡眠 / 尿布 / 用药")
                featureRow(icon: "sparkles", title: "里程碑", subtitle: "留住第一次的感动")
                featureRow(icon: "photo.on.rectangle.angled", title: "时间线", subtitle: "照片视频按时间排列")
            }
            .padding(.top, 8)
        }
    }

    @ViewBuilder
    private var profileStep: some View {
        VStack(spacing: 20) {
            Text("先认识一下宝宝吧")
                .font(.title2.bold())

            PhotosPicker(selection: $avatarItem, matching: .images) {
                ZStack {
                    if let avatarImage = avatarImage {
                        avatarImage
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.appPink.opacity(0.2))
                            .frame(width: 120, height: 120)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.title)
                                    .foregroundColor(.appPink)
                            )
                    }
                    Circle()
                        .strokeBorder(Color.appPink, lineWidth: 3)
                        .frame(width: 120, height: 120)
                }
            }
            .onChange(of: avatarItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        avatarImage = Image(uiImage: uiImage)
                        avatarData = data
                    }
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("宝宝姓名")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                TextField("如:小宝", text: $name)
                    .textFieldStyle(.roundedBorder)
                    .font(.title3)
            }
            .padding(.top, 8)

            VStack(alignment: .leading, spacing: 8) {
                Text("性别")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Picker("性别", selection: $gender) {
                    ForEach(Gender.allCases) { g in
                        Text(g.displayName).tag(g)
                    }
                }
                .pickerStyle(.segmented)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("血型(可选)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Picker("血型", selection: $bloodType) {
                    Text("未知").tag("")
                    Text("A").tag("A")
                    Text("B").tag("B")
                    Text("AB").tag("AB")
                    Text("O").tag("O")
                }
                .pickerStyle(.segmented)
            }
        }
    }

    @ViewBuilder
    private var birthdayStep: some View {
        VStack(spacing: 20) {
            Text("宝宝生日")
                .font(.title2.bold())
            Text("用来计算月龄 / 周龄 / 疫苗提醒")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            DatePicker(
                "出生日期",
                selection: $birthDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .padding(.horizontal)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(.secondarySystemBackground))
            )

            HStack(spacing: 8) {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(.accentColor)
                Text(previewAge)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.accentColor.opacity(0.1))
            )
        }
    }

    // MARK: - Bottom

    @ViewBuilder
    private var bottomButtons: some View {
        VStack(spacing: 8) {
            switch step {
            case .welcome:
                Button {
                    withAnimation { step = .profile }
                    HapticService.light()
                } label: {
                    Text("开始创建")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

            case .profile:
                Button {
                    withAnimation { step = .birthday }
                    HapticService.light()
                } label: {
                    Text("下一步")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)

                Button("返回") {
                    withAnimation { step = .welcome }
                }
                .foregroundColor(.secondary)

            case .birthday:
                Button {
                    finishOnboarding()
                } label: {
                    Text("完成")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button("返回") {
                    withAnimation { step = .profile }
                }
                .foregroundColor(.secondary)
            }
        }
    }

    // MARK: - Helpers

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.appPink)
                .frame(width: 32, height: 32)
                .background(
                    Circle().fill(Color.appPink.opacity(0.15))
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.body.bold())
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }
            Spacer()
        }
    }

    private var previewAge: String {
        AgeCalculator.displayString(from: birthDate, to: Date())
    }

    private func finishOnboarding() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        let baby = Baby(
            name: trimmedName,
            birthDate: birthDate,
            gender: gender,
            bloodType: bloodType.isEmpty ? nil : bloodType,
            avatarData: avatarData
        )
        modelContext.insert(baby)
        try? modelContext.save()
        HapticService.success()
    }
}

enum OnboardingStep {
    case welcome
    case profile
    case birthday
}

#Preview {
    OnboardingView()
        .modelContainer(for: Baby.self, inMemory: true)
}
