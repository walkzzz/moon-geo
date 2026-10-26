// 度量空间 Trait
// 第0层 atop

///|
/// 度量空间：有距离定义的拓扑空间
/// 公理：非负性 d(a,b)≥0、同一性 d(a,a)=0、对称性 d(a,b)=d(b,a)、三角不等式 d(a,c)≤d(a,b)+d(b,c)
pub trait MetricSpace: TopologicalSpace {
  /// 两点距离
  fn distance(self : Self, other : Self) -> Double
}

///|
/// 度量诱导邻域判定辅助：点 p 在 center 的 radius 球内 ⟺ distance(p,center) ≤ radius
pub fn[M : MetricSpace] in_metric_ball(
  p : M,
  center : M,
  radius : Double,
) -> Bool {
  MetricSpace::distance(p, center) <= radius
}
