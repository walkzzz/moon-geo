// 三维射影空间
// 点类型 Proj3，实现 Space Trait（Dim + MetricSpace + TopologicalSpace + Space）
// 齐次坐标 [x : y : z : w]，w=0 为无穷远点
// 度量：弦距离 d([p],[q]) = sqrt(1 - (p·q)² / (||p||²·||q||²))

///|
/// 三维射影空间点（齐次坐标）
pub struct Proj3 {
  x : Double
  y : Double
  z : Double
  w : Double
}

///|
pub fn Proj3::new(x : Double, y : Double, z : Double, w : Double) -> Proj3 {
  { x, y, z, w, }
}

///|
/// 从仿射点构造 [x : y : z : 1]
pub fn Proj3::from_affine(x : Double, y : Double, z : Double) -> Proj3 {
  { x, y, z, w: 1.0, }
}

///|
pub fn Proj3::x(self : Proj3) -> Double {
  self.x
}

///|
pub fn Proj3::y(self : Proj3) -> Double {
  self.y
}

///|
pub fn Proj3::z(self : Proj3) -> Double {
  self.z
}

///|
pub fn Proj3::w(self : Proj3) -> Double {
  self.w
}

///|
/// 是否为无穷远点（w ≈ 0）
pub fn Proj3::is_at_infinity(self : Proj3) -> Bool {
  @util.dbl_approx_zero(self.w, @util.EPS)
}

///|
/// 去齐次化：返回 (x/w, y/w, z/w)，无穷远点 raise DegenerateInput
pub fn Proj3::to_affine(
  self : Proj3,
) -> (Double, Double, Double) raise @util.GeoError {
  if self.is_at_infinity() {
    raise @util.GeoError::DegenerateInput("point at infinity", [
      "Proj3::to_affine",
    ])
  }
  let inv_w = 1.0 / self.w
  (self.x * inv_w, self.y * inv_w, self.z * inv_w)
}

///|
/// 齐次点积 p·q = px*qx + py*qy + pz*qz + pw*qw
pub fn Proj3::dot(self : Proj3, other : Proj3) -> Double {
  self.x * other.x + self.y * other.y + self.z * other.z + self.w * other.w
}

///|
/// 齐次范数 ||p|| = sqrt(x² + y² + z² + w²)
pub fn Proj3::norm(self : Proj3) -> Double {
  self.dot(self).sqrt()
}

///|
/// 归一化：缩放使 ||p|| = 1
pub fn Proj3::normalize(self : Proj3) -> Proj3 {
  let n = self.norm()
  if n < @util.EPS {
    return self
  }
  let inv_n = 1.0 / n
  {
    x: self.x * inv_n,
    y: self.y * inv_n,
    z: self.z * inv_n,
    w: self.w * inv_n,
  }
}

///|
/// 缩放齐次坐标（同一射影点）
pub fn Proj3::scale(self : Proj3, s : Double) -> Proj3 {
  { x: self.x * s, y: self.y * s, z: self.z * s, w: self.w * s, }
}

///|
/// 维度 = 3（实射影 3 维）
impl @atop.Dim for Proj3 with fn dim(_) {
  3
}

///|
/// 弦距离度量：d = sqrt(1 - (p·q)² / (||p||²·||q||²))
impl @atop.MetricSpace for Proj3 with fn distance(self, other) {
  let dot = self.dot(other)
  let np = self.dot(self)
  let nq = other.dot(other)
  if np < @util.EPS || nq < @util.EPS {
    return 1.0
  }
  let cos_sq = dot * dot / (np * nq)
  if cos_sq >= 1.0 {
    0.0
  } else {
    (1.0 - cos_sq).sqrt()
  }
}

///|
/// 度量诱导邻域
impl @atop.TopologicalSpace for Proj3 with fn is_in_neighborhood(
  self,
  center,
  radius,
) {
  @atop.MetricSpace::distance(self, center) <= radius
}

///|
/// 空间类型标识
impl Space for Proj3 with fn space_kind(_) {
  SpaceKind::Projective3
}

///|
pub extend Proj3 with Space::{space_kind}
