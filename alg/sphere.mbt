// 3D 球 + 幂定理
// 第2层 alg，依赖 util, atop, space
// 球心 (cx, cy, cz) + 半径 r
// 幂定理：点 P 对球 S 的幂 pow(P, S) = |P - C|² - r²
//   pow > 0：点在球外，pow = 切线长度²
//   pow = 0：点在球上
//   pow < 0：点在球内

///|
/// 三维球
pub struct Sphere {
  cx : Double
  cy : Double
  cz : Double
  r : Double
}

///|
pub fn Sphere::new(cx : Double, cy : Double, cz : Double, r : Double) -> Sphere {
  { cx, cy, cz, r, }
}

///|
pub fn Sphere::cx(self : Sphere) -> Double {
  self.cx
}

///|
pub fn Sphere::cy(self : Sphere) -> Double {
  self.cy
}

///|
pub fn Sphere::cz(self : Sphere) -> Double {
  self.cz
}

///|
pub fn Sphere::r(self : Sphere) -> Double {
  self.r
}

///|
/// 球心
pub fn Sphere::center(self : Sphere) -> Pt3 {
  Pt3::new(self.cx, self.cy, self.cz)
}

///|
/// 体积 (4/3) π r³
pub fn Sphere::volume(self : Sphere) -> Double {
  4.0 / 3.0 * 3.14159265358979323846 * self.r * self.r * self.r
}

///|
/// 表面积 4 π r²
pub fn Sphere::surface_area(self : Sphere) -> Double {
  4.0 * 3.14159265358979323846 * self.r * self.r
}

///|
/// 点是否在球面上
pub fn Sphere::contains(self : Sphere, p : Pt3) -> Bool {
  let d = self.center().distance_to(p)
  @util.dbl_approx_eq(d, self.r, @util.EPS)
}

///|
/// 点是否在球内
pub fn Sphere::contains_interior(self : Sphere, p : Pt3) -> Bool {
  let d = self.center().distance_to(p)
  d < self.r
}

///|
/// 幂定理：点 P 对球的幂 pow = |P - C|² - r²
/// pow > 0：点在球外（= 切线长度²）
/// pow = 0：点在球上
/// pow < 0：点在球内
pub fn Sphere::power(self : Sphere, p : Pt3) -> Double {
  let dx = p.x() - self.cx
  let dy = p.y() - self.cy
  let dz = p.z() - self.cz
  dx * dx + dy * dy + dz * dz - self.r * self.r
}

///|
/// 切线长度（点在球外时）：sqrt(power)
/// 点在球上/球内时返回 0
pub fn Sphere::tangent_length(self : Sphere, p : Pt3) -> Double {
  let pow = self.power(p)
  if pow > 0.0 {
    pow.sqrt()
  } else {
    0.0
  }
}

///|
impl Geo for Sphere with fn geo_dim(_) {
  GeoDim::Surface
}

///|
impl Geo for Sphere with fn is_degenerate(self) {
  self.r < @util.EPS
}

///|
pub extend Sphere with Geo::{geo_dim, is_degenerate}

///|
/// 2D 圆的幂定理：点 P 对圆 C 的幂 pow = |P - C|² - r²
pub fn Circle::power(self : Circle, p : Pt2) -> Double {
  let dx = p.x() - self.cx
  let dy = p.y() - self.cy
  dx * dx + dy * dy - self.r * self.r
}

///|
/// 2D 圆的切线长度
pub fn Circle::tangent_length(self : Circle, p : Pt2) -> Double {
  let pow = self.power(p)
  if pow > 0.0 {
    pow.sqrt()
  } else {
    0.0
  }
}
