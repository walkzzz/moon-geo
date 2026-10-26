# ADR-005：核心 Trait 冻结（0.1.1.12）

**状态**：已接受  
**日期**：2027-01  
**决策者**：项目创始人  

## 背景

经过 12 轮迭代（0.1.1.0 ~ 0.1.1.11），四大核心 Trait 已完备：

- `Geo`（alg）：7 个实现（Pt2/Pt3/Line2/Circle/Conic2/Plane3/Sphere/Quad3）
- `Space`（space）：2 个实现（Euclid2/Euclid3），继承 MetricSpace + Dim
- `Bv`（bv）：3 个实现（Aabb2/Aabb3/SphereBv）
- `Topo`（brep）：3 个实现（HEMesh/Solid/BRep）

0.1.1.11 审查确认接口完备性后，进入冻结。

## 决策

**冻结以下 4 个核心 Trait 的方法签名（至 1.0 发布前）**：

> ⚠️ 0.x 阶段不承诺 API 冻结——接口可能调整。冻结承诺在 1.0 发布后生效。

纪元跃迁时允许 Level 2/3 API 变更（与版本规约 §4 一致）。

### Geo Trait（alg/geo.mbt）
```
fn geo_dim(Self) -> GeoDim
fn is_degenerate(Self) -> Bool
```

### Space Trait（space/space.mbt）
```
// 继承 @atop.MetricSpace + @atop.Dim
fn space_kind(Self) -> SpaceKind
```

### Bv Trait（bv/bv_trait.mbt）
```
fn bv_volume(Self) -> Double
fn bv_is_empty(Self) -> Bool
```

### Topo Trait（brep/topo.mbt）
```
fn topo_dim(Self) -> TopoDim
fn topo_is_closed(Self) -> Bool
fn topo_is_manifold(Self) -> Bool
fn topo_is_oriented(Self) -> Bool
fn topo_is_connected(Self) -> Bool
```

## 冻结策略

1. **方法签名不可变**：不可重命名、不可改参数类型、不可改返回类型、不可删除
2. **可添加默认方法**：`pub(open) trait` 允许添加带默认实现的方法（非破坏性扩展）
3. **新功能放类型方法**：`area`/`length`/`transform`/`bbox`/`contains`/`intersect` 等因 MoonBit 无关联类型，留在具体类型方法
4. **枚举不可删值**：`GeoDim`/`SpaceKind`/`TopoDim` 的已有变体不可删除，可添加新变体
5. **解冻评审门槛**：需累计 3 个独立真实用例证明现有 Trait 无法表达，且默认方法扩展方案已否决，方可启动解冻评审

## 理由

- **纪元一内兼容承诺**：核心 Trait 是整个系统的契约基础，冻结后所有下游代码在纪元一内永久有效
- **审查已确认完备**：0.1.1.11 审查确认每个 Trait 的方法集是该抽象层级的最小完备集
- **MoonBit 无关联类型**：`area`/`contains`/`transform` 等返回类型随维度变化的方法无法统一进 Trait
- **pub(open) 允许安全扩展**：新类型可在下游包实现 Trait；Trait 可添加默认方法
- **留有科学退路**：纪元跃迁时若真实用例证明 Trait 不够用，可按解冻评审门槛启动变更

## 否决的方案

1. **不冻结，持续演进**：核心 Trait 频繁变更会破坏下游所有代码，违背终身兼容承诺
2. **冻结后用版本化 Trait（GeoV2）**：增加复杂度，用户需同时处理多版本接口
3. **冻结全部类型方法**：过度约束，具体类型方法不在兼容承诺范围内

## 影响

- 所有实现 Geo/Space/Bv/Topo 的类型必须提供全部 Trait 方法
- 新增几何类型只需实现 Trait + 类型特化方法，算法自动复用
- 冻结后 PR 改动 Trait 签名需特殊评审流程
- 稳定性测试（`brep_wbtest.mbt` 中的 freeze 测试）验证接口不变
