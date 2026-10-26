# ADR-004: pub extend dot syntax 与良性警告分类

> **状态**：已接受
> **日期**：2026-10-26
> **关联**：ADR-002（pub(open) trait + trait object）

## 背景

ADR-002 论证了 `pub(open) trait` 允许跨包实现和 trait 对象的 tradeoff，但未覆盖 `pub extend` 语法。全项目 20+ 处使用 `pub extend Type with Trait::{method1, method2}`，需要记录此决策。

同时，`moon check` 持续报告 6 个良性警告，需要分类说明以避免反复排查。

## 决策

### pub extend dot syntax

对每个 `impl Trait for Type` 声明，配套添加 `pub extend Type with Trait::{method1, method2}`，将 trait 方法提升为类型的公开方法。

**理由**：
1. 启用点语法 `x.method()` 替代 `Trait::method(x)`，提高可读性
2. 显式列出实现的方法名，作为文档级的 impl 清单
3. 黑盒测试可直接 `x.method()` 调用，无需 `Trait::method(x)` 全限定
4. 与 `pub(open) trait` 配合：open trait 允许跨包 impl，pub extend 让 impl 方法对外可用

**代价**：
- 每个类型多一行声明，代码量略增
- 方法名在 impl 和 extend 中各出现一次，修改时需同步

### 良性警告分类（P2-12）

| 警告码 | 含义 | 数量 | 处理 |
|--------|------|------|------|
| `[0029]` | unused_package | 2 | atop/space 保留 util dep 供测试文件引用 `@util.X`，源码中不直接引用 |
| `[0001]` | unused_value (unused trait implementation) | 4 | trait impl 被 `pub extend` 和白盒测试使用，编译器看不到跨文件/trait object 使用 |

**处理策略**：这些为 MoonBit 编译器的 false positive，无法通过 `//warning-off` 局部抑制（moon 0.1.20261020 不支持）。接受为良性警告，不强行消除。

## 后续

- 若 MoonBit 后续版本支持 `#allow` 或 `warning-off` 注解，可局部抑制
- trait 契约约束（防止错误 impl）待 trait test 机制引入后补充
