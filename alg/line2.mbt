// 2D 直线
// 第2层 alg，依赖 util, space
// 一般式：a*x + b*y + c = 0

///|
/// 二维直线：a*x + b*y + c = 0
pub struct Line2 {
  a : Double
  b : Double
  c : Double
}

///|
pub fn Line2::new(a : Double, b : Double, c : Double) -> Line2 {
  { a, b, c, }
}

///|
pub fn Line2::a(self : Line2) -> Double {
  self.a
}

///|
pub fn Line2::b(self : Line2) -> Double {
  self.b
}

///|
pub fn Line2::c(self : Line2) -> Double {
  self.c
}

///|
/// 从两点构造直线
/// 退化：两点重合时返回 Err(GeoError::DegenerateInput)
pub fn Line2::from_two_points(
  p1 : Pt2,
  p2 : Pt2,
) -> Result[Line2, @util.GeoError] {
  let a = p1.y() - p2.y()
  let b = p2.x() - p1.x()
  let c = p1.x() * p2.y() - p2.x() * p1.y()
  if @util.dbl_approx_eq(a, 0.0, @util.EPS) &&
    @util.dbl_approx_eq(b, 0.0, @util.EPS) {
    Err(
      @util.GeoError::with_context(
        @util.GeoErrorCode::DegenerateInput,
        "Line2::from_two_points: two points are coincident",
        ["p1", "p2"],
      ),
    )
  } else {
    Ok({ a, b, c, })
  }
}

///|
/// 将点代入直线方程：a*x + b*y + c
/// 返回 0 表示点在直线上
pub fn Line2::eval(self : Line2, p : Pt2) -> Double {
  self.a * p.x() + self.b * p.y() + self.c
}

///|
/// 点是否在直线上
pub fn Line2::contains(self : Line2, p : Pt2) -> Bool {
  @util.dbl_approx_eq(self.eval(p), 0.0, @util.EPS)
}

///|
/// 点到直线的距离 |a*x + b*y + c| / sqrt(a^2 + b^2)
/// 退化直线（a=b=0）返回 |c|
pub fn Line2::distance_to_point(self : Line2, p : Pt2) -> Double {
  let denom = (self.a * self.a + self.b * self.b).sqrt()
  if denom < @util.EPS {
    self.c.abs()
  } else {
    self.eval(p).abs() / denom
  }
}

///|
/// 两直线求交：叉积法
/// 平行/重合返回 None，否则返回交点
pub fn Line2::intersect(self : Line2, other : Line2) -> Pt2? {
  let det = self.a * other.b - other.a * self.b
  if @util.dbl_approx_eq(det, 0.0, @util.EPS) {
    None
  } else {
    let x = (self.b * other.c - other.b * self.c) / det
    let y = (other.a * self.c - self.a * other.c) / det
    Some(Pt2::new(x, y))
  }
}

///|
/// 两直线是否平行
pub fn Line2::is_parallel(self : Line2, other : Line2) -> Bool {
  @util.dbl_approx_eq(self.a * other.b - other.a * self.b, 0.0, @util.EPS)
}

///|
impl Geo for Line2 with fn geo_dim(_) {
  GeoDim::Curve
}

///|
impl Geo for Line2 with fn is_degenerate(self) {
  @util.dbl_approx_eq(self.a, 0.0, @util.EPS) &&
  @util.dbl_approx_eq(self.b, 0.0, @util.EPS)
}
