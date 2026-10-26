# ADR-002：Trait 驱动 + pub(open) 跨包实现

**状态**：已接受  
**日期**：2026-03  
**决策者**：项目创始人  

## 背景

MoonBit 的 trait 系统与 Rust trait 有差异。需确定 trait 设计策略，确保跨包可实现、API 可导出、测试可验证。

## 决策

1. **Trait 驱动**：每层用统一 Trait 定义行为，新增类型只需实现 Trait，算法自动复用
2. **`pub(open) trait`**：需要跨包实现的 trait 声明为 `pub(open)`，允许下游包 `impl`
3. **白盒测试跨包 trait**：跨包 trait impl 用白盒测试（`*_wbtest.mbt`）验证，黑盒测试看不到包内 impl
4. **非泛型 trait**：MoonBit 不支持泛型 trait（`trait[T]`），需要泛型的方法由具体类型提供

## 理由

- `pub trait` 对外部包是 readonly，下游不能 impl——必须 `pub(open)`
- 黑盒测试是外部视角，看不到包内 `impl @pkg.Trait for LocalType`——必须白盒测试
- MoonBit 0.1.x 不支持 `trait[T]` 语法（编译报错）——泛型需求改为非泛型 trait + 具体类型方法

## 否决的方案

1. **`pub(app) trait`**：MoonBit 不支持此修饰符在 trait 位置使用
2. **trait object 动态分发**：MoonBit 无关联类型，且动态分发有性能开销
3. **泛型函数替代泛型 trait**：部分可行但失去 trait 的多态能力

## 影响

- 所有需要跨包实现的 trait 必须用 `pub(open) trait`
- 跨包 trait 测试统一用白盒测试
- 泛型需求（如 SpaceMap[Src, Dst]）改为非泛型 trait（元数据接口）+ 具体类型提供泛型方法
