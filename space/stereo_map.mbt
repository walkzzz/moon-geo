// 球极投影 StereoMap
// 第1层 space，依赖 util, atop, math
// 复平面 C ↔ 单位球面 S²（Riemann 球）的双射映射
// 正向：球面点 (X,Y,Z) → z = (X+iY)/(1-Z)，北极 (0,0,1) → ∞
// 逆向：复数 z=x+iy → (2x/r, 2y/r, (|z|²-1)/r)，r = |z|²+1
// 保圆性：球面上的圆映射到平面上的圆或直线

///|
/// 球极投影映射
pub struct StereoMap {
  dummy : Unit
}

///|
pub fn StereoMap::new() -> StereoMap {
  { dummy: (), }
}

///|
/// 正向投影：球面点 → 复平面
/// z = (X + iY) / (1 - Z)，北极 Z≈1 时 raise DegenerateInput
pub fn StereoMap::to_plane(
  self : StereoMap,
  p : Euclid3,
) -> Complex2 raise @util.GeoError {
  ignore(self)
  let denom = 1.0 - p.z()
  if @util.dbl_approx_zero(denom, @util.EPS) {
    raise @util.GeoError::DegenerateInput("north pole maps to infinity", [
      "StereoMap::to_plane",
    ])
  }
  let inv_denom = 1.0 / denom
  Complex2::new(p.x() * inv_denom, p.y() * inv_denom)
}

///|
/// 逆向投影：复平面 → 球面点
/// X = 2x/r, Y = 2y/r, Z = (|z|²-1)/r, r = |z|²+1
pub fn StereoMap::to_sphere(self : StereoMap, z : Complex2) -> Euclid3 {
  ignore(self)
  let x = z.re()
  let y = z.im()
  let r = x * x + y * y + 1.0
  let inv_r = 1.0 / r
  Euclid3::new(2.0 * x * inv_r, 2.0 * y * inv_r, (x * x + y * y - 1.0) * inv_r)
}

///|
/// SpaceMap：源 = Euclidean3（球面嵌入 3D），目标 = Complex2
impl SpaceMap for StereoMap with fn source_kind(_) {
  SpaceKind::Euclidean3
}

///|
impl SpaceMap for StereoMap with fn target_kind(_) {
  SpaceKind::Complex2
}

///|
/// 单射：球面去掉北极后，每点映射到唯一复数
impl SpaceMap for StereoMap with fn is_injective(_) {
  true
}

///|
/// 满射：每个复数都有球面上的原像
impl SpaceMap for StereoMap with fn is_surjective(_) {
  true
}
