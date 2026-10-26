# moon-geo · 统一空间数学引擎

> MoonBit 实现的开源学术驱动统一空间数学引擎。技术规范见 `../geo 统一空间数学引擎 · 开发立项技术规范.md`，迭代详表见 `../geo 统一空间数学引擎 · 迭代计划详表.md`。

## 0. 项目定位

- **双层架构**：后端库（统一空间数学引擎）+ 前端（数据处理平台）
  - **后端库**：以复射影代数几何 + 代数拓扑为底层内核，覆盖全维度/全数域/全空间类型/全拓扑形态的通用空间数学引擎（九层洋葱，终身稳定，不感知数据模型/CRS/I/O）——对标 CGAL / GEOS / Shapely
  - **前端平台**：`platform/` 数据处理平台，承载要素/图层/数据集 + CRS + 格式 I/O + 流式/LOD，调用后端内核算法——对标 GDAL / PostGIS / ArcGIS
- **性质**：开源社区战略 · 学术驱动（Apache-2.0），核心永久开源
- **周期**：2026 → 2046（20年/240月），4 纪元 × 5 年，核心架构终身稳定
- **竞品参照**：CGAL / OpenCASCADE / ArcGIS / GEOS / Shapely / Boost.Geometry / GDAL / Lean4-Coq 几何库
- **终极愿景**：范畴化空间数学范式的定义者 + 空间数据处理基础设施

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

### 1.1 数据处理平台（前端）架构

`platform/` 前端依赖后端九层内核，后端不感知前端。承载真实业务数据类型（点云/倾斜摄影/正射影像/栅格/矢量/CAD/3D 模型）的数据模型、CRS、格式 I/O 与大规模流式处理。

| 层 | 包名 | 职责 | 依赖 | 对应缺口 |
|----|------|------|------|---------|
| P1 | `platform/crs` | CRS/EPSG/投影变换（WGS84/UTM/CGCS2000） | util, space | D |
| P2 | `platform/mesh` | IndexedMesh（顶点+索引+法向+UV+材质）+ 网格简化/法向重算 | util, space, bv, brep | B, F |
| P3 | `platform/pcloud` | PointCloud + 属性通道 + 降采样/法向/地面滤波/RANSAC/ICP | util, space, bv, mesh | 点云 |
| P4 | `platform/data` | Feature/Layer/Dataset/Field + RasterDataset/Tiled/Pyramid + StreamingReader/LODTree | space, brep, mesh, pcloud, crs | A, C, E |
| P5 | `platform/io` | 格式 I/O（LAS/GeoTIFF/shp/DXF/OBJ/GLTF/OSGB/3DTiles）+ 流式读写 | data, crs | I/O |

**时序铁律**：I/O 格式读写（P5）不能先于其数据模型（P4）和 CRS（P1）。必须先建数据模型与 CRS，再建格式 I/O，否则读出的数据无坐标无属性，是废数据。

## 2. 核心设计原则

1. **Trait 驱动**：每层用统一 Trait 定义行为，新增图元/空间类型只需实现 Trait，算法自动复用
2. **内外分离**：内核保留完整数学完备性（复/射影/高维），对外暴露极简实数域工程 API
3. **终身兼容**：核心 Trait 第一阶段冻结后永久稳定，新增能力只扩展不修改，无破坏性变更
4. **开闭统一**：代数给形状，拓扑定开闭，开闭定体面
5. **不可变原则**：几何/拓扑对象默认不可变，修改操作返回新对象
6. **公差原则**：所有几何比较使用近似相等，禁止直接 `==` 比较浮点数。提供三层公差：`dbl_approx_eq`（绝对）、`rel_approx_eq`（相对）、`mixed_approx_eq`/`ctx_approx_eq`（混合，推荐默认）。`GeoContext` 封装精度配置（Engineering/Surveying/Game/Custom）。详见 [ADR-003](docs/adr/003-precision-strategy.md)
7. **错误处理**：可能失败的操作返回 `Result<T, GeoError>` 或 `raise GeoError`，禁止 panic。`GeoError` 含错误码（`GeoErrorCode`）+ 结构化上下文 + 可选恢复建议
8. **前后端分离**：后端九层处理纯数学空间的几何/拓扑/代数运算，不感知数据模型/CRS/I/O；前端 `platform/` 层承载数据模型/CRS/格式 I/O，将业务数据拆解为几何对象委托后端计算，再包装回业务数据模型
9. **时序铁律**：I/O 格式读写不能先于其数据模型和 CRS——先建数据模型（Feature/Layer/Dataset）与 CRS，再建格式 I/O，否则读出无坐标无属性的裸几何是废数据

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

已完成：
- `0.1.1.0`（2026-01）：项目脚手架 + `util/num.mbt` + `util/cpx.mbt` + CRAP/变异测试工具
- `0.1.1.1`（2026-02）：`util/vec.mbt`（Vec2/Vec3）+ `util/mat.mbt`（Mat3/Mat4）+ `util/quat.mbt`（Quat）
- `0.1.1.2`（2026-03）：`util/poly.mbt`（Poly1/PolyN）+ `atop/`（TopologicalSpace/MetricSpace/Manifold/Dim Trait）
- `0.1.1.3`（2026-04）：`space/`（Space Trait + Euclid2 + SpaceKind）+ atop trait 改 `pub(open)` 允许跨包实现
- `0.1.1.4`（2026-05）：`space/`（Euclid3 + SpaceMap Trait + Embed2In3 + Project3To2）+ 变异测试扩展至 space 包
- `0.1.1.5`（2026-06）：`alg/`（Geo Trait + Pt2/Pt3 + Line2）+ 前瞻性审查完善（精度策略/GeoContext/GeoError/Logger/CI/ADR/CONTRIBUTING/FFI RFC）
- `0.1.1.6`（2026-07）：`alg/`（Circle + Conic2 + discriminant + ConicType 分类）
- `0.1.1.7`（2026-08）：`alg/`（Plane3 + Sphere + Quad3 + 幂定理 power/tangent_length）
- `0.1.1.8`（2026-09）：`alg/`（intersect_line_circle + intersect_circle_circle + Transform2/3）

本月任务包（2026-10，`0.1.1.9`）：
- `bv/`：Bv Trait + Aabb2/Aabb3 + SphereBv + BVH
- 验收：包围体 + 层级树 + 碰撞加速测试

后续月度任务见迭代详表。核心 Trait 在 2026-12（`0.1.1.11`）冻结。

**前端平台时序**（据业务适配性评估调整）：`platform/crs` CRS + `platform/data` 要素模型提前到 2027-04/05（先于格式 I/O）；`platform/mesh` + `platform/pcloud` 落在 2028；`platform/data` RasterDataset + 流式 + `platform/io` LAS 落在 2029。详见迭代详表 2027-2029 年。

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

### 6.6 多手段测试

**每轮迭代收尾时，必须按下表选择适用手段执行，不得跳过。**

| 测试手段 | 职责 | 适用场景 | 执行方式 |
|----------|------|----------|----------|
| **形式化证明** | 校验代码逻辑性质，SMT 求解器证明证明义务 | 核心数学定理、不变量、循环正确性 | `moon prove`（见 §6.6.1） |
| **AI 测试** | 用 AI 智能体模拟工作流执行，验证设计可行性 | 工作流设计、算子语义、用户场景模拟 | 人工触发 AI 智能体或脚本驱动 |
| **FAKE 测试** | 构造假数据结构，验证输出契约字段完整可构造 | 数据结构定义、类型完备性 | 构造最小合法/非法实例，断言字段完备 |
| **MOCK 测试** | mock 外部依赖组件，验证编排逻辑正确 | 工作流编排、接口调用顺序 | 替换外部依赖为 stub，验证调用序列 |
| **E2E 测试** | 端到端模拟完整流程，验证多组件串联闭环 | 用户需求 → 最终输出的完整链路 | 构造端到端用例，验证输入→输出闭环 |

**适用矩阵**（按迭代类型选择必跑手段）：

| 迭代类型 | 形式化证明 | AI 测试 | FAKE 测试 | MOCK 测试 | E2E 测试 |
|----------|-----------|---------|-----------|-----------|----------|
| util/atop（纯数学） | ✅ 核心 | — | ✅ 类型 | — | — |
| space/alg（空间代数） | ✅ 核心 | — | ✅ 类型 | — | ✅ 链路 |
| bv/brep（拓扑结构） | 可选 | ✅ 工作流 | ✅ 结构 | ✅ 编排 | ✅ 链路 |
| algo/parallel（算法） | 可选 | ✅ 工作流 | — | ✅ 依赖 | ✅ 链路 |
| domain/eco（业务） | — | ✅ 场景 | — | ✅ 接口 | ✅ 链路 |

#### 6.6.1 形式化验证（moon prove）

MoonBit 通过 `moon prove` 提供实验性的形式化验证支持，借助 SMT 求解器（z3/cvc5/alt-ergo）证明生成的证明义务。

**启用方式**：在包的 `moon.pkg` 中添加 `proof_enabled = true`。

**源码布局**：
- `.mbt`：可执行代码 + 契约（`proof_require`/`proof_ensure`/`proof_assert`）+ 循环不变量
- `.mbtp`：逻辑侧谓词（`predicate`）、引理（`lemma`）、抽象模型

**关键语法**：

```moonbit
// .mbtp：逻辑侧谓词
predicate sorted(xs : FixedArray[Int32]) {
  ∀ i : Int32, ∀ j : Int32,
    in_bounds(xs, i) && in_bounds(xs, j) && (i <= j) → xs[i] <= xs[j]
}

// .mbt：程序侧函数 + 契约
pub fn binary_search(xs : FixedArray[Int32], key : Int32) -> Int32? where {
  proof_require: sorted(xs),
  proof_ensure: result => binary_search_ok(xs, key, result),
} {
  // ... 可执行实现 ...
  // proof_assert 记录中间事实
  // 循环 where { proof_invariant: ..., proof_yield: ..., proof_reasoning: ... }
}
```

**证明注解速查**：

| 注解 | 位置 | 用途 |
|------|------|------|
| `proof_require` | 函数 `where` 块 | 前置条件 |
| `proof_ensure` | 函数 `where` 块 | 后置条件（`result` 指代返回值） |
| `proof_assert` | 函数体内 | 中间事实，辅助求解器 |
| `proof_invariant` | 循环 `where` 块 | 循环不变量 |
| `proof_yield` | 循环 `where` 块 | `break` 产出值必须满足的事实 |
| `proof_reasoning` | 循环 `where` 块 | 面向证明的文字说明 |
| `proof_decrease` | 递归函数 | 终止度量 |
| `proof_axiomatized` | 函数/引理 | 假定成立（标记可信边界） |
| `#proof_pure` | 函数属性 | 纯函数，程序侧+逻辑侧共用 |
| `#proof_external` | 类型属性 | 映射到 Why3 外部理论类型 |
| `#proof_import` | 函数属性 | 声明 Why3 符号 stub |

**运行**：`moon prove`（全模块）或 `moon prove path/to/package`（单包）。

**可信边界**：
- 证明推理的是**数学整数**（无界），不建模运行时溢出——需显式范围约束
- `proof_axiomatized` 声明作为假设，不被证明，属于可信边界
- `#proof_external`/`#proof_import` 的 Why3 映射正确性属于可信边界

**项目要求**：
- util/atop 层核心数学定理（如度量公理、多项式运算性质）优先用 `moon prove` 验证
- 证明文件放 `<package>/<module>.mbtp`，与可执行代码同包
- 当前阶段（0.1.1.z）形式化验证为**可选增强**，0.1.2.z 起对核心 Trait 逐步启用
- 环境依赖：Why3 1.7.2（opam 安装）+ z3/cvc5/alt-ergo 至少一个

#### 6.6.2 AI 测试

- 用 AI 智能体模拟工作流执行，验证设计可行性
- 适用：工作流设计、算子语义、用户场景模拟
- 执行：构造场景描述 → AI 智能体执行 → 验证输出符合预期
- 项目要求：brep/algo 层工作流（布尔运算/三角剖分/拓扑修复）迭代时必跑

#### 6.6.3 FAKE 测试

- 构造假数据结构（最小合法/非法实例），验证输出契约字段完整可构造
- 适用：数据结构定义、类型完备性
- 执行：构造实例 → 断言所有字段可访问 → 断言不变量成立
- 项目要求：每新增 struct/enum/trait 时，构造 FAKE 实例验证字段完备

#### 6.6.4 MOCK 测试

- mock 外部依赖组件，验证编排逻辑正确
- 适用：工作流编排、接口调用顺序
- 执行：替换外部依赖为 stub → 验证调用序列与参数
- 项目要求：algo/parallel/domain 层引入外部依赖时必跑

#### 6.6.5 E2E 测试

- 端到端模拟完整流程，验证多组件串联闭环
- 适用：用户需求 → 最终输出的完整链路
- 执行：构造端到端用例（输入 → 经过多层 → 输出）→ 验证闭环
- 项目要求：space→alg→bv→brep→algo 跨层迭代时必跑

### 6.7 文档系统更新与一致性校验

**每轮迭代收尾时，必须执行以下文档维护流程：**

1. **更新迭代详表**：`docs/geo 统一空间数学引擎 · 迭代计划详表.md` 中标记本月任务为 ✅ 已完成
2. **更新 AGENTS.md §5**：更新"已完成"列表和"本月任务包"为下一迭代
3. **更新技术规范**（如有架构变更）：`docs/geo 统一空间数学引擎 · 开发立项技术规范.md`
4. **一致性校验**：
   - AGENTS.md §1 九层架构表 vs 技术规范 §1.3 目录树 → 层级/包名/依赖一致
   - AGENTS.md §5 当前任务 vs 迭代详表当月行 → 版本号/任务包/验收标准一致
   - AGENTS.md §4 版本号 vs `moon.mod` version → 语义一致
   - `.mbti` 接口文件 vs 实际公开 API → `moon info` 生成后无意外 diff
   - 代码 import 依赖 vs 架构依赖铁律 → 无反向依赖/同层环依赖
5. **校验报告**：将一致性校验结果记入迭代收尾报告（见 §6.8 步骤 7）

### 6.8 迭代收尾流程（每次迭代必须执行，不得跳过）

**每轮迭代（每月任务包）完成后，必须按以下顺序执行收尾流程：**

| 步骤 | 内容 | 命令/工具 | 通过标准 |
|------|------|-----------|----------|
| 1 | 类型检查 | `moon check` | 0 errors |
| 2 | 全量测试 | `moon test` | 全部 passed |
| 3 | 格式化 + 接口 | `moon fmt && moon info` | 无意外 .mbti diff |
| 4 | CRAP 指标 | `bash tools/crap_report.sh` | 高风险函数记录并制定降级计划 |
| 5 | 变异测试 | `bash tools/mutation_test.sh` | MS ≥ 90% |
| 6 | 多手段测试 | 按 §6.6 适用矩阵选择 | 适用手段全部通过 |
| 7 | 文档更新 + 一致性校验 | 按 §6.7 执行 | 校验全部通过 |
| 8 | 生成收尾报告 | 文本输出 | 含版本号/测试数/CRAP/MS/校验结果 |
| 9 | Git 提交 | `git add -A && git commit` | 含版本号和收尾摘要 |

**自动进入下一阶段**：步骤 1-9 全部通过后，自动开始下一迭代（下一月任务包），无需等待用户确认。仅在以下情况暂停等待用户决策：
- 高风险函数 CRAP > 10 且无法通过补测降级
- 变异测试 MS < 90% 且存活变异体非等效变异
- 一致性校验发现架构违规（反向依赖/环依赖）
- 形式化证明失败且无法修复
- 需要用户决策的架构设计选择

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
