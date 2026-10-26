// 3D 二次曲面
// 第2层 alg，依赖 util, atop, space
// 一般式：a*x² + b*y² + c*z² + d*xy + e*xz + f*yz + g*x + h*y + i*z + j = 0

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
/// 4×4 伴随矩阵行列式
/// | a   d/2 e/2 g/2 |
/// | d/2 b   f/2 h/2 |
/// | e/2 f/2 c   i/2 |
/// | g/2 h/2 i/2 j   |
/// det = 0 时二次曲面退化
fn Quad3::quad3_det(self : Quad3) -> Double {
  let m = @util.Mat4::new(
    self.a,
    self.d / 2.0,
    self.e / 2.0,
    self.g / 2.0,
    self.d / 2.0,
    self.b,
    self.f / 2.0,
    self.h / 2.0,
    self.e / 2.0,
    self.f / 2.0,
    self.c,
    self.i / 2.0,
    self.g / 2.0,
    self.h / 2.0,
    self.i / 2.0,
    self.j,
  )
  m.det()
}

///|
impl Geo for Quad3 with fn geo_dim(_) {
  GeoDim::Surface
}

///|
impl Geo for Quad3 with fn is_degenerate(self) {
  @util.dbl_approx_eq(self.quad3_det(), 0.0, @util.EPS)
}

///|
pub extend Quad3 with Geo::{geo_dim, is_degenerate}
