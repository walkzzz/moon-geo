// 3D 平面
// 第2层 alg，依赖 util, atop, space
// 一般式：a*x + b*y + c*z + d = 0

///|
/// 三维平面：a*x + b*y + c*z + d = 0
pub struct Plane3 {
  a : Double
  b : Double
  c : Double
  d : Double
}

///|
pub fn Plane3::new(a : Double, b : Double, c : Double, d : Double) -> Plane3 {
  { a, b, c, d, }
}

///|
pub fn Plane3::a(self : Plane3) -> Double {
  self.a
}

///|
pub fn Plane3::b(self : Plane3) -> Double {
  self.b
}

///|
pub fn Plane3::c(self : Plane3) -> Double {
  self.c
}

///|
pub fn Plane3::d(self : Plane3) -> Double {
  self.d
}

///|
/// 从三点构造平面
/// 退化：三点共线时返回 a=b=c=0 的退化平面
pub fn Plane3::from_three_points(p1 : Pt3, p2 : Pt3, p3 : Pt3) -> Plane3 {
  let v1x = p2.x() - p1.x()
  let v1y = p2.y() - p1.y()
  let v1z = p2.z() - p1.z()
  let v2x = p3.x() - p1.x()
  let v2y = p3.y() - p1.y()
  let v2z = p3.z() - p1.z()
  let a = v1y * v2z - v1z * v2y
  let b = v1z * v2x - v1x * v2z
  let c = v1x * v2y - v1y * v2x
  let d = -(a * p1.x() + b * p1.y() + c * p1.z())
  { a, b, c, d, }
}

///|
/// 将点代入平面方程：a*x + b*y + c*z + d
pub fn Plane3::eval(self : Plane3, p : Pt3) -> Double {
  self.a * p.x() + self.b * p.y() + self.c * p.z() + self.d
}

///|
/// 点是否在平面上
pub fn Plane3::contains(self : Plane3, p : Pt3) -> Bool {
  @util.dbl_approx_eq(self.eval(p), 0.0, @util.EPS)
}

///|
/// 点到平面的距离 |a*x+b*y+c*z+d| / sqrt(a²+b²+c²)
pub fn Plane3::distance_to_point(self : Plane3, p : Pt3) -> Double {
  let denom = (self.a * self.a + self.b * self.b + self.c * self.c).sqrt()
  if denom < @util.EPS {
    self.d.abs()
  } else {
    self.eval(p).abs() / denom
  }
}

///|
impl Geo for Plane3 with fn geo_dim(_) {
  GeoDim::Surface
}

///|
impl Geo for Plane3 with fn is_degenerate(self) {
  @util.dbl_approx_eq(self.a, 0.0, @util.EPS) &&
  @util.dbl_approx_eq(self.b, 0.0, @util.EPS) &&
  @util.dbl_approx_eq(self.c, 0.0, @util.EPS)
}
