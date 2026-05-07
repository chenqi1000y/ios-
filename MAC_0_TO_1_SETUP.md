# 灵居 iOS 0-1 安装到运行指南

这份文档是给 **0 基础、刚拿到一台新 Mac** 的你准备的。

目标不是先讲概念，而是带你把当前 `灵居 iOS` 第一版源码在 Mac 上真正跑起来。

你最终要做到的是：

1. 在 Mac 上安装好开发环境
2. 把当前 iOS 源码拷到 Mac
3. 生成 `LingJu.xcodeproj`
4. 用 Xcode 打开工程
5. 在模拟器里成功编译运行
6. 先用 `mockAPIMode` 跑通 UI
7. 再切换到真实后端联调

---

## 一、你现在需要从当前电脑带到 Mac 的文件

**只需要带这一个目录：**

`lingju-ios`

也就是把下面这个整个文件夹拷到 Mac：

[lingju-ios](</E:/codex项目/AI 家装售前方案生成器/lingju-ios>)

### 这个目录里最关键的文件有

- [project.yml](</E:/codex项目/AI 家装售前方案生成器/lingju-ios/project.yml>)
- [README.md](</E:/codex项目/AI 家装售前方案生成器/lingju-ios/README.md>)
- [MAC_0_TO_1_SETUP.md](</E:/codex项目/AI 家装售前方案生成器/lingju-ios/MAC_0_TO_1_SETUP.md>)
- `Sources/`
- `Resources/`

### 不需要带什么

当前这轮 **不需要** 把这些一起带到 Mac 才能做 iOS 编译验证：

- `backend/`
- `home-design-demo/`
- 服务器上的 `.env`
- OpenAI Key

因为 iOS 第一轮和第二轮的目标，是先把 **App 工程编译和联调链路跑通**。

---

## 二、最简单的传输方式

你是 0 基础，我建议只选最简单的一个方法。

### 方法 A：直接拷整个 `lingju-ios` 文件夹到 U 盘 / 移动硬盘

把 `lingju-ios` 整个目录复制到移动存储设备，然后在 Mac 上粘贴到：

```bash
~/Desktop/
```

或者：

```bash
~/Documents/
```

### 方法 B：发到网盘，再在 Mac 下载

把 `lingju-ios` 压缩成 zip：

```text
lingju-ios.zip
```

上传到网盘，在 Mac 下载后解压。

### 方法 C：如果你已经会用 Git

如果你后面想正规一点，可以把这个目录放进 Git 仓库再拉到 Mac。

但你现在是 0 基础，**先不用这个**。

---

## 三、Mac 上第一天要安装什么

你这台是新 Mac，建议按这个顺序装。

## 1. 安装 Xcode

打开 Mac 上的：

`App Store`

搜索：

`Xcode`

然后安装。

### 注意

- Xcode 很大，可能要十几 GB
- 安装完成后，**一定要先打开一次**
- 第一次打开会让你同意协议、安装组件，点确认即可

---

## 2. 安装 Command Line Tools

打开 Mac 上的：

`终端 Terminal`

执行：

```bash
xcode-select --install
```

如果弹窗提示安装，就点安装。

如果提示已经安装，也没关系。

---

## 3. 安装 Homebrew

Homebrew 是 Mac 上最常用的包管理器，后面装 `xcodegen` 需要它。

在终端执行：

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

安装完成后，执行：

```bash
brew -v
```

如果能看到版本号，说明成功。

---

## 4. 安装 XcodeGen

在终端执行：

```bash
brew install xcodegen
```

然后执行：

```bash
xcodegen --version
```

如果能看到版本号，说明成功。

---

## 四、把 iOS 源码放到 Mac 哪里

假设你已经把 `lingju-ios` 文件夹拷到 Mac。

我建议你放在：

```bash
~/Documents/lingju-ios
```

或者：

```bash
~/Desktop/lingju-ios
```

**不要放到系统太深的目录里。**

对新手最友好的方式就是桌面或文稿目录。

---

## 五、在 Mac 上生成 Xcode 工程

进入终端，假设你放在桌面：

```bash
cd ~/Desktop/lingju-ios
```

如果你放在文稿目录：

```bash
cd ~/Documents/lingju-ios
```

然后执行：

```bash
xcodegen generate
```

### 你预期会看到

类似：

```bash
Generating project...
Writing project...
Created project at LingJu.xcodeproj
```

如果成功，就说明：

- `project.yml` 没坏
- 目录结构匹配
- XcodeGen 可以正常生成工程

---

## 六、打开工程

在终端继续执行：

```bash
open LingJu.xcodeproj
```

或者你也可以在 Finder 里直接双击：

`LingJu.xcodeproj`

---

## 七、第一次打开 Xcode 后要检查什么

打开工程以后，先不要急着点 Run。

先检查这几件事。

## 1. 左侧文件树里是否能看到这些目录

- `Sources`
- `Resources`
- `App`
- `Models`
- `Services`
- `ViewModels`
- `Views`

如果这些都在，说明工程结构正常。

## 2. 顶部 Scheme 是否是 `LingJu`

看 Xcode 顶部中间，应该能看到：

`LingJu`

## 3. 运行目标先选模拟器

第一次建议选：

- `iPhone 16`
- 或 `iPhone 15`

不要先连真机，先用模拟器最稳。

---

## 八、第一次编译运行

点击 Xcode 左上角的三角形 Run 按钮。

或者按快捷键：

```text
Command + R
```

### 你第一次运行可能会遇到的事

#### 情况 1：直接成功

最好，说明工程已经能起。

#### 情况 2：提示签名问题

如果提示 `Signing`、`Team`、`Bundle` 相关问题，不用慌。

按下面操作：

1. 点击左侧工程名 `LingJu`
2. 选中 Target `LingJu`
3. 点击上方 `Signing & Capabilities`
4. 勾选 `Automatically manage signing`
5. `Team` 选择你自己的 Apple ID

如果你还没登录 Apple ID：

1. Xcode 顶部菜单 `Xcode`
2. `Settings...`
3. `Accounts`
4. 添加你的 Apple ID

### 注意

就算你没有开发者付费账号，**大多数情况下模拟器编译仍然能跑**。

---

## 九、第一轮建议先开 mock 模式

你是新电脑，先不要一上来就检查真实后端。

建议第一轮先把：

[AppConfig.swift](/E:/codex项目/AI%20家装售前方案生成器/lingju-ios/Sources/App/AppConfig.swift)

里的这行改成：

```swift
static let mockAPIMode = true
```

这样做的好处是：

- 不依赖服务器状态
- 不依赖网络
- 不依赖 HTTPS 证书细节
- 可以先验证页面和流程

---

## 十、mock 模式下你要怎么验收

跑起来之后，按这个顺序点：

1. 首页能不能打开
2. 点“上传户型图开始生成”
3. 选择一张相册图片
4. 看图片能否显示预览
5. 点“开始生成”
6. 看是否进入生成中页面
7. 看进度是否会自动走到完成
8. 看是否进入免费预览页
9. 点“解锁完整方案”
10. 看是否进入完整方案页
11. 点“二次修改”
12. 提交修改意见
13. 看是否生成 `方案 v2`
14. 切到“我的项目”看看最近项目缓存是否正常

如果这条链跑通，说明：

- 工程能编译
- SwiftUI 页面能跑
- 状态管理没炸
- Mock 服务没炸
- 本地缓存没炸

这一步非常重要。

---

## 十一、第二轮再切真实后端

等 mock 流程确认没问题后，再把：

```swift
static let mockAPIMode = false
```

改回来。

当前真实后端地址已经固定在：

```swift
static let apiBaseURL = https://ios1.ma37.com/api
```

也就是：

[https://ios1.ma37.com/api](https://ios1.ma37.com/api)

---

## 十二、真实后端模式下的验收路径

切回真实模式后，再跑这一条：

1. 选相册图
2. 上传图片
3. 创建项目
4. 进入生成中
5. 轮询 job
6. 完成后进入预览页
7. mock 解锁完整方案
8. 发起二次修改
9. 生成 v2

这时如果失败，通常就不是 UI 结构问题了，而是接口或网络问题。

---

## 十三、如果运行时报错，先看哪里

你是 0 基础，所以不要一看到报错就乱改。

优先按这个顺序看：

## 1. `project.yml`

[project.yml](</E:/codex项目/AI 家装售前方案生成器/lingju-ios/project.yml>)

如果 `xcodegen generate` 都过不了，先看这个。

## 2. `AppConfig.swift`

[AppConfig.swift](/E:/codex项目/AI%20家装售前方案生成器/lingju-ios/Sources/App/AppConfig.swift)

如果是 URL、mock 开关、配置问题，先看它。

## 3. `ProjectViewModel.swift`

[ProjectViewModel.swift](/E:/codex项目/AI%20家装售前方案生成器/lingju-ios/Sources/ViewModels/ProjectViewModel.swift)

如果是上传、创建项目、切页、图片压缩、版本切换，大概率看这里。

## 4. `GenerationViewModel.swift`

[GenerationViewModel.swift](/E:/codex项目/AI%20家装售前方案生成器/lingju-ios/Sources/ViewModels/GenerationViewModel.swift)

如果是轮询、超时、重试，看这里。

## 5. `ProjectResult.swift`

[ProjectResult.swift](/E:/codex项目/AI%20家装售前方案生成器/lingju-ios/Sources/Models/ProjectResult.swift)

如果是接口 JSON 解码失败，看这里。

## 6. `MockAPIStore.swift`

[MockAPIStore.swift](/E:/codex项目/AI%20家装售前方案生成器/lingju-ios/Sources/Services/MockAPIStore.swift)

如果 mock 模式流程不通，看这里。

---

## 十四、最常见的新手问题

## 问题 1：我双击工程打不开

先确认你是不是已经先执行了：

```bash
xcodegen generate
```

因为当前项目不是直接带 `.xcodeproj` 的。

## 问题 2：Xcode 提示没有签名

先用模拟器，不要先上真机。

如果仍提示签名，就按前面“Signing & Capabilities”那一步处理。

## 问题 3：选图失败

检查：

- 是否在模拟器里允许相册权限
- 是否真的选择了图片
- 是否图片太大

## 问题 4：真实模式请求失败

先在浏览器里打开：

- [https://ios1.ma37.com](https://ios1.ma37.com)
- [https://ios1.ma37.com/health](https://ios1.ma37.com/health)

确认服务正常，再看 App。

## 问题 5：我看不懂 Xcode 报错

不要自己乱修。

把这 3 样东西发给我：

1. 报错截图
2. 报错原文
3. 你当时点击了什么

我会按顺序带你排。

---

## 十五、给你的最短执行版

如果你现在就要开干，只看这段就够了：

### 第一步：把 `lingju-ios` 整个文件夹拷到 Mac

### 第二步：安装

```bash
xcode-select --install
```

```bash
brew install xcodegen
```

### 第三步：进入目录

```bash
cd ~/Desktop/lingju-ios
```

### 第四步：生成工程

```bash
xcodegen generate
```

### 第五步：打开工程

```bash
open LingJu.xcodeproj
```

### 第六步：先把 `mockAPIMode` 改成 `true`

### 第七步：Run

### 第八步：先跑通 mock 流程

### 第九步：再改回 `mockAPIMode = false` 联调真实后端

---

## 十六、你现在最应该做什么

你现在不用想部署，也不用想上架。

你现在只做一件事：

**把 `lingju-ios` 整个目录传到 Mac，然后执行 `xcodegen generate`。**

如果你做到这一步，下一步不管是编译报错、签名报错、选图问题、接口问题，我们都能继续往前推进。
