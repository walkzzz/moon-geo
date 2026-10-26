// 球形包围体
// 第3层 bv，依赖 util, alg

///|
/// 球形包围体（3D）
pub struct SphereBv {
  cx : Double
  cy : Double
  cz : Double
  r : Double
}

///|
pub fn SphereBv::new(
  cx : Double,
  cy : Double,
  cz : Double,
  r : Double,
) -> SphereBv {
  { cx, cy, cz, r, }
}

///|
/// 从 Aabb3 构造（外接球）
pub fn SphereBv::from_aabb(aabb : Aabb3) -> SphereBv {
  let cx = (aabb.min_x() + aabb.max_x()) / 2.0
  let cy = (aabb.min_y() + aabb.max_y()) / 2.0
  let cz = (aabb.min_z() + aabb.max_z()) / 2.0
  let dx = (aabb.max_x() - aabb.min_x()) / 2.0
  let dy = (aabb.max_y() - aabb.min_y()) / 2.0
  let dz = (aabb.max_z() - aabb.min_z()) / 2.0
  let r = (dx * dx + dy * dy + dz * dz).sqrt()
  { cx, cy, cz, r, }
}

///|
pub fn SphereBv::cx(self : SphereBv) -> Double {
  self.cx
}

///|
pub fn SphereBv::cy(self : SphereBv) -> Double {
  self.cy
}

///|
pub fn SphereBv::cz(self : SphereBv) -> Double {
  self.cz
}

///|
pub fn SphereBv::r(self : SphereBv) -> Double {
  self.r
}

///|
/// 点是否在球内
pub fn SphereBv::contains(self : SphereBv, p : @alg.Pt3) -> Bool {
  let dx = p.x() - self.cx
  let dy = p.y() - self.cy
  let dz = p.z() - self.cz
  dx * dx + dy * dy + dz * dz <= self.r * self.r
}

///|
/// 两球是否相交
pub fn SphereBv::intersect(self : SphereBv, other : SphereBv) -> Bool {
  let dx = self.cx - other.cx
  let dy = self.cy - other.cy
  let dz = self.cz - other.cz
  let dist_sq = dx * dx + dy * dy + dz * dz
  let r_sum = self.r + other.r
  dist_sq <= r_sum * r_sum
}

///|
/// 两球并集（外接球近似）
pub fn SphereBv::union(self : SphereBv, other : SphereBv) -> SphereBv {
  let dx = other.cx - self.cx
  let dy = other.cy - self.cy
  let dz = other.cz - self.cz
  let dist = (dx * dx + dy * dy + dz * dz).sqrt()
  if dist + other.r <= self.r {
    { cx: self.cx, cy: self.cy, cz: self.cz, r: self.r, }
  } else if dist + self.r <= other.r {
    { cx: other.cx, cy: other.cy, cz: other.cz, r: other.r, }
  } else {
    let cx = (self.cx + other.cx) / 2.0
    let cy = (self.cy + other.cy) / 2.0
    let cz = (self.cz + other.cz) / 2.0
    let r = (dist + self.r + other.r) / 2.0
    { cx, cy, cz, r, }
  }
}

///|
impl Bv for SphereBv with fn bv_volume(self) {
  4.0 / 3.0 * 3.14159265358979323846 * self.r * self.r * self.r
}

///|
impl Bv for SphereBv with fn bv_is_empty(self) {
  self.r < @util.EPS
}
