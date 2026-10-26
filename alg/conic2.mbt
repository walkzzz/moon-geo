// 2D 圆锥曲线
// 第2层 alg，依赖 util, space
// 一般式：a*x² + b*x*y + c*y² + d*x + e*y + f = 0
// 判别式 Δ = b² - 4ac 决定曲线类型

///|
/// 圆锥曲线类型
pub enum ConicType {
  /// 椭圆（Δ < 0）
  Ellipse
  /// 抛物线（Δ = 0）
  Parabola
  /// 双曲线（Δ > 0）
  Hyperbola
  /// 退化（无法分类）
  Degenerate
}

///|
/// 二维圆锥曲线：a*x² + b*x*y + c*y² + d*x + e*y + f = 0
pub struct Conic2 {
  a : Double
  b : Double
  c : Double
  d : Double
  e : Double
  f : Double
}

///|
pub fn Conic2::new(
  a : Double,
  b : Double,
  c : Double,
  d : Double,
  e : Double,
  f : Double,
) -> Conic2 {
  { a, b, c, d, e, f, }
}

///|
pub fn Conic2::a(self : Conic2) -> Double {
  self.a
}

///|
pub fn Conic2::b(self : Conic2) -> Double {
  self.b
}

///|
pub fn Conic2::c(self : Conic2) -> Double {
  self.c
}

///|
pub fn Conic2::d(self : Conic2) -> Double {
  self.d
}

///|
pub fn Conic2::e(self : Conic2) -> Double {
  self.e
}

///|
pub fn Conic2::f(self : Conic2) -> Double {
  self.f
}

///|
/// 判别式 Δ = b² - 4ac
/// Δ < 0 → 椭圆，Δ = 0 → 抛物线，Δ > 0 → 双曲线
pub fn Conic2::discriminant(self : Conic2) -> Double {
  self.b * self.b - 4.0 * self.a * self.c
}

///|
/// 3×3 伴随矩阵行列式（×4 避免除法精度损失）
/// | a   b/2 d/2 |
/// | b/2 c   e/2 |  4·det = 4acf - ae² - b²f + bde - cd²
/// | d/2 e/2 f   |
/// det = 0 时圆锥曲线退化（如两条直线、点、空集等）
fn Conic2::conic_det(self : Conic2) -> Double {
  let a = self.a
  let b = self.b
  let c = self.c
  let d = self.d
  let e = self.e
  let f = self.f
  4.0 * a * c * f - a * e * e - b * b * f + b * d * e - c * d * d
}

///|
/// 分类圆锥曲线类型
/// 先检查退化（3×3 行列式=0），再按判别式 Δ = b² - 4ac 分类
pub fn Conic2::classify(self : Conic2) -> ConicType {
  let det = self.conic_det()
  if @util.dbl_approx_eq(det, 0.0, @util.EPS) {
    Degenerate
  } else {
    let disc = self.discriminant()
    if @util.dbl_approx_eq(disc, 0.0, @util.EPS) {
      Parabola
    } else if disc < 0.0 {
      Ellipse
    } else {
      Hyperbola
    }
  }
}

///|
/// 将点代入方程：a*x² + b*x*y + c*y² + d*x + e*y + f
pub fn Conic2::eval(self : Conic2, p : Pt2) -> Double {
  let x = p.x()
  let y = p.y()
  self.a * x * x +
  self.b * x * y +
  self.c * y * y +
  self.d * x +
  self.e * y +
  self.f
}

///|
/// 点是否在曲线上
pub fn Conic2::contains(self : Conic2, p : Pt2) -> Bool {
  @util.dbl_approx_eq(self.eval(p), 0.0, @util.EPS)
}

///|
/// 从圆构造圆锥曲线：x² + y² - 2*cx*x - 2*cy*y + (cx² + cy² - r²) = 0
pub fn Conic2::from_circle(circle : Circle) -> Conic2 {
  let cx = circle.cx()
  let cy = circle.cy()
  let r = circle.r()
  {
    a: 1.0,
    b: 0.0,
    c: 1.0,
    d: -2.0 * cx,
    e: -2.0 * cy,
    f: cx * cx + cy * cy - r * r,
  }
}

///|
impl Geo for Conic2 with fn geo_dim(_) {
  GeoDim::Curve
}

///|
impl Geo for Conic2 with fn is_degenerate(self) {
  @util.dbl_approx_eq(self.conic_det(), 0.0, @util.EPS)
}

///|
pub extend Conic2 with Geo::{geo_dim, is_degenerate}
