# moon-geo 开发对话历史

**会话日期**：2026-10-25
**会话主题**：moon-geo 统一空间数学引擎立项开发（0.1.1.0 → 0.1.1.1）

---

## 1. 项目2. 项目规则与技术规范学习

### 1.1 用户需求
- 为 `D:\codearts\moon-geo` 项目添加规则
- 根据《geo 统一空间数学引擎 · 开发立项技术规范.md》进行开发

### 1.2 技术规范要点
- **定位**：以复射影代数几何 + 代数拓扑为底层内核的通用空间数学引擎
- **周期**：2026 → 2046（20年/240月），4 纪元 × 5 年
- **版本号**：`0.x.y.z`（纪元.阶段.迭代）
- **九层架构**：util → atop → space → alg → bv → brep → algo → parallel → domain → eco
- **当前阶段**：纪元一·阶段一·基础可用（2026，`0.1.1.z`）

### 1.3 MoonBit 技能学习
- 加载 `moonbit-agent-guide`（项目布局/编码/工具链/错误处理/语言特性）
- 加载 `moonbit-orientation`（语言问题解答导向）
- 访问 MoonBit 中文官网 https://www.moonbitlang.cn/
- 掌握关键特性：表达式导向、检查错误、`///|` 分块、`@pkg.fn` 调用、moon check/test/fmt/info/ide 工具链

---

## 2. 0.1.1.0 任务包（2026-01）：项目脚手架 + util num/cpx

### 2.1 AGENTS.md 项目规则
扩充 `moon-geo/AGENTS.md`，加入：
- §0 项目定位 · §1 九层单向依赖架构 · §2 核心设计原则
- §3 命名与编码规范 · §4 版本号规约 `0.x.y.z` · §5 当前阶段与任务
- §6 工程保障（验证命令/测试约定/质量保障/CRAP 指标/变异测试）

### 2.2 util/num.mbt（数值扩展）
- 常量：`EPS = 1.0e-8`、`MIN_POSITIVE = 1.0e-12`
- Trait：`ApproxEq`（approx_eq/approx_zero）、`NumExt`（sq/clamp/lerp）、`Field : NumExt + ApproxEq`（zero/one/abs）
- Double 实现 + 自由函数 `dbl_approx_eq`/`dbl_approx_zero`（供黑盒测试）

### 2.3 util/cpx.mbt（复数全量运算）
- `Cpx` 结构 + `new/from_real/conj/norm_sq/norm/inv/add/sub/mul/div/neg`
- `CpxError`（ZeroInverse/ZeroDivide）
- ApproxEq/NumExt/Field 实现 + `pub extend` 提升方法

### 2.4 踩坑记录（MoonBit 新版语法）
1. `impl Trait for Type with fn method(args) { body }`，每方法单独 impl
2. foreign type（Double）不能 `pub extend`，trait impl 不导出到黑盒测试
3. 浮点字面量需小数点：`1.0e-8` 非 `1e-8`
4. trait 方法参数无 `~` 为位置参数；%参数
5. 无 `Copy` trait；struct 字段默认 public
6. `derive(Eq, Debug)` 需配 `pub extend` 消除 `implicit_impl_as_method` 警告
7. 黑盒测试用 `@util.X` 显式引用消除 `test_unqualified_package` 警告
8. 三角函数在 `@math` 包（`@math.sin(x)`），非 Double 方法

### 2.5 验证
- `moon check` 0 errors · `moon test` 18/18 passed · `moon fmt` + `moon info` 完成

---

## 3. CRAP 指标分析 + 变异测试

### 3.1 CRAP 指标（`tools/crap_report.mbtx`）
- 公式：`CRAP(m) = comp² + comp × (1 - cov)`
- 结果：总 CRAP=50，1 高风险（Double::clamp=9），3 未覆盖（Cpx::sq/clamp/lerp）

### 3.2 变异测试（`tools/mutation_test.sh`）
- 8 个变异点（Cpx::add/norm_sq/mul/conj/inv + approx_eq 运算符翻转）
- **变异分数 MS = 100%（8/8 全杀死）**

---

## 4. 全面修复

### 4.1 补测
- `Cpx::sq/clamp/lerp`（降 CRAP 未覆盖）
- `Cpx::inv/div` 错误路径（ZeroInverse/ZeroDivide）

### 4.2 警告修复
- `test_unqualified_package` → 黑盒测试改用 `@util.X`
- `core_package_not_imported` → moon.pkg 加 debug/math 导入

### 4.3 AGENTS.md 规则补充
- §6.4 CRAP 指标分析（公式/工具:工具/阈值/要求）
- §6.5 变异测试（工具/变异分数/变异点/要求）

### 4.4 验证
- `moon test` 23/23 · CRAP=47 · 变异 MS=100%

---

## 5. 0.1.1.1 任务包（2026-02）：util vec2/vec3/mat3/mat4/quat

### 5.1 util/vec.mbt（Vec2/Vec3）
- Vec2：new/zero/len_sq/len/dot/cross/normalize/add/sub/scale/neg/perp
- Vec3：new/zero/len_sq/len/dot/cross/normalize/add/sub/scale/neg
- ApproxEq 实现 + `pub extend` 提升

### 5.2 util/mat.mbt（Mat3/Mat4）
- Mat3：identity/new/get/det/transpose/mul_vec/mul_mat/inv + MatError
- Mat4：identity/new/translation/scaling/transpose/mul_vec/mul_mat
- ApproxEq 实现（逐元素比较）

### 5.3 util/quat.mbt（Quat）
- new/identity/from_axis_angle/from_euler/mul/conjugate/norm_sq/norm/normalize/to_mat4/slerp
- 使用 `@math.sin`/`@math.cos`/`@math.acos` 自由函数

### 5.4 验证
- `moon check` 0 errors · `moon test` **47/47 passed** · `moon fmt` + `moon info` 完成

---

## 6. 仓库提交

- 提交内容：源代码 + 技能 + 规则 + 文档 + 对话历史
- 目标：https://github.com/walkzzz/moon-geo.git

---

## 交付清单

| 文件 | 内容 |
|------|------|
| `AGENTS.md` | 项目规则（定位/架构/命名/版本/工程保障/CRAP/变异） |
| `util/num.mbt` | 数值扩展 + ApproxEq/NumExt/Field trait |
| `util/cpx.mbt` | 复数全量运算 |
| `util/vec.mbt` | Vec2/Vec3 向量 |
| `util/mat.mbt` | Mat3/Mat4 矩阵 |
| `util/quat.mbt` | Quat 四元数 |
| `util/*_test.mbt` | 黑盒测试（47 个全通过） |
| `util/*_wbtest.mbt` | 白盒测试（foreign type trait impl） |
| `tools/crap_report.mbtx` | CRAP 指标报告 |
| `tools/mutation_test.sh` | 变异测试脚本 |
| `docs/` | 技术规范 + 迭代详表 + 规则 + 对话历史 |
| `skills/` | MoonBit 官方技能集（10 个） |
