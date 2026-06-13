# BBA 安装到 iPhone 完整指南(零成本)

> 适用:Windows 用户,无 Mac,想免费把 APP 装到自己的 iPhone

---

## 📋 总览

整个流程 4 步:
1. 把代码推到 GitHub(本地)
2. GitHub Actions 自动编译出 `.app`(云端 Mac)
3. 下载 `.app` 到 Windows
4. AltStore 签名 + 装到 iPhone

预计总时间:**第 1 次 1-2 小时**,之后每次重新编译只需 5 分钟。

---

## 第 1 步:安装必要工具(Windows)

### 1.1 安装 Git
- 下载: https://git-scm.com/download/win
- 一路 Next 安装即可

### 1.2 安装 iTunes(只是为了驱动 iPhone)
- 打开 Microsoft Store 搜索 "iTunes" 安装
- 或者从 Apple 官网下载: https://www.apple.com/itunes/

### 1.3 安装 iCloud(可选,方便)
- Microsoft Store 搜索 "iCloud" 安装
- 登录你的 Apple ID

### 1.4 在 iPhone 上准备
- 打开 "设置" → "隐私与安全性" → 打开 "开发者模式"(首次会要求重启)
- 信任这台电脑:首次连数据线时,iPhone 会弹窗"信任此电脑",点信任

---

## 第 2 步:注册 GitHub 并推送代码(15 分钟)

### 2.1 注册 GitHub
- 访问 https://github.com 注册账号(免费)
- 验证邮箱

### 2.2 创建仓库
- 登录后,右上角 + → "New repository"
- Repository name: `BBA`
- 选择 **Public**(公开,GitHub Actions 免费额度更高)
- 不要勾选 "Add a README"
- 点击 "Create repository"

### 2.3 推送代码
在 Windows 上打开 PowerShell 或 Git Bash:
```bash
cd D:\claude_demo\BBA

# 初始化 git
git init
git add .
git commit -m "BBA 初始版本"

# 改主分支名为 main
git branch -M main

# 添加远程仓库(替换 你的用户名)
git remote add origin https://github.com/你的用户名/BBA.git

# 推送
git push -u origin main
```

> 第一次推送会要求登录 GitHub,按提示在浏览器中授权。

推送成功后,刷新 GitHub 仓库页面,应该能看到所有文件。

---

## 第 3 步:触发 GitHub Actions 编译(等待 10-15 分钟)

### 3.1 查看 Actions
- 在 GitHub 仓库页面,点击 "Actions" 标签
- 你会看到 "Build iOS" workflow 正在运行(自动触发)
- 也可以点击右侧 "Run workflow" 手动触发

### 3.2 等待编译完成
- 第一次会下载 Xcode 和依赖,约 10-15 分钟
- 成功后变绿勾 ✓
- 失败变红叉 ✗ (把日志发给我,我帮你修)

### 3.3 下载编译产物
1. 进入 workflow 运行详情
2. 滚到页面底部 "Artifacts" 区域
3. 点击 "BBA-unsigned" 下载(得到一个 zip 文件)
4. 解压到任意位置,得到 `BBA.app` 文件夹

> ⚠️ **重要**:不要直接双击 `.app`,Windows 装不了。需要走第 4 步的 AltStore 流程。

---

## 第 4 步:用 AltStore 安装到 iPhone(20 分钟)

### 4.1 注册免费 Apple Developer 账号
- 用你的 Apple ID 登录 https://developer.apple.com/account
- 同意协议即可(免费,无需付费)

### 4.2 在 iPhone 上安装 AltStore
- 在 iPhone Safari 浏览器打开: https://altstore.io/
- 点击 "Download AltStore" → "iOS"
- 它会让你添加一个企业签名 profile,允许安装 AltStore
- 安装后 AltStore 图标出现在桌面

### 4.3 在 Windows 上安装 AltServer
- 访问 https://altstore.io/
- 下载 AltServer for Windows
- 安装并运行 AltServer(它会最小化到任务栏)

### 4.4 配置 AltServer
- 点击任务栏 AltServer 图标 → "Install AltStore" → 选你的 iPhone
- 输入你的 Apple ID 和密码(用 App 专用密码,见下)
- iPhone 上会出现 AltStore,打开它

> ⚠️ **Apple ID 二次验证问题**:
> 1. 登录 https://appleid.apple.com
> 2. "登录与安全性" → "App 专用密码" → 生成密码
> 3. 把生成的密码填到 AltServer
> 4. 以后 AltServer 每次重签都会用这个

### 4.5 通过 AltStore 安装 BBA
**方法 A:用 iPhone 上的 AltStore(推荐)**
1. 把第 3 步下载的 `BBA.app` 复制到 iPhone(用 iCloud Drive / AirDrop / 微信)
2. 在 iPhone 上打开 AltStore
3. 点击底栏 "My Apps" → 右上角 "+"
4. 选择 BBA.app 文件
5. 等待安装完成,主屏出现 BBA 图标 ✓

**方法 B:用 Windows 上的 AltServer**
1. iPhone 用数据线连电脑并信任
2. AltServer → "Install AltStore" → 选 iPhone
3. 这次会要求你选择 `.app` 文件(从第 3 步的解压位置)
4. 完成安装

---

## 🎉 第一次启动

1. 主屏打开 BBA
2. 进入引导页,创建宝宝档案
3. 开始使用!

---

## ⚠️ 免费方案的 3 个限制

1. **7 天过期**:免费 Apple ID 签名的 App 7 天后会无法打开
   - **解决**:在 iPhone 上打开 AltStore → 找到 BBA → 点击 "Refresh" 重新签名(需要电脑开着 AltServer)
   - 或:打开 AltStore 设置,开启 "Background Refresh"(需要开启 Wi-Fi 联网)

2. **最多 3 个 App**:免费账号一次只能签 3 个第三方 App
   - **解决**:每次只能装 3 个,可以删除已签名的再装新的

3. **不能上 App Store**:免费账号不能发布到 App Store
   - 解决:自用足够,无需上 App Store

---

## 👨‍👩‍👧 给家人也装

每个家人的 iPhone 都需要:
1. 各自安装 AltStore(用各自的 Apple ID)
2. 各自安装 AltServer(在自己的电脑 / 借用一台)
3. 共享 `BBA.app` 文件(微信 / iCloud Drive / AirDrop)
4. 各自走一遍 4.5 步骤

**简化方案**:
- 把 `BBA.app` 上传到网盘(百度网盘 / iCloud Drive / Dropbox)
- 家人下载到 iPhone,各自用 AltStore 装

**注意**:数据是存在每个 iPhone 本地的,家人的 iPhone 上需要各自重新创建宝宝档案。数据不共享。

---

## 🔄 重新编译(代码更新后)

每次修改代码后:
```bash
cd D:\claude_demo\BBA
git add .
git commit -m "更新说明"
git push
```
GitHub Actions 自动重新编译,5-10 分钟后你按上面步骤重新装一次即可。

---

## 🆘 常见问题

### Q1: GitHub Actions 编译失败?
A: 把失败的日志(在 Actions 页面点进去能看到)发给我,我帮你改代码。

### Q2: AltStore 安装失败提示 "Please sign in with a different Apple ID"?
A: 用一个**专门用于开发的 Apple ID**,不要用正在用 iCloud 的主账号。注册新 Apple ID 即可。

### Q3: BBA.app 装到 iPhone 后打开闪退?
A: 第一次打开要在 iPhone 设置 → 通用 → VPN 与设备管理 → 信任你的 Apple ID 证书。

### Q4: 7 天后必须重签,不能自动吗?
A: 可以!AltStore 有 "Background Refresh" 功能,需要在 iPhone 保持 AltStore 联网运行,设置里开启。每月需电脑开一次 AltServer 续签。

### Q5: 比买 Mac Mini 划算吗?
A: 短期免费方案省钱。长期使用,买二手 Mac Mini M1(2000 元)更省心,因为你可以:
- 随时编译
- 任意修改代码
- 不用每月开电脑续签
- 顺便给家里其他人也开发各种 App

---

## 📞 需要帮助?

把以下信息发给我:
1. 卡在哪一步
2. 错误信息截图
3. 你想实现什么效果

我会持续帮你解决。
