# moon-geo · 统一空间数学引擎

> MoonBit 实现的开源学术驱动统一空间数学引擎。技术规范见 `../geo 统一空间数学引擎 · 开发立项技术规范.md`，迭代详表见 `../geo 统一空间数学引擎 · 迭代计划详表.md`。

## 0. 项目定位

- **一句话**：以复射影代数几何 + 代数拓扑为底层内核，覆盖全维度/全数域/全空间类型/全拓扑形态的通用空间数学引擎
- **性质**：开源社区战略 · 学术驱动（Apache-2.0），核心永久开源
- **周期**：2026 → 2046（20年/240月），4 纪元 × 5 年，核心架构终身稳定
- **竞品参照**：CGAL / OpenCASCADE / ArcGIS / GEOS / Shapely / Boost.Geometry / Lean4-Coq 几何库
- **终极愿景**：范畴化空间数学范式的定义者

## 1. 九层单向依赖架构

洋葱型分层，内层更稳定抽象，外层更灵活业务；上层只能依赖下层，下层不感知上层。

| 层 | 包名 | 职责 | 依赖 |
|----|------|------|------|
| -1 | `util` | 数域/数值/矩阵/精度体系 | 无 |
| 0 | `atop` | 拓扑空间/流形/范畴化抽象 | util |
| 1 | `space` | 欧氏/复/射影/非欧/时空/栅格 | util, atop |
| 2 | `alg` | 代数簇/变换/不变量/求交 | util, space |
| 3 | `bv` | 全类型包围体/空间索引树 | util, alg |
| 4 | `brep` | 流形/非流形/胞腔复形/奇异拓扑 | alg, bv |
| 5 | `algo` | 基础几何/GIS/高阶拓扑/优化 | alg, brep, bv |
| 6 | `parallel` | CPU多线程/GPU/分布式 | algo |
| 7 | `domain` | CAD/GIS/仿真/视觉/机器人 | algo |
| 8 | `eco` | 语言绑定/格式兼容/引擎对接 | domain |

**依赖铁律**：禁止反向依赖、禁止同层环依赖、外部依赖经评审才引入。

## 2. 核心设计原则

1. **Trait 驱动**：每层用统一 Trait 定义行为，新增图元/空间类型只需实现 Trait，算法自动复用
2. **内外分离**：内核保留完整数学完备性（复/射影/高维），对外暴露极简实数域工程 API
3. **终身兼容**：核心 Trait 第一阶段冻结后永久稳定，新增能力只扩展不修改，无破坏性变更
4. **开闭统一**：代数给形状，拓扑定开闭，开闭定体面
5. **不可变原则**：几何/拓扑对象默认不可变，修改操作返回新对象
6. **公差原则**：所有几何比较使用近似相等，禁止直接 `==` 比较浮点数
7. **错误处理**：可能失败的操作返回 `Result<T, GeoError>` 或 `raise GeoError`，禁止 panic

## 3. 命名与编码规范

### 3.1 命名规则

| 元素 | 规则 | 示例 |
|------|------|------|
| 结构体/枚举/Trait | 大驼峰，短名词，领域通用缩写 | `Pt3`, `Quad3`, `Geo`, `Topo` |
| 函数/方法 | 小蛇形，动词开头 | `new`, `is_closed`, `transform` |
| 模块/文件 | 小蛇形 | `quadric.mbt`, `topo_relate.mbt` |
| 常量 | 全大写下划线 | `EPS`, `MIN_POSITIVE` |
| 包/目录 | 小蛇形 | `util`, `atop`, `brep` |

### 3.2 MoonBit 编码约定（项目专属）

- 顶层块用 `///|` 分隔，块顺序无关
- `fn` 私有，`pub` 暴露读取，`pub(all)` 允许外部构造
- 浮点统一用 `Double`（MoonBit 内置双精度），规范文档中 `F64` 即 `Double`
- 错误类型用 `suberror GeoError { ... }` 定义
- 废弃代码放 `deprecated.mbt`
- 禁止 `++`/`--`，用 `i += 1`
- 调试用 `Debug` + `debug_inspect`，不派生 `Show`（除非需自定义显示格式）

## 4. 版本号规约 `0.x.y.z`

| 段 | 名称 | 语义 | 取值 |
|----|------|------|------|
| 第1段 | 主版本 | 20年规划期保持 `0`，终极愿景达成升 `1` | `0`→`1` |
| 第2段 `x` | 纪元号 | 纪元编号 | `1`-`4` |
| 第3段 `y` | 阶段号 | 纪元内阶段编号 | `1`-`N` |
| 第4段 `z` | 迭代号 | 阶段内迭代（月/季度）递增 | `0`-`N` |

- `x` 递增（纪元跃迁）：允许 Level 2/3 API 变更，Level 1 保持兼容
- `y` 递增（阶段递进）：Level 1/2 保持兼容，新增能力
- `z` 递增（迭代）：全 Level 兼容，仅修复与增量实现
- 兼容 SemVer：`major=0, minor=x, patch=y`，`z` 为预发布迭代标识

## 5. 当前阶段与任务

**纪元一·奠基纪元（2026-2031）→ 阶段一·基础可用（2026）→ 版本 `0.1.1.z`**

本月任务包（2026-01，`0.1.1.0`）：
- 项目脚手架 + `util/num.mbt`（数值扩展、近似相等、公差管理）
- `util/cpx.mbt`（复数类型与全量运算）
- 验收：util 单测通过

后续月度任务见迭代详表。核心 Trait 在 2026-12（`0.1.1.11`）冻结。

## 6. 工程保障

### 6.1 验证命令（每次改动后必跑）

```bash
moon check          # 类型检查（快速）
moon test           # 运行测试
moon fmt            # 格式化
moon info           # 生成 .mbti，检查公开 API 变更
```

### 6.2 测试约定

- 每层独立单测，核心数学定理 100% 用例覆盖
- 黑盒测试（`*_test.mbt`）测公开 API，白盒测试（`*_wbtest.mbt`）测私有成员
- 数值断言用 `assert_true(x.approx_eq(y, tol))`，禁止 `assert_eq` 比浮点
- 快照测试用 `inspect`/`debug_inspect` + `moon test --update`
- 极端边界、退化场景全覆盖

### 6.3 质量保障

- 基准对标 CGAL/ArcGIS/OpenCASCADE
- 模糊测试挖掘边界崩溃
- 每版本全量回归

### 6.4 CRAP 指标分析

- **公式**：`CRAP(m) = comp(m)² + comp(m) × (1 - cov(m))`（comp=圈复杂度，cov=覆盖率）
- **工具**：`moon run tools/crap_report.mbtx`（基于 `moon coverage analyze` + 函数复杂度表）
- **阈值**：CRAP ≤ 1 低风险，≤ 5 中风险，> 5 高风险（需优先补测或重构）
- **要求**：每个任务包收尾时跑 CRAP，高风险函数必须补测降级；覆盖率数据同步到 `crap_report.mbtx` 的函数表

### 6.5 变异测试

- **工具**：`bash tools/mutation_test.sh`（对源码应用预定义变异，跑 `moon test` 验证捕获）
- **变异分数**：`MS = killed / total × 100%`，目标 ≥ 90%
- **变异点**：运算符翻转（+↔-、*↔/）、常量取反、条件边界、删判断
- **要求**：核心数学运算（求交/幂定理/布尔等）每个任务包跑变异测试；存活变异体需补测或标注等效变异
- **注**：Windows 环境下 `.mbtx` 工具脚本易遇 `.moon/cache/deps` 锁定，工具脚本优先用 bash

---

## 7. MoonBit 项目结构（通用）

This is a [MoonBit](https://docs.moonbitlang.com) project. Browse and install extra skills at <https://github.com/moonbitlang/skills>.

- MoonBit packages are organized per directory; each directory contains a `moon.pkg` file listing its dependencies. Each package has its files, blackbox test files (ending in `_test.mbt`) and whitebox test files (ending in `_wbtest.mbt`).
- In the toplevel directory, there is a `moon.mod` file listing module metadata.
- MoonBit code is organized in block style, each block is separated by `///|`, the order of each block is irrelevant.
- Try to keep deprecated blocks in file called `deprecated.mbt` in each directory.

## 8. MoonBit 工具链（通用）

- `moon fmt` — format code
- `moon ide` — project navigation (`peek-def`, `outline`, `find-references`, `hover`, `rename`, `doc`)
- `moon info` — update generated `.mbti` interface; review diffs to detect public API changes
- `moon test` — run tests; `moon test --update` refreshes snapshots
- `moon check` — type check without building (fast, use regularly)
- Prefer `assert_eq` or `assert_true(pattern is Pattern(...))` for stable results. For debugging output, derive `Debug` and use `debug_inspect`. For scientific computations, prefer assertion tests.
- In the last step, run `moon info && moon fmt` to update interface and format. Check `.mbti` diffs.
