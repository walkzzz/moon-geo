// 3D 二次曲面
// 第2层 alg，依赖 util, atop, space
// 一般式：a*x² + b*y² + c*z² + d*xy + e*xz + f*yz + g*x + h*y + i*z + j = 0

///|
/// 二次曲面类型
pub enum Quad3Type {
  /// 椭球面
  Ellipsoid
  /// 单叶双曲面
  HyperboloidOneSheet
  /// 双叶双曲面
  HyperboloidTwoSheets
  /// 椭圆抛物面
  EllipticParaboloid
  /// 双曲抛物面
  HyperbolicParaboloid
  /// 椭圆锥面
  EllipticCone
  /// 椭圆柱面
  EllipticCylinder
  /// 其他/退化
  Other
}

///|
/// 三维二次曲面
pub struct Quad3 {
  a : Double
  b : Double
  c : Double
  d : Double
  e : Double
  f : Double
  g : Double
  h : Double
  i : Double
  j : Double
}

///|
pub fn Quad3::new(
  a : Double,
  b : Double,
  c : Double,
  d : Double,
  e : Double,
  f : Double,
  g : Double,
  h : Double,
  i : Double,
  j : Double,
) -> Quad3 {
  { a, b, c, d, e, f, g, h, i, j, }
}

///|
/// 将点代入方程
pub fn Quad3::eval(self : Quad3, p : Pt3) -> Double {
  let x = p.x()
  let y = p.y()
  let z = p.z()
  self.a * x * x +
  self.b * y * y +
  self.c * z * z +
  self.d * x * y +
  self.e * x * z +
  self.f * y * z +
  self.g * x +
  self.h * y +
  self.i * z +
  self.j
}

///|
/// 点是否在曲面上
pub fn Quad3::contains(self : Quad3, p : Pt3) -> Bool {
  @util.dbl_approx_eq(self.eval(p), 0.0, @util.EPS)
}

///|
/// 从球构造二次曲面：x² + y² + z² - 2*cx*x - 2*cy*y - 2*cz*z + (cx²+cy²+cz²-r²) = 0
pub fn Quad3::from_sphere(s : Sphere) -> Quad3 {
  let cx = s.cx()
  let cy = s.cy()
  let cz = s.cz()
  let r = s.r()
  {
    a: 1.0,
    b: 1.0,
    c: 1.0,
    d: 0.0,
    e: 0.0,
    f: 0.0,
    g: -2.0 * cx,
    h: -2.0 * cy,
    i: -2.0 * cz,
    j: cx * cx + cy * cy + cz * cz - r * r,
  }
}

///|
impl Geo for Quad3 with fn geo_dim(_) {
  GeoDim::Surface
}

///|
impl Geo for Quad3 with fn is_degenerate(self) {
  @util.dbl_approx_eq(self.a, 0.0, @util.EPS) &&
  @util.dbl_approx_eq(self.b, 0.0, @util.EPS) &&
  @util.dbl_approx_eq(self.c, 0.0, @util.EPS) &&
  @util.dbl_approx_eq(self.d, 0.0, @util.EPS) &&
  @util.dbl_approx_eq(self.e, 0.0, @util.EPS) &&
  @util.dbl_approx_eq(self.f, 0.0, @util.EPS)
}
