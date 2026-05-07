# 灵居 iOS MVP

这是基于当前 `Web + Backend MVP` 的 iOS 第一版源码，目标是先跑通这条最小链路：

- 相册选图
- 上传图片
- 创建项目
- 轮询生成任务
- 展示免费预览
- mock 解锁完整报告
- 二次修改生成 v2
- 本地缓存最近项目

## 当前工程形态

当前目录是 `SwiftUI + XcodeGen` 工程源码，**不包含现成的 `.xcodeproj`**。

这是刻意保持轻量和可迁移的做法，避免把本地绝对路径和机器状态带进仓库。

## Mac 上如何运行

```bash
brew install xcodegen
cd lingju-ios
xcodegen generate
open LingJu.xcodeproj
```

运行要求：

- Xcode 15+
- iOS 17+

## 当前 API 地址

- Website: `https://ios1.ma37.com`
- API Base URL: `https://ios1.ma37.com/api`

当前接入接口：

- `POST /api/uploads/image`
- `POST /api/projects`
- `GET /api/generation-jobs/:jobId`
- `GET /api/projects/:projectId`
- `POST /api/projects/:projectId/mock-unlock`
- `POST /api/projects/:projectId/revisions`
- `GET /api/projects/:projectId/versions/:versionId`

## 如何切换 mockAPIMode

在文件 [AppConfig.swift](/E:/codex项目/AI%20家装售前方案生成器/lingju-ios/Sources/App/AppConfig.swift) 中修改：

```swift
static let mockAPIMode = false
```

- `false`：走真实后端 `https://ios1.ma37.com/api`
- `true`：不请求真实接口，使用本地 Mock 跑完整 UI 流程

Mock 模式会覆盖：

- 模拟上传
- 模拟创建项目
- 模拟 generation job 进度
- 模拟获取预览结果
- 模拟 mock-unlock
- 模拟二次修改生成 v2

## 当前不包含

当前版本**暂不包含**：

- 登录
- Keychain
- 真实 StoreKit
- 后端“我的项目列表”接口
- 淘宝链接
- 社区

## 目录结构

```text
lingju-ios/
  project.yml
  README.md
  Resources/
  Sources/
    App/
    Models/
    Services/
    Storage/
    UI/
    ViewModels/
    Views/
```

## Mac 上第一次运行的检查步骤

建议按这个顺序验：

1. 能否执行 `xcodegen generate`
2. 能否成功打开 `LingJu.xcodeproj`
3. 能否在模拟器里编译通过
4. 能否进入首页和创建项目页
5. 能否选择相册图片
6. 能否上传图片
7. 能否创建项目
8. 能否进入生成中页面
9. 能否进入免费预览页
10. 能否 mock 解锁完整方案
11. 能否发起二次修改并生成 v2

## 当前实现上的取舍

1. “我的项目”先用 `RecentProjectsStore` 本地缓存最近项目，不请求后端全量列表。
2. 所有 AI 生成只走后端 API，iOS 工程内不保存任何 OpenAI Key。
3. 图片上传默认压缩到约 3MB 左右，字段名固定为 `file`。
4. 对后端返回做了宽松解析，兼容常见的 `snake_case / camelCase` 差异。

## 如果你准备继续下一轮

更适合的下一步是：

1. 在 Mac / Xcode 上完成真实编译验证
2. 根据编译器报错做第三轮清理
3. 然后再决定是否接入真实 StoreKit、登录或更完整的项目中心
