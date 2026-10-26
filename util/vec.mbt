// 向量类型：Vec2 / Vec3
// 第-1层 util

///|
pub(all) struct Vec2 {
  x : Double
  y : Double
} derive(Eq, Debug)

///|
pub fn Vec2::new(x : Double, y : Double) -> Vec2 {
  { x, y, }
}

///|
pub fn Vec2::zero() -> Vec2 {
  { x: 0.0, y: 0.0, }
}

///|
pub fn Vec2::len_sq(self : Vec2) -> Double {
  self.x * self.x + self.y * self.y
}

///|
pub fn Vec2::len(self : Vec2) -> Double {
  self.len_sq().sqrt()
}

///|
pub fn Vec2::dot(self : Vec2, other : Vec2) -> Double {
  self.x * other.x + self.y * other.y
}

///|
/// 2D 叉积（标量）：x1*y2 - y1*x2
pub fn Vec2::cross(self : Vec2, other : Vec2) -> Double {
  self.x * other.y - self.y * other.x
}

///|
pub fn Vec2::normalize(self : Vec2) -> Vec2 {
  let l = self.len()
  if dbl_approx_zero(l, EPS) {
    self
  } else {
    { x: self.x / l, y: self.y / l, }
  }
}

///|
pub fn Vec2::add(self : Vec2, other : Vec2) -> Vec2 {
  { x: self.x + other.x, y: self.y + other.y, }
}

///|
pub fn Vec2::sub(self : Vec2, other : Vec2) -> Vec2 {
  { x: self.x - other.x, y: self.y - other.y, }
}

///|
pub fn Vec2::scale(self : Vec2, s : Double) -> Vec2 {
  { x: self.x * s, y: self.y * s, }
}

///|
pub fn Vec2::neg(self : Vec2) -> Vec2 {
  { x: -self.x, y: -self.y, }
}

///|
/// 逆时针旋转 90 度
pub fn Vec2::perp(self : Vec2) -> Vec2 {
  { x: -self.y, y: self.x, }
}

///|
/// 线性插值
pub fn Vec2::lerp(self : Vec2, other : Vec2, t : Double) -> Vec2 {
  { x: self.x + (other.x - self.x) * t, y: self.y + (other.y - self.y) * t, }
}

///|
/// 夹角（弧度）
pub fn Vec2::angle(self : Vec2, other : Vec2) -> Double {
  let l = self.len() * other.len()
  if dbl_approx_zero(l, EPS) {
    0.0
  } else {
    @math.acos((self.dot(other) / l).clamp(min=-1.0, max=1.0))
  }
}

///|
/// 投影到 other
pub fn Vec2::project(self : Vec2, other : Vec2) -> Vec2 {
  let d = other.dot(other)
  if dbl_approx_zero(d, EPS) {
    Vec2::zero()
  } else {
    other.scale(self.dot(other) / d)
  }
}

///|
impl ApproxEq for Vec2 with fn approx_eq(self, other, tol) {
  dbl_approx_eq(self.x, other.x, tol) && dbl_approx_eq(self.y, other.y, tol)
}

///|
impl ApproxEq for Vec2 with fn approx_zero(self, tol) {
  dbl_approx_eq(self.x, 0.0, tol) && dbl_approx_eq(self.y, 0.0, tol)
}

///|
pub extend Vec2 with Eq::{not_equal, equal}

///|
pub extend Vec2 with @debug.Debug::{to_repr}

///|
pub extend Vec2 with ApproxEq::{approx_eq, approx_zero}

///|
pub(all) struct Vec3 {
  x : Double
  y : Double
  z : Double
} derive(Eq, Debug)

///|
pub fn Vec3::new(x : Double, y : Double, z : Double) -> Vec3 {
  { x, y, z, }
}

///|
pub fn Vec3::zero() -> Vec3 {
  { x: 0.0, y: 0.0, z: 0.0, }
}

///|
pub fn Vec3::len_sq(self : Vec3) -> Double {
  self.x * self.x + self.y * self.y + self.z * self.z
}

///|
pub fn Vec3::len(self : Vec3) -> Double {
  self.len_sq().sqrt()
}

///|
pub fn Vec3::dot(self : Vec3, other : Vec3) -> Double {
  self.x * other.x + self.y * other.y + self.z * other.z
}

///|
/// 3D 叉积（向量）
pub fn Vec3::cross(self : Vec3, other : Vec3) -> Vec3 {
  {
    x: self.y * other.z - self.z * other.y,
    y: self.z * other.x - self.x * other.z,
    z: self.x * other.y - self.y * other.x,
  }
}

///|
pub fn Vec3::normalize(self : Vec3) -> Vec3 {
  let l = self.len()
  if dbl_approx_zero(l, EPS) {
    self
  } else {
    { x: self.x / l, y: self.y / l, z: self.z / l, }
  }
}

///|
pub fn Vec3::add(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x + other.x, y: self.y + other.y, z: self.z + other.z, }
}

///|
pub fn Vec3::sub(self : Vec3, other : Vec3) -> Vec3 {
  { x: self.x - other.x, y: self.y - other.y, z: self.z - other.z, }
}

///|
pub fn Vec3::scale(self : Vec3, s : Double) -> Vec3 {
  { x: self.x * s, y: self.y * s, z: self.z * s, }
}

///|
pub fn Vec3::neg(self : Vec3) -> Vec3 {
  { x: -self.x, y: -self.y, z: -self.z, }
}

///|
/// 线性插值
pub fn Vec3::lerp(self : Vec3, other : Vec3, t : Double) -> Vec3 {
  {
    x: self.x + (other.x - self.x) * t,
    y: self.y + (other.y - self.y) * t,
    z: self.z + (other.z - self.z) * t,
  }
}

///|
/// 夹角（弧度）
pub fn Vec3::angle(self : Vec3, other : Vec3) -> Double {
  let l = self.len() * other.len()
  if dbl_approx_zero(l, EPS) {
    0.0
  } else {
    @math.acos((self.dot(other) / l).clamp(min=-1.0, max=1.0))
  }
}

///|
/// 投影到 other
pub fn Vec3::project(self : Vec3, other : Vec3) -> Vec3 {
  let d = other.dot(other)
  if dbl_approx_zero(d, EPS) {
    Vec3::zero()
  } else {
    other.scale(self.dot(other) / d)
  }
}

///|
impl ApproxEq for Vec3 with fn approx_eq(self, other, tol) {
  dbl_approx_eq(self.x, other.x, tol) &&
  dbl_approx_eq(self.y, other.y, tol) &&
  dbl_approx_eq(self.z, other.z, tol)
}

///|
impl ApproxEq for Vec3 with fn approx_zero(self, tol) {
  dbl_approx_eq(self.x, 0.0, tol) &&
  dbl_approx_eq(self.y, 0.0, tol) &&
  dbl_approx_eq(self.z, 0.0, tol)
}

///|
pub extend Vec3 with Eq::{not_equal, equal}

///|
pub extend Vec3 with @debug.Debug::{to_repr}

///|
pub extend Vec3 with ApproxEq::{approx_eq, approx_zero}
