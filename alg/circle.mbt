// 2D 圆
// 第2层 alg，依赖 util, space
// 圆心 (cx, cy) + 半径 r

///|
/// 二维圆
pub struct Circle {
  cx : Double
  cy : Double
  r : Double
}

///|
pub fn Circle::new(cx : Double, cy : Double, r : Double) -> Circle {
  { cx, cy, r, }
}

///|
pub fn Circle::cx(self : Circle) -> Double {
  self.cx
}

///|
pub fn Circle::cy(self : Circle) -> Double {
  self.cy
}

///|
pub fn Circle::r(self : Circle) -> Double {
  self.r
}

///|
/// 圆心
pub fn Circle::center(self : Circle) -> Pt2 {
  Pt2::new(self.cx, self.cy)
}

///|
/// 面积 π r²
pub fn Circle::area(self : Circle) -> Double {
  3.14159265358979323846 * self.r * self.r
}

///|
/// 周长 2 π r
pub fn Circle::circumference(self : Circle) -> Double {
  2.0 * 3.14159265358979323846 * self.r
}

///|
/// 点是否在圆上（|dist - r| < EPS）
pub fn Circle::contains(self : Circle, p : Pt2) -> Bool {
  let d = self.center().distance_to(p)
  @util.dbl_approx_eq(d, self.r, @util.EPS)
}

///|
/// 点是否在圆内（dist < r）
pub fn Circle::contains_interior(self : Circle, p : Pt2) -> Bool {
  let d = self.center().distance_to(p)
  d < self.r
}

///|
/// 点到圆的距离（|dist_to_center - r|）
pub fn Circle::distance_to_point(self : Circle, p : Pt2) -> Double {
  let d = self.center().distance_to(p)
  (d - self.r).abs()
}

///|
/// 从三点构造圆（外接圆）
/// 退化：三点共线时返回 Err(GeoError::DegenerateInput)
pub fn Circle::from_three_points(
  p1 : Pt2,
  p2 : Pt2,
  p3 : Pt2,
) -> Result[Circle, @util.GeoError] {
  let ax = p1.x()
  let ay = p1.y()
  let bx = p2.x()
  let by = p2.y()
  let cx_ = p3.x()
  let cy_ = p3.y()
  let d = 2.0 * (ax * (by - cy_) + bx * (cy_ - ay) + cx_ * (ay - by))
  if @util.dbl_approx_eq(d, 0.0, @util.EPS) {
    Err(
      @util.GeoError::with_context(
        @util.GeoErrorCode::DegenerateInput,
        "Circle::from_three_points: three points are collinear",
        ["p1", "p2", "p3"],
      ),
    )
  } else {
    let ux = (
        (ax * ax + ay * ay) * (by - cy_) +
        (bx * bx + by * by) * (cy_ - ay) +
        (cx_ * cx_ + cy_ * cy_) * (ay - by)
      ) /
      d
    let uy = (
        (ax * ax + ay * ay) * (cx_ - bx) +
        (bx * bx + by * by) * (ax - cx_) +
        (cx_ * cx_ + cy_ * cy_) * (bx - ax)
      ) /
      d
    let r = ((ux - ax) * (ux - ax) + (uy - ay) * (uy - ay)).sqrt()
    Ok(Circle::new(ux, uy, r))
  }
}

///|
impl Geo for Circle with fn geo_dim(_) {
  GeoDim::Surface
}

///|
impl Geo for Circle with fn is_degenerate(self) {
  self.r < @util.EPS
}
