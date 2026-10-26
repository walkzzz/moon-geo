# ADR-003：混合公差精度策略

**状态**：已接受  
**日期**：2026-10  
**决策者**：项目创始人  

## 背景

前瞻性审查 §1.1 指出：固定 EPS=1e-8 在全局尺度坐标、级联运算、大尺度点云场景必然失效。需引入自适应精度策略。

## 决策

引入三层公差体系：

1. **绝对公差** `dbl_approx_eq(a, b, tol)`：`|a-b| <= tol`（已有，小量场景）
2. **相对公差** `rel_approx_eq(a, b, rel_tol)`：`|a-b| <= max(|a|,|b|) * rel_tol`（大尺度场景）
3. **混合公差** `mixed_approx_eq(a, b, abs_tol, rel_tol)`：`|a-b| <= max(abs_tol, max(|a|,|b|) * rel_tol)`（推荐默认）

引入 `GeoContext` 结构体封装精度配置：
- `PrecisionMode`：Engineering(1e-8) / Surveying(1e-10) / Game(1e-4) / Custom
- `ctx_approx_eq(a, b, ctx)`：在给定上下文下用混合公差判定

## 理由

- **相对公差**：WGS84 经纬度与 UTM 米坐标混算时，公差随量级自适应
- **混合公差**：兼顾小量绝对精度和大量相对精度，Python `math.isclose` 同此策略
- **GeoContext**：不同应用场景需不同精度，全局常量无法适应；context 参数化避免全局可变状态

## 否决的方案

1. **纯相对公差**：当 a=b=0 时 max(|a|,|b|)=0，公差为 0，无法判定——必须混合
2. **区间算术**：每量携带 [lo,hi]，三值判定——正确但实现复杂、性能开销大，远期评估
3. **精确谓词（CGAL 方案）**：关键判定用任意精度有理数——MoonBit 无大整数库，远期评估

## 影响

- 新增算法推荐用 `ctx_approx_eq` 或 `mixed_approx_eq` 替代 `dbl_approx_eq`
- 现有代码保持 `dbl_approx_eq` 兼容，逐步迁移
- 远期评估区间算术和精确谓词路径
