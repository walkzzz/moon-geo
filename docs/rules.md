# moon-geo 开发规则全集 / Development Rules

> **用途**：本文件是 moon-geo 项目所有开发规则的权威汇总，供 agent 与人类协作者复用。
> **维护**：每次新增规则时回写本文件。
> **项目根包**：`walkzzz/moon-geo`（MoonBit 模块）
> **技术规范**：`docs/geo 统一空间数学引擎 · 开发立项技术规范.md`
> **迭代详表**：`docs/geo 统一空间数学引擎 · 迭代计划详表.md`
> **工程规约**：`AGENTS.md`（§0-§8，含 CRAP/变异/多手段测试/迭代收尾流程）

---

## 一、项目规则 / Project Rules

### R1 — 源码目录
按九层洋葱架构组织，每层一个包目录（`util/`、`atop/`、`space/`、`alg/`、`bv/`、`brep/`、`algo/`、`parallel/`、`domain/`、`eco/`）。包内 `.mbt` 源文件按模块功能命名（小蛇形）。无 `src/` 目录。

### R2 — 多手段测试
形式化证明（`moon prove`）+ AI/FAKE/MOCK/E2E 多手段测试，详见 `AGENTS.md` §6.6。每次迭代收尾跑 `moon check` 0 error、`moon test` 全通过、CRAP + 变异测试，详见 `AGENTS.md` §6.8。

### R3 — 代码文档注释
代码三级文档注释（包级、类型级、方法级）。所有 `pub fn` 必须有 `///` 注释。

### R4 — README 规范
README 中英文，默认中文。当前 `README.mbt.md` 为项目 README。

### R5 — 迭代路线
按 `docs/geo 统一空间数学引擎 · 迭代计划详表.md` 月度任务包推进，版本号 `0.x.y.z`。

### R6 — 提交查证
每个任务包完成后按 `AGENTS.md` §6.8 迭代收尾流程执行，commit 包含版本号和收尾摘要。

### R7 — 自动迭代触发
测试全绿 + 收尾流程全通过后，自动进入下一迭代，无需等待用户确认。

---

## 二、架构规则 / Architecture Rules

### R8 — 九层单向依赖
`util(-1) → atop(0) → space(1) → alg(2) → bv(3) → brep(4) → algo(5) → parallel(6) → domain(7) → eco(8)`。禁止反向依赖、禁止同层环依赖。详见 `AGENTS.md` §1。

### R9 — Trait 驱动
每层用统一 Trait 定义行为，新增类型只需实现 Trait，算法自动复用。核心 Trait 2026-12 冻结后终身兼容。

### R10 — 包结构
每个包目录含 `moon.pkg`（依赖声明）+ `.mbt` 源文件 + `*_test.mbt`（黑盒测试）+ `*_wbtest.mbt`（白盒测试）。公开接口由 `moon info` 生成 `.mbti`。

---

## 三、迭代流程 / Iteration Flow

### R11 — 月度任务包
每月一个任务包，版本号 `z` 递增。详见迭代详表。

### R12 — 收尾流程
每次迭代完成后按 `AGENTS.md` §6.8 执行 9 步收尾流程：check → test → fmt/info → CRAP → 变异测试 → 多手段测试 → 文档更新+一致性校验 → 收尾报告 → Git 提交。

---

## 四、当前进度 / Current Progress

**纪元一·奠基纪元 → 阶段一·基础可用（2026）→ 版本 `0.1.1.z`**

| 版本 | 任务 | 状态 |
|------|------|------|
| `0.1.1.0` | util num/cpx + CRAP/变异工具 | ✅ |
| `0.1.1.1` | util vec/mat/quat | ✅ |
| `0.1.1.2` | util poly + atop 拓扑空间 Trait | ✅ |
| `0.1.1.3` | space Space Trait + Euclid2 + Dim | 进行中 |

测试：71 通过 · CRAP：115 · 变异分数：100%

---

## 五、通用研发质量规约 / Quality Standards

### Q1 — 浮点比较
所有浮点比较使用 `ApproxEq`，禁止裸 `==` 比浮点。公差 `EPS = 1.0e-8`。

### Q2 — 错误处理
可能失败的操作返回 `Result<T, Error>` 或 `raise Error`，禁止 panic。

### Q3 — 不可变原则
几何/拓扑对象默认不可变，修改操作返回新对象。

### Q4 — 命名规范
大驼峰（struct/Trait）、小蛇形（函数/文件/包）、全大写下划线（常量）。详见 `AGENTS.md` §3。

### Q5 — 构建命令
```bash
moon check    # 类型检查
moon test     # 运行测试
moon fmt      # 格式化
moon info     # 生成 .mbti
moon prove    # 形式化验证（需 Why3 + SMT 求解器）
```
