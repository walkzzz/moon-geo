// 包围体核心 Trait
// 第3层 bv，依赖 util, alg
// Bv Trait：统一包围体接口（体积 + 空判定）
// 具体类型（Aabb2/Aabb3/SphereBv）各自提供 contains/intersect/union 等类型安全方法

///|
/// 包围体 Trait
pub(open) trait Bv {
  /// 体积（2D 为面积，3D 为体积）
  fn bv_volume(self : Self) -> Double

  /// 是否为空/退化
  fn bv_is_empty(self : Self) -> Bool
}
