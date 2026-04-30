# 发布步骤说明

本仓库发布统一按以下流程执行。

## 当前版本

- 1.1.25

## 版本规则

- 主分支：`master`
- Tag 格式：`v<版本号>`，例如 `v1.1.2`
- 存档分支格式：与版本号同名，例如 `1.1.2`
- 版本分支仅用于版本代码存档，日常开发始终在 `master` 进行
- 文档语言规则：`RELEASE_PROCESS.md` 保持中文，`README.md` 保持英文

## 标准发布流程

1. 先更新外部入口展示的版本号，再更新 `README.md` 中的版本记录（保持英文），并更新 `version.config.js` 中的版本号
2. 检查 `RELEASE_PROCESS.md` 是否保持中文内容
3. 检查当前代码改动并确认纳入本次发布
4. 提交代码到本地仓库
5. 推送 `master` 到 GitHub
6. 创建对应 Tag
7. 推送 Tag 到 GitHub
8. 创建同名存档分支
9. 推送存档分支到 GitHub
10. 验证提交、Tag、分支是否全部存在

## 标准提交信息

- `release: v<版本号>`
- 示例：`release: v1.1.2`

## 标准命令

按版本号 `1.1.2` 为例：

```bash
git add -A
git commit -m "release: v1.1.2"
git push origin master
git tag v1.1.2
git push origin refs/tags/v1.1.2
git branch 1.1.2
git push origin refs/heads/1.1.2
```

## 可选文档同步 Tag

当发布后仅同步文档时可使用轻量 Tag。

- Tag 格式：`docs-v<版本号>-sync`
- 示例：`docs-v1.1.12-sync`

```bash
git tag docs-v1.1.12-sync
git push origin refs/tags/docs-v1.1.12-sync
```

## 发布前检查

- `README.md` 已新增当前版本说明（英文）
- `version.config.js` 已更新为当前版本号
- 外部入口展示版本号已更新为当前版本
- `RELEASE_PROCESS.md` 保持中文
- 工作区改动确认无误
- 当前分支为 `master`
- 目标 Tag 不存在
- 目标分支不存在

## 发布后检查

- GitHub 上 `master` 已更新
- GitHub 上存在对应 Tag
- GitHub 上存在同名存档分支
- 本地工作区保持干净

## 后续可直接使用的发布指令

后续只需给出类似指令即可开始发布：

默认会同时更新 `README.md` 的版本记录与 `version.config.js` 的版本号。

```text
发布 1.1.3
按 RELEASE_PROCESS.md 执行
```

如果需要补充版本说明，可一并提供：

```text
发布 1.1.3
按 RELEASE_PROCESS.md 执行
版本说明：
- 新增 xxx
- 修复 xxx
```
