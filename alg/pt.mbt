// 2D/3D 点图元
// 第2层 alg，依赖 util, space
// Pt2/Pt3 = 几何点图元，与 space/Euclid2/Euclid3（空间点）通过转换方法关联

///|
/// 二维点图元
pub struct Pt2 {
  x : Double
  y : Double
}

///|
pub fn Pt2::new(x : Double, y : Double) -> Pt2 {
  { x, y, }
}

///|
pub fn Pt2::x(self : Pt2) -> Double {
  self.x
}

///|
pub fn Pt2::y(self : Pt2) -> Double {
  self.y
}

///|
/// 转换为空间点 Euclid2
pub fn Pt2::to_euclid(self : Pt2) -> @space.Euclid2 {
  @space.Euclid2::new(self.x, self.y)
}

///|
/// 从空间点 Euclid2 构造
pub fn Pt2::from_euclid(p : @space.Euclid2) -> Pt2 {
  { x: p.x(), y: p.y(), }
}

///|
/// 两点距离
pub fn Pt2::distance_to(self : Pt2, other : Pt2) -> Double {
  let dx = self.x - other.x
  let dy = self.y - other.y
  (dx * dx + dy * dy).sqrt()
}

///|
/// 点是否重合
pub fn Pt2::coincident(self : Pt2, other : Pt2) -> Bool {
  @util.dbl_approx_eq(self.distance_to(other), 0.0, @util.EPS)
}

///|
impl Geo for Pt2 with fn geo_dim(_) {
  GeoDim::Point
}

///|
impl Geo for Pt2 with fn is_degenerate(_) {
  false
}

///|
/// 三维点图元
pub struct Pt3 {
  x : Double
  y : Double
  z : Double
}

///|
pub fn Pt3::new(x : Double, y : Double, z : Double) -> Pt3 {
  { x, y, z, }
}

///|
pub fn Pt3::x(self : Pt3) -> Double {
  self.x
}

///|
pub fn Pt3::y(self : Pt3) -> Double {
  self.y
}

///|
pub fn Pt3::z(self : Pt3) -> Double {
  self.z
}

///|
/// 转换为空间点 Euclid3
pub fn Pt3::to_euclid(self : Pt3) -> @space.Euclid3 {
  @space.Euclid3::new(self.x, self.y, self.z)
}

///|
/// 从空间点 Euclid3 构造
pub fn Pt3::from_euclid(p : @space.Euclid3) -> Pt3 {
  { x: p.x(), y: p.y(), z: p.z(), }
}

///|
/// 两点距离
pub fn Pt3::distance_to(self : Pt3, other : Pt3) -> Double {
  let dx = self.x - other.x
  let dy = self.y - other.y
  let dz = self.z - other.z
  (dx * dx + dy * dy + dz * dz).sqrt()
}

///|
/// 点是否重合
pub fn Pt3::coincident(self : Pt3, other : Pt3) -> Bool {
  @util.dbl_approx_eq(self.distance_to(other), 0.0, @util.EPS)
}

///|
impl Geo for Pt3 with fn geo_dim(_) {
  GeoDim::Point
}

///|
impl Geo for Pt3 with fn is_degenerate(_) {
  false
}
