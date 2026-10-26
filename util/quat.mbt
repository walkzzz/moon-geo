// 四元数类型：Quat
// 第-1层 util

///|
pub(all) struct Quat {
  w : Double
  x : Double
  y : Double
  z : Double
} derive(Eq, Debug)

///|
pub fn Quat::new(w : Double, x : Double, y : Double, z : Double) -> Quat {
  { w, x, y, z, }
}

///|
pub fn Quat::identity() -> Quat {
  { w: 1.0, x: 0.0, y: 0.0, z: 0.0, }
}

///|
/// 从轴角构造：q = cos(angle/2) + sin(angle/2) * axis_normalized
/// 零轴旋转等价无旋转，返回 identity
pub fn Quat::from_axis_angle(axis : Vec3, angle : Double) -> Quat {
  if dbl_approx_zero(axis.len_sq(), EPS) {
    return Quat::identity()
  }
  let half = angle * 0.5
  let s = @math.sin(half)
  let n = axis.normalize()
  { w: @math.cos(half), x: n.x * s, y: n.y * s, z: n.z * s, }
}

///|
/// 从欧拉角构造（ZYX 顺序：先 Z 偏航，再 Y 俯仰，后 X 翻滚）
pub fn Quat::from_euler(pitch : Double, yaw : Double, roll : Double) -> Quat {
  let cp = @math.cos(pitch * 0.5)
  let sp = @math.sin(pitch * 0.5)
  let cy = @math.cos(yaw * 0.5)
  let sy = @math.sin(yaw * 0.5)
  let cr = @math.cos(roll * 0.5)
  let sr = @math.sin(roll * 0.5)
  {
    w: cr * cp * cy + sr * sp * sy,
    x: sr * cp * cy - cr * sp * sy,
    y: cr * sp * cy + sr * cp * sy,
    z: cr * cp * sy - sr * sp * cy,
  }
}

///|
/// Hamilton 乘积
pub fn Quat::mul(self : Quat, other : Quat) -> Quat {
  {
    w: self.w * other.w + self.x * other.x - self.y * other.y - self.z * other.z,
    x: self.w * other.x + self.x * other.w + self.y * other.z - self.z * other.y,
    y: self.w * other.y - self.x * other.z + self.y * other.w + self.z * other.x,
    z: self.w * other.z + self.x * other.y - self.y * other.x + self.z * other.w,
  }
}

///|
pub fn Quat::conjugate(self : Quat) -> Quat {
  { w: self.w, x: -self.x, y: -self.y, z: -self.z, }
}

///|
pub fn Quat::norm_sq(self : Quat) -> Double {
  self.w * self.w + self.x * self.x + self.y * self.y + self.z * self.z
}

///|
pub fn Quat::norm(self : Quat) -> Double {
  self.norm_sq().sqrt()
}

///|
pub fn Quat::normalize(self : Quat) -> Quat {
  let n = self.norm()
  if dbl_approx_zero(n, EPS) {
    self
  } else {
    { w: self.w / n, x: self.x / n, y: self.y / n, z: self.z / n, }
  }
}

///|
/// 转换为 4x4 旋转矩阵（内部归一化，非单位四元数安全）
pub fn Quat::to_mat4(self : Quat) -> Mat4 {
  let q = self.normalize()
  let xx = q.x * q.x
  let yy = q.y * q.y
  let zz = q.z * q.z
  let xy = q.x * q.y
  let xz = q.x * q.z
  let yz = q.y * q.z
  let wx = q.w * q.x
  let wy = q.w * q.y
  let wz = q.w * q.z
  Mat4::new(
    1.0 - 2.0 * (yy + zz),
    2.0 * (xy - wz),
    2.0 * (xz + wy),
    0.0,
    2.0 * (xy + wz),
    1.0 - 2.0 * (xx + zz),
    2.0 * (yz - wx),
    0.0,
    2.0 * (xz - wy),
    2.0 * (yz + wx),
    1.0 - 2.0 * (xx + yy),
    0.0,
    0.0,
    0.0,
    0.0,
    1.0,
  )
}

///|
/// 球面线性插值
pub fn Quat::slerp(self : Quat, other : Quat, t : Double) -> Quat {
  let mut q2 = other
  let mut cos_theta = self.w * other.w +
    self.x * other.x +
    self.y * other.y +
    self.z * other.z
  if cos_theta < 0.0 {
    q2 = { w: -other.w, x: -other.x, y: -other.y, z: -other.z, }
    cos_theta = -cos_theta
  }
  // 小角度用线性插值 + 归一化
  if cos_theta > 0.9995 {
    let r = {
      w: self.w + t * (q2.w - self.w),
      x: self.x + t * (q2.x - self.x),
      y: self.y + t * (q2.y - self.y),
      z: self.z + t * (q2.z - self.z),
    }
    return r.normalize()
  }
  let theta = @math.acos(cos_theta)
  let sin_theta = @math.sin(theta)
  let a = @math.sin((1.0 - t) * theta) / sin_theta
  let b = @math.sin(t * theta) / sin_theta
  {
    w: a * self.w + b * q2.w,
    x: a * self.x + b * q2.x,
    y: a * self.y + b * q2.y,
    z: a * self.z + b * q2.z,
  }
}

///|
impl ApproxEq for Quat with fn approx_eq(self, other, tol) {
  dbl_approx_eq(self.w, other.w, tol) &&
  dbl_approx_eq(self.x, other.x, tol) &&
  dbl_approx_eq(self.y, other.y, tol) &&
  dbl_approx_eq(self.z, other.z, tol)
}

///|
impl ApproxEq for Quat with fn approx_zero(self, tol) {
  dbl_approx_eq(self.w, 0.0, tol) &&
  dbl_approx_eq(self.x, 0.0, tol) &&
  dbl_approx_eq(self.y, 0.0, tol) &&
  dbl_approx_eq(self.z, 0.0, tol)
}

///|
pub extend Quat with Eq::{not_equal, equal}

///|
pub extend Quat with @debug.Debug::{to_repr}

///|
pub extend Quat with ApproxEq::{approx_eq, approx_zero}
