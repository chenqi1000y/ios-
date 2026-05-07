# 灵居 iOS 路线 A 执行手册

这份文档就是你现在要走的路线 A：

`Win11 整理代码 -> GitHub 自动编译检查 -> Mac 本地 Xcode 运行 -> 模拟器验证 -> 真机验证`

这条路线适合你现在的阶段，因为它把“会不会编译”和“能不能真的跑起来”拆开了。

---

## 一、路线 A 的目标

你现在不是要一步到位上架，而是先做到这 5 件事：

1. 把 `lingju-ios` 放到 GitHub
2. 让 GitHub 自动帮你检查工程能不能编译
3. 在 Mac 上拉下代码
4. 在 Xcode 里跑起模拟器
5. 最后再连 iPhone 真机测试

---

## 二、你现在需要准备什么

### Win11 这边准备

你当前只需要这个目录：

[lingju-ios](</E:/codex项目/AI 家装售前方案生成器/lingju-ios>)

这个目录里我已经帮你补了：

- `.gitignore`
- GitHub Actions 自动编译工作流
- XcodeGen 配置
- Mac 0-1 安装文档

### 你需要有

1. 一个 GitHub 账号
2. 一台新的 Mac 笔记本
3. 后续用来测试的 iPhone（可选，但建议有）

---

## 三、Win11 上先做什么

## 第一步：把 `lingju-ios` 单独放好

建议你确认这个目录结构是完整的：

```text
lingju-ios/
  .github/
  Resources/
  Sources/
  .gitignore
  project.yml
  README.md
  MAC_0_TO_1_SETUP.md
  ROUTE_A_WIN11_GITHUB_MAC.md
```

---

## 第二步：创建 GitHub 仓库

去 GitHub 新建一个仓库，建议名字：

```text
lingju-ios
```

或者：

```text
lingju-app
```

都可以。

建议先设成：

- `Private`

这样更稳。

---

## 第三步：把本地代码传到 GitHub

如果你已经安装了 Git，可以在 Win11 终端里这样做。

先进入目录：

```bash
cd "E:\codex项目\AI 家装售前方案生成器\lingju-ios"
```

初始化 Git：

```bash
git init
```

添加文件：

```bash
git add .
```

提交：

```bash
git commit -m "init lingju ios mvp"
```

关联你的 GitHub 仓库地址：

```bash
git remote add origin 你的仓库地址
```

例如：

```bash
git remote add origin https://github.com/你的用户名/lingju-ios.git
```

推送：

```bash
git branch -M main
git push -u origin main
```

---

## 四、GitHub 自动编译是怎么工作的

我已经给你放好了工作流文件：

[ios-build.yml](</E:/codex项目/AI 家装售前方案生成器/lingju-ios/.github/workflows/ios-build.yml>)

它会做这些事：

1. 拉代码
2. 安装 `xcodegen`
3. 执行 `xcodegen generate`
4. 执行 `xcodebuild`
5. 检查这个工程是否能在 iOS Simulator 目标下编译通过

### 它的作用

它解决的是：

**“这套源码有没有明显编译问题”**

### 它不解决什么

它不替你解决：

- 本地 Xcode 交互调试
- 相册权限
- `PhotosPicker` 真实行为
- 真机安装
- 页面点按流程体验

所以它是“前置编译体检”，不是“完整替代 Mac”。

---

## 五、上传后怎么查看 GitHub 编译结果

你把代码 push 到 GitHub 后：

1. 打开仓库页面
2. 点击上方 `Actions`
3. 看 `iOS Build Check`

### 成功时你会看到

绿色勾：

```text
build passed
```

### 失败时你会看到

红色叉，然后点进去看日志。

你如果看不懂日志，不要硬改，直接把日志贴给我。

---

## 六、GitHub 编译通过后，Mac 上做什么

这一步才是路线 A 的后半段。

### 在 Mac 上先安装这些

1. Xcode
2. Command Line Tools
3. Homebrew
4. XcodeGen

具体步骤你看这里：

[MAC_0_TO_1_SETUP.md](</E:/codex项目/AI 家装售前方案生成器/lingju-ios/MAC_0_TO_1_SETUP.md>)

---

## 七、Mac 上拉代码

### 方法 A：直接从 GitHub clone

打开 Mac 终端执行：

```bash
git clone 你的仓库地址
```

例如：

```bash
git clone https://github.com/你的用户名/lingju-ios.git
```

进入目录：

```bash
cd lingju-ios
```

### 方法 B：如果你不会 git

那就直接在 GitHub 仓库页面点：

`Code -> Download ZIP`

下载后解压到桌面即可。

---

## 八、Mac 上生成 Xcode 工程

进入项目目录后执行：

```bash
xcodegen generate
```

如果成功，你会得到：

```text
LingJu.xcodeproj
```

然后执行：

```bash
open LingJu.xcodeproj
```

---

## 九、Mac 上第一轮建议先开 mock 模式

打开：

[AppConfig.swift](/E:/codex项目/AI%20家装售前方案生成器/lingju-ios/Sources/App/AppConfig.swift)

先把：

```swift
static let mockAPIMode = false
```

改成：

```swift
static let mockAPIMode = true
```

### 为什么先这么做

因为这样你可以先验证：

- App 能不能编译
- 页面能不能跑
- 状态流转对不对
- 上传前的图片处理有没有崩

先不受服务器状态影响。

---

## 十、Mac 上模拟器验证顺序

建议你先用 `iPhone 16` 或 `iPhone 15` 模拟器。

第一次验证按这个顺序：

1. 首页打开
2. 进入创建项目页
3. 选择相册图
4. 图片预览出现
5. 点击“开始生成”
6. 进入生成中页面
7. 进度走完
8. 进入免费预览页
9. 解锁完整方案
10. 发起二次修改
11. 生成 v2
12. 查看“我的项目”

如果 mock 这条链通了，说明本地工程底盘没大问题。

---

## 十一、第二轮再切真实后端

等 mock 没问题后，再把：

```swift
static let mockAPIMode = false
```

改回来。

此时 App 会对接：

[https://ios1.ma37.com/api](https://ios1.ma37.com/api)

然后再测真实流程：

1. 选图
2. 上传
3. 创建项目
4. 轮询 job
5. 进入预览页
6. mock 解锁
7. 二次修改
8. 生成 v2

---

## 十二、最后再做真机测试

当模拟器跑通后，再连 iPhone。

### 真机前你要做的事

1. 用数据线把 iPhone 连到 Mac
2. iPhone 上点“信任此电脑”
3. Xcode 里选择你的 iPhone 作为运行目标
4. 如果提示签名，去：
   - `Signing & Capabilities`
   - 勾选 `Automatically manage signing`
   - 选择你的 Apple ID Team

### 真机重点验证什么

真机最值得测的是：

- 相册权限
- 真实图片上传
- 页面滚动和布局
- 网络请求
- 生成完成后的图片展示

---

## 十三、路线 A 的节奏建议

我建议你不要一口气做完，按这个节奏走：

### 阶段 1：Win11

- 把 `lingju-ios` 上传到 GitHub
- 看 GitHub Actions 编译是否通过

### 阶段 2：Mac

- 安装 Xcode / Homebrew / XcodeGen
- `xcodegen generate`
- 打开工程

### 阶段 3：模拟器

- 先开 `mockAPIMode = true`
- 跑通整条 UI 流程

### 阶段 4：真实联调

- 改回 `mockAPIMode = false`
- 联调真实后端

### 阶段 5：真机

- 连 iPhone
- 做最终体验验证

---

## 十四、你现在就该做什么

如果你现在要开始执行，顺序就是：

1. 把 [lingju-ios](</E:/codex项目/AI 家装售前方案生成器/lingju-ios>) 上传到 GitHub
2. 看 GitHub Actions 是否通过
3. 把新的 Mac 准备好
4. 在 Mac 上按 [MAC_0_TO_1_SETUP.md](</E:/codex项目/AI 家装售前方案生成器/lingju-ios/MAC_0_TO_1_SETUP.md>) 安装环境
5. 在 Mac 上拉代码并运行

---

## 十五、你发给我什么，我能继续带你走

你执行过程中，下一步最有用的是把这些发给我：

### 如果你卡在 Win11 / GitHub

发我：

1. GitHub Actions 报错截图
2. 报错日志文本

### 如果你卡在 Mac / Xcode

发我：

1. `xcodegen generate` 输出
2. Xcode 第一条报错
3. 你当前把 `mockAPIMode` 设成了什么

---

## 十六、一句话版本

路线 A 不是让 GitHub 替你做完全部，而是：

**先让 GitHub 帮你做编译体检，再让 Mac 负责真正把 App 跑起来。**

这条路线对你现在最稳，也最省返工。
