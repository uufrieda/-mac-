# 她先输入法

她先是一款女性指代优先的 macOS 简体拼音输入法。它基于 Rime / Squirrel 1.1.2，本仓库保存“她先”新增的输入规则、界面配置、安装器脚本，以及可重新生成 macOS 安装包的构建流程。

GitHub Topic: `shenicest-fission`

## 当前版本

- macOS: 1.1.0
- 安装包: 请在 GitHub Releases 下载 `她先-1.1.0.pkg`
- SHA-256: `7cdc6774d0367101c1dc934d8a683cac244f12cf33c89c82811664ffdeae2e52`
- 系统要求: macOS 13.0 或更高版本，支持 Intel 与 Apple 芯片 Mac

## 她先规则

在性别未知或默认候选场景中，“她”和“她们”优先排在第一位。

示例：

- `t` -> `她`
- `ta` -> `她`
- `tamen` -> `她们`
- `tade` -> `她的`
- `geita` -> `给她`
- `henxiangta` -> `很想她`
- `yisheng` -> `她是医生`
- `laoban` -> `她是老板`
- `ceo` -> `她是CEO`
- `youxiu` -> `她很优秀`

明确男性语境会保留男性指代，例如 `爸爸`、`丈夫`、`男士` 等。非代词词汇也会被保护，例如 `其他`、`吉他`。

## 模式

- 她先: 性别未知时，女性形式排在第一位。
- 中性: 性别未知时，优先使用 `TA` 或 `对方`。
- 常规: 恢复普通拼音候选顺序。

按 `Control + `` 或 `F4` 打开“她先设置”，可以切换模式，也可以单独关闭职业联想或褒义联想。

## 仓库结构

- `rime/`: 她先输入规则、Lua 候选过滤器、Rime 默认设置和 Squirrel 外观配置。
- `package/`: macOS 安装器 Distribution、component plist、postinstall 脚本和安装器页面。
- `macos/`: 她先 App 的 Info.plist 与本地化资源。
- `assets/`: 图标资源说明；构建时会重新生成图标。
- `vendor/`: 上游 Squirrel 1.1.2 获取说明；构建时会按需下载。
- `dist/`: 发布安装包校验值；本地构建会在这里生成安装包。
- `tools/`: 候选词验证程序和辅助源码。
- `scripts/`: 本地重建与验证脚本。
- `docs/`: 面向用户的安装说明。

## 本地重建

在 macOS 上运行：

```bash
bash scripts/build-macos-package.sh
```

脚本会按需下载 Squirrel 1.1.2，重新生成她先图标，并输出 `dist/她先-1.1.0.pkg` 和 `dist/她先-1.1.0.sha256.txt`。

## 验证候选词

先运行构建脚本，再运行：

```bash
bash scripts/verify-macos-candidates.sh
```

验证会检查她先模式、中性模式、常规模式，以及职业联想和褒义联想开关。

## 关于语音输入

macOS 系统听写不会把识别结果交给第三方输入法处理。为了避免后台监听和额外权限，本版本不自动改写系统听写已经输出的文字。

## 开源与许可

她先基于 Rime / Squirrel 1.1.2。Squirrel 使用 GPL-3.0，本仓库遵循同一许可发布。第三方项目说明见 [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md)。
