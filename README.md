# BBA - 宝宝成长记录 iOS APP

> 记录宝宝成长的每一个珍贵瞬间 · 隐私优先 · 数据本地存储

BBA 是一款专为宝爸宝妈设计的 iPhone 应用,用于记录宝宝的成长过程:身高体重曲线、喂养/睡眠/尿布/用药日常、里程碑(第一次)、照片视频时间线,并支持本地通知提醒、月度 PDF 报告导出。

## ✨ 主要功能

- 📊 **成长曲线** - Swift Charts 绘制身高/体重/头围曲线
- 🍼 **日常记录** - 喂养(母乳左右计时)、睡眠、尿布、用药
- 🎉 **里程碑** - 30+ 预置模板 + 自定义,留住每一个"第一次"
- 📷 **照片时间线** - 照片视频按月排列
- ⏰ **智能提醒** - 本地通知,可重复(每天/每周/自定义)
- 📄 **PDF 导出** - 月度成长报告 + JSON 备份
- 🔒 **隐私优先** - 所有数据仅存储在你的设备本地

## 🛠 技术栈

- **语言**: Swift 5.9+
- **UI**: SwiftUI
- **数据**: SwiftData (iOS 17+)
- **图表**: Swift Charts
- **媒体**: PhotosUI / AVKit
- **最低 iOS**: 17.0

## 📂 项目结构

```
BBA/
├── App/                  # 应用入口 (BBAApp, RootView, AppDelegate)
├── Models/               # SwiftData 实体 + 枚举
│   ├── Baby.swift
│   ├── GrowthRecord.swift
│   ├── FeedingRecord.swift
│   ├── SleepRecord.swift
│   ├── DiaperRecord.swift
│   ├── MedicationRecord.swift
│   ├── Milestone.swift
│   ├── MediaItem.swift
│   ├── Reminder.swift
│   └── Enums/            # 8 个枚举类型
├── Services/             # 业务服务层
├── ViewModels/           # @Observable 视图模型
├── Views/                # 视图层(按 Tab 组织)
│   ├── Components/       # 通用组件
│   ├── Onboarding/       # 首次启动
│   ├── Home/             # 首页
│   ├── Growth/           # 成长
│   ├── Daily/            # 日常
│   ├── Milestone/        # 里程碑
│   ├── Media/            # 媒体
│   ├── Reminder/         # 提醒
│   ├── Settings/         # 设置
│   └── Export/           # 导出
├── Core/                 # 核心工具
│   ├── Extensions/       # Swift 扩展
│   ├── Utilities/        # 工具类
│   └── Constants/        # 常量
└── Resources/            # 资源
    ├── Info.plist
    └── MilestoneTemplates.json
```

## 🚀 在 Mac 上构建运行

由于 Swift / SwiftUI / SwiftData 必须在 macOS + Xcode 环境下编译,Windows 端仅用于编写代码。

### ⚡ 零成本方案:无 Mac 也能装到 iPhone

如果你没有 Mac,可以用 **GitHub Actions + AltStore** 零成本方案:
- 完整步骤见 [DEPLOY_GUIDE.md](./DEPLOY_GUIDE.md)
- 原理:GitHub 免费的 Mac 服务器帮你编译,你用免费 Apple ID 签名安装
- 限制:7 天需重签一次(可后台自动),最多 3 个第三方 App

### 🖥️ 有 Mac 的标准构建步骤

1. **安装 Xcode**
   - 打开 Mac App Store,搜索并安装 [Xcode 15+](https://apps.apple.com/app/xcode/id497799835)

2. **克隆代码**
   ```bash
   git clone <本仓库地址>
   cd BBA
   ```

3. **创建 Xcode 项目**
   - 打开 Xcode → File → New → Project
   - 选择 **iOS → App**
   - Product Name: `BBA`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **None**(我们用 SwiftData)

4. **导入源代码**
   - 在 Xcode 项目导航中,删除自动生成的 `ContentView.swift` 和 `<App>App.swift`
   - 把本仓库 `BBA/` 目录下的所有 `.swift` 文件拖入项目
   - 把 `BBA/Resources/Info.plist` 设为项目的 Info.plist
   - 把 `BBA/Resources/MilestoneTemplates.json` 加入项目(Bundle Resource)

5. **配置签名**
   - 选中项目 → Signing & Capabilities
   - Team 选择你的个人 Apple ID
   - Bundle Identifier 改成独一无二的(如 `com.yourname.bba`)

6. **配置权限**
   - 项目的 Info.plist 中已包含权限说明:
     - `NSPhotoLibraryUsageDescription`
     - `NSCameraUsageDescription`
     - `NSMicrophoneUsageDescription`
     - `NSUserNotificationsUsageDescription`

7. **运行**
   - 选择 iPhone 真机或模拟器(建议 iPhone 15 / iOS 17+)
   - 按 `Cmd + R` 运行
   - 首次启动进入 Onboarding,创建宝宝档案

## 📦 发布到 App Store(可选)

1. 注册 [Apple Developer Program](https://developer.apple.com/programs/)($99/年)
2. Xcode → Product → Archive
3. Organizer → Distribute App → App Store Connect
4. 提交审核

## 🔍 代码统计

| 类别 | 数量 |
|---|---|
| Swift 源文件 | ~80 个 |
| 代码行数 | ~10,000 行 |
| 数据模型 | 9 个 SwiftData 实体 + 8 个枚举 |
| 视图组件 | 7 个可复用 + 40+ 业务视图 |
| 服务类 | 10 个 |

## 📝 验证

启动后,按以下步骤验证:

1. ✅ 创建宝宝档案(Onboarding)
2. ✅ 添加一条成长记录 → 在"成长" Tab 看到折线图
3. ✅ 添加喂养/尿布记录 → 在"日常" Tab 看到列表,首页摘要更新
4. ✅ 添加里程碑 → 在"里程碑" Tab 看到时间线
5. ✅ 添加照片 → 在"媒体" Tab 看到缩略图
6. ✅ 设置一个 1 分钟后触发的提醒 → 收到本地通知
7. ✅ 设置页 → 导出 PDF → 系统分享面板弹出

## 🤝 贡献

欢迎 PR!但请注意:

- 保持 SwiftUI 风格一致
- 视图层与业务逻辑分离(Services / ViewModels)
- 内部数据统一用 cm / kg 存储,UI 层做单位换算
- 所有用户可见文本用中文

## 📄 许可

MIT License

---

**享受记录宝宝成长的过程 💕**
