// 2D 轴对齐包围盒
// 第3层 bv，依赖 util, alg

///|
/// 二维轴对齐包围盒
pub struct Aabb2 {
  min_x : Double
  min_y : Double
  max_x : Double
  max_y : Double
}

///|
pub fn Aabb2::new(
  min_x : Double,
  min_y : Double,
  max_x : Double,
  max_y : Double,
) -> Aabb2 {
  { min_x, min_y, max_x, max_y, }
}

///|
/// 从两点构造（自动确定 min/max）
pub fn Aabb2::from_two_points(p1 : @alg.Pt2, p2 : @alg.Pt2) -> Aabb2 {
  let min_x = if p1.x() < p2.x() { p1.x() } else { p2.x() }
  let max_x = if p1.x() > p2.x() { p1.x() } else { p2.x() }
  let min_y = if p1.y() < p2.y() { p1.y() } else { p2.y() }
  let max_y = if p1.y() > p2.y() { p1.y() } else { p2.y() }
  { min_x, min_y, max_x, max_y, }
}

///|
pub fn Aabb2::min_x(self : Aabb2) -> Double {
  self.min_x
}

///|
pub fn Aabb2::max_x(self : Aabb2) -> Double {
  self.max_x
}

///|
pub fn Aabb2::min_y(self : Aabb2) -> Double {
  self.min_y
}

///|
pub fn Aabb2::max_y(self : Aabb2) -> Double {
  self.max_y
}

///|
/// 点是否在盒内
pub fn Aabb2::contains(self : Aabb2, p : @alg.Pt2) -> Bool {
  p.x() >= self.min_x &&
  p.x() <= self.max_x &&
  p.y() >= self.min_y &&
  p.y() <= self.max_y
}

///|
/// 两盒是否相交
pub fn Aabb2::intersect(self : Aabb2, other : Aabb2) -> Bool {
  self.min_x <= other.max_x &&
  self.max_x >= other.min_x &&
  self.min_y <= other.max_y &&
  self.max_y >= other.min_y
}

///|
/// 两盒并集
pub fn Aabb2::union(self : Aabb2, other : Aabb2) -> Aabb2 {
  let min_x = if self.min_x < other.min_x { self.min_x } else { other.min_x }
  let max_x = if self.max_x > other.max_x { self.max_x } else { other.max_x }
  let min_y = if self.min_y < other.min_y { self.min_y } else { other.min_y }
  let max_y = if self.max_y > other.max_y { self.max_y } else { other.max_y }
  { min_x, min_y, max_x, max_y, }
}

///|
/// 中心点
pub fn Aabb2::center(self : Aabb2) -> @alg.Pt2 {
  @alg.Pt2::new(
    (self.min_x + self.max_x) / 2.0,
    (self.min_y + self.max_y) / 2.0,
  )
}

///|
impl Bv for Aabb2 with fn bv_volume(self) {
  (self.max_x - self.min_x) * (self.max_y - self.min_y)
}

///|
impl Bv for Aabb2 with fn bv_is_empty(self) {
  self.max_x < self.min_x || self.max_y < self.min_y
}
