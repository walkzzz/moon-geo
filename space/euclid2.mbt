// 二维欧氏空间
// 点类型 Euclid2，实现 Space Trait（Dim + MetricSpace + TopologicalSpace + Space）

///|
/// 二维欧氏空间点
pub struct Euclid2 {
  x : Double
  y : Double
}

///|
pub fn Euclid2::new(x : Double, y : Double) -> Euclid2 {
  { x, y, }
}

///|
pub fn Euclid2::x(self : Euclid2) -> Double {
  self.x
}

///|
pub fn Euclid2::y(self : Euclid2) -> Double {
  self.y
}

///|
/// 维度 = 2
impl @atop.Dim for Euclid2 with fn dim(_) {
  2
}

///|
/// 度量诱导邻域：distance(self, center) <= radius
impl @atop.TopologicalSpace for Euclid2 with fn is_in_neighborhood(
  self,
  center,
  radius,
) {
  @atop.MetricSpace::distance(self, center) <= radius
}

///|
/// 欧氏距离 sqrt(dx^2 + dy^2)
impl @atop.MetricSpace for Euclid2 with fn distance(self, other) {
  let dx = self.x - other.x
  let dy = self.y - other.y
  (dx * dx + dy * dy).sqrt()
}

///|
/// 空间类型标识
impl Space for Euclid2 with fn space_kind(_) {
  SpaceKind::Euclidean2
}

///|
pub extend Euclid2 with Space::{space_kind}
