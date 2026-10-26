// Space 核心Trait
// 第1层 space，依赖 atop（MetricSpace/Dim/TopologicalSpace）
// Space = 有度量 + 有维度的空间，统一空间接口
// Self = 点类型；具体空间（欧氏/复/射影/球面/栅格）实现此 Trait

///|
/// 空间类型标识
pub enum SpaceKind {
  Euclidean2
  Euclidean3
  Complex2
  Projective3
  Spherical3
  Raster2
}

///|
/// Space Trait：统一空间接口
/// 继承 MetricSpace（有距离）+ Dim（有维度），加空间类型标识
pub(open) trait Space: @atop.MetricSpace + @atop.Dim {
  /// 空间类型标识
  fn space_kind(self : Self) -> SpaceKind
}
