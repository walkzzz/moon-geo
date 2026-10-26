// 三维欧氏空间
// 点类型 Euclid3，实现 Space Trait（Dim + MetricSpace + TopologicalSpace + Space）

///|
/// 三维欧氏空间点
pub struct Euclid3 {
  x : Double
  y : Double
  z : Double
}

///|
pub fn Euclid3::new(x : Double, y : Double, z : Double) -> Euclid3 {
  { x, y, z, }
}

///|
pub fn Euclid3::x(self : Euclid3) -> Double {
  self.x
}

///|
pub fn Euclid3::y(self : Euclid3) -> Double {
  self.y
}

///|
pub fn Euclid3::z(self : Euclid3) -> Double {
  self.z
}

///|
/// 维度 = 3
impl @atop.Dim for Euclid3 with fn dim(_) {
  3
}

///|
/// 度量诱导邻域：distance(self, center) <= radius
impl @atop.TopologicalSpace for Euclid3 with fn is_in_neighborhood(
  self,
  center,
  radius,
) {
  @atop.MetricSpace::distance(self, center) <= radius
}

///|
/// 欧氏距离 sqrt(dx^2 + dy^2 + dz^2)
impl @atop.MetricSpace for Euclid3 with fn distance(self, other) {
  let dx = self.x - other.x
  let dy = self.y - other.y
  let dz = self.z - other.z
  (dx * dx + dy * dy + dz * dz).sqrt()
}

///|
/// 空间类型标识
impl Space for Euclid3 with fn space_kind(_) {
  SpaceKind::Euclidean3
}
