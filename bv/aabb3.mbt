// 3D 轴对齐包围盒
// 第3层 bv，依赖 util, alg

///|
/// 三维轴对齐包围盒
pub struct Aabb3 {
  min_x : Double
  min_y : Double
  min_z : Double
  max_x : Double
  max_y : Double
  max_z : Double
}

///|
pub fn Aabb3::new(
  min_x : Double,
  min_y : Double,
  min_z : Double,
  max_x : Double,
  max_y : Double,
  max_z : Double,
) -> Aabb3 {
  { min_x, min_y, min_z, max_x, max_y, max_z, }
}

///|
/// 从两点构造
pub fn Aabb3::from_two_points(p1 : @alg.Pt3, p2 : @alg.Pt3) -> Aabb3 {
  let min_x = if p1.x() < p2.x() { p1.x() } else { p2.x() }
  let max_x = if p1.x() > p2.x() { p1.x() } else { p2.x() }
  let min_y = if p1.y() < p2.y() { p1.y() } else { p2.y() }
  let max_y = if p1.y() > p2.y() { p1.y() } else { p2.y() }
  let min_z = if p1.z() < p2.z() { p1.z() } else { p2.z() }
  let max_z = if p1.z() > p2.z() { p1.z() } else { p2.z() }
  { min_x, min_y, min_z, max_x, max_y, max_z, }
}

///|
pub fn Aabb3::min_x(self : Aabb3) -> Double {
  self.min_x
}

///|
pub fn Aabb3::max_x(self : Aabb3) -> Double {
  self.max_x
}

///|
pub fn Aabb3::min_y(self : Aabb3) -> Double {
  self.min_y
}

///|
pub fn Aabb3::max_y(self : Aabb3) -> Double {
  self.max_y
}

///|
pub fn Aabb3::min_z(self : Aabb3) -> Double {
  self.min_z
}

///|
pub fn Aabb3::max_z(self : Aabb3) -> Double {
  self.max_z
}

///|
/// 点是否在盒内
pub fn Aabb3::contains(self : Aabb3, p : @alg.Pt3) -> Bool {
  p.x() >= self.min_x &&
  p.x() <= self.max_x &&
  p.y() >= self.min_y &&
  p.y() <= self.max_y &&
  p.z() >= self.min_z &&
  p.z() <= self.max_z
}

///|
/// 两盒是否相交
pub fn Aabb3::intersect(self : Aabb3, other : Aabb3) -> Bool {
  self.min_x <= other.max_x &&
  self.max_x >= other.min_x &&
  self.min_y <= other.max_y &&
  self.max_y >= other.min_y &&
  self.min_z <= other.max_z &&
  self.max_z >= other.min_z
}

///|
/// 两盒并集
pub fn Aabb3::union(self : Aabb3, other : Aabb3) -> Aabb3 {
  let min_x = if self.min_x < other.min_x { self.min_x } else { other.min_x }
  let max_x = if self.max_x > other.max_x { self.max_x } else { other.max_x }
  let min_y = if self.min_y < other.min_y { self.min_y } else { other.min_y }
  let max_y = if self.max_y > other.max_y { self.max_y } else { other.max_y }
  let min_z = if self.min_z < other.min_z { self.min_z } else { other.min_z }
  let max_z = if self.max_z > other.max_z { self.max_z } else { other.max_z }
  { min_x, min_y, min_z, max_x, max_y, max_z, }
}

///|
/// 中心点
pub fn Aabb3::center(self : Aabb3) -> @alg.Pt3 {
  @alg.Pt3::new(
    (self.min_x + self.max_x) / 2.0,
    (self.min_y + self.max_y) / 2.0,
    (self.min_z + self.max_z) / 2.0,
  )
}

///|
impl Bv for Aabb3 with fn bv_volume(self) {
  (self.max_x - self.min_x) *
  (self.max_y - self.min_y) *
  (self.max_z - self.min_z)
}

///|
impl Bv for Aabb3 with fn bv_is_empty(self) {
  self.max_x < self.min_x || self.max_y < self.min_y || self.max_z < self.min_z
}
