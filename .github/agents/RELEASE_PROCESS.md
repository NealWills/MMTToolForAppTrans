# 发布步骤说明

本仓库发布统一按以下流程执行。

## 当前版本

- 0.6.9

## 版本规则

- 主分支：`main`
- Tag 格式：`<版本号>`，例如 `0.6.9`
- 存档分支格式：与版本号同名，例如 `0.6.9`
- 版本分支仅用于版本代码存档，日常开发始终在 `main` 进行
- 文档语言规则：`RELEASE_PROCESS.md` 保持中文，`README.md` 保持英文

## 标准发布流程

1. 先更新 `MMTToolForAppTrans.podspec` 中的版本号 (`s.version`)，并根据本次发布内容同步更新 `s.summary` 和 `s.description`，确保描述与当前功能集一致
2. 在 `Doc/Version.md` 顶部新增版本记录（中文）
3. 检查 `README.md` 是否保持英文内容
4. 检查当前代码改动并确认纳入本次发布
5. 提交代码到本地仓库
6. 推送 `main` 到 GitHub
7. 创建对应 Tag
8. 推送 Tag 到 GitHub
9. 创建同名存档分支
10. 推送存档分支到 GitHub
11. 检查新功能是否需要更新 `README.md` 的特性说明
12. 执行 `pod trunk push MMTToolForAppTrans.podspec --allow-warnings` 发布到 CocoaPods
13. 验证提交、Tag、分支是否全部存在

## 标准提交信息

- `release: <版本号>`
- 示例：`release: 0.6.9`

## 标准命令

按版本号 `0.6.9` 为例：

```bash
git add -A
git commit -m "release: 0.6.9"
git push origin main
git tag 0.6.9
git push origin refs/tags/0.6.9
git branch 0.6.9
git push origin refs/heads/0.6.9
pod trunk push MMTToolForAppTrans.podspec --allow-warnings
```

## 可选文档同步 Tag

当发布后仅同步文档时可使用轻量 Tag。

- Tag 格式：`docs-v<版本号>-sync`
- 示例：`docs-v0.6.9-sync`

```bash
git tag docs-v0.6.9-sync
git push origin refs/tags/docs-v0.6.9-sync
```

## 发布前检查

- `MMTToolForAppTrans.podspec` 已更新为当前版本号，且 `s.summary` 和 `s.description` 与最新功能集一致
- `Doc/Version.md` 已新增当前版本记录
- `README.md` 保持英文，功能特性已同步（如需）
- 工作区改动确认无误
- 当前分支为 `main`
- 目标 Tag 不存在
- 目标分支不存在
- `pod lib lint` 通过

## 发布后检查

- GitHub 上 `main` 已更新
- GitHub 上存在对应 Tag
- GitHub 上存在同名存档分支
- CocoaPods 上存在对应版本 (`pod search MMTToolForAppTrans`)
- 本地工作区保持干净

## 后续可直接使用的发布指令

后续只需给出类似指令即可开始发布：

```text
发布 0.7.0
按 RELEASE_PROCESS.md 执行
```

如果需要补充版本说明，可一并提供：

```text
发布 0.7.0
按 RELEASE_PROCESS.md 执行
版本说明：
- 新增 xxx
- 修复 xxx
```
