# 她先：开源与源码说明

“她先”1.1.0 使用 Rime / Squirrel 1.1.2 作为输入法引擎，并加入了女性代词优先配置、Lua 候选过滤规则、主题与品牌资源。

## 主要项目

- Squirrel 1.1.2，GPL-3.0：<https://github.com/rime/squirrel/tree/1.1.2>
- librime 1.16.x，BSD-3-Clause：<https://github.com/rime/librime>
- 朙月拼音词库，LGPL-3.0：<https://github.com/rime/rime-luna-pinyin>
- Sparkle 2.6.2，MIT：<https://github.com/sparkle-project/Sparkle>

完整 GPL-3.0 文本位于同目录的 `LICENSE.txt`。Squirrel 原始说明位于 `README.md`。

她先新增或修改的配置源文件位于 App 的 `Contents/SharedSupport`：

- `shefirst.schema.yaml`
- `shefirst_phrases.txt`
- `rime.lua`
- `squirrel.yaml`
- `default.yaml`

本版本为个人使用的本地构建，未使用 Rime 项目的官方签名。Rime 与 Squirrel 项目不对她先的改动负责。
