# 代码提交流程与标准（iOS 项目）

## 1. 提交流程

1. **本地开发**：
   - 拉取最新 `main` 分支代码，确保本地无冲突
   - 按功能/bugfix/资源/文档等逻辑单元开发

2. **代码检查**：
   - 本地运行编译、单元测试（如有）
   - 检查无明显警告和报错

3. **分组提交**：
   - 每个逻辑单元单独 commit，避免一次提交混杂多类改动
   - **功能拆分**：一个功能应拆分为多个小 commit，按步骤逐个提交（如：Model → API → View → 调试），便于回溯和 review
   - **模块拆分**：不同功能模块的改动不应混在同一个 commit 中（如 BBQ 与 Device 模块需分开提交）
   - **Bug 修复**：每个 bug 单独一个 commit，禁止多个 bug 修复混在同一个提交中
   - 资源、配置、证书、文档等建议单独 commit

4. **Commit Message 规范**（推荐 Conventional Commits）：
   - feat(module): 新增功能
   - fix(module): 修复 bug
   - refactor(module): 重构
   - chore(module): 构建/配置/脚本/证书等
   - docs(module): 文档
   - test(module): 测试
   - style(module): 格式/空格/注释等
   - 例：
     - feat(home): add width constraint for device cell layout
     - fix(ai): probe temperature online check
     - chore(project): set code signing to manual

5. **推送与合并**：
   - 本地提交后，推送到远端 main 分支
   - 如需合并其他分支，先 rebase main，确保无冲突

## 2. 代码检查重点

- UI 相关：主线程更新、约束、动画、事件回调
- 业务逻辑：可选值安全、边界处理、日志
- 并发：@MainActor、线程安全
- 资源/证书/配置：单独 commit，避免混杂

## 3. 其他建议

- 避免大提交，优先小步快提
- 提交前自查，减少无效提交
- 遵循现有命名、结构和注释风格
- **全量提交**：除 `.gitignore` 覆盖的文件外，所有有变动的文件均需提交，不得遗漏

---
如需补充/调整标准，请在本文件下方补充说明。
