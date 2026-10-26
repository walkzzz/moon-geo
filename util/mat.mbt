// 矩阵类型：Mat3 / Mat4
// 第-1层 util

///|
pub(all) suberror MatError {
  Singular
}

///|
pub(all) struct Mat3 {
  m : Array[Double] // row-major, 9 elements: m[row*3+col]
} derive(Debug)

///|
pub fn Mat3::new(
  m00 : Double,
  m01 : Double,
  m02 : Double,
  m10 : Double,
  m11 : Double,
  m12 : Double,
  m20 : Double,
  m21 : Double,
  m22 : Double,
) -> Mat3 {
  { m: [m00, m01, m02, m10, m11, m12, m20, m21, m22], }
}

///|
pub fn Mat3::identity() -> Mat3 {
  { m: [1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0], }
}

///|
/// 取元素：row, col ∈ 0..2
pub fn Mat3::get(self : Mat3, row : Int32, col : Int32) -> Double {
  self.m[row * 3 + col]
}

///|
pub fn Mat3::det(self : Mat3) -> Double {
  let m = self.m
  m[0] * (m[4] * m[8] - m[5] * m[7]) -
  m[1] * (m[3] * m[8] - m[5] * m[6]) +
  m[2] * (m[3] * m[7] - m[4] * m[6])
}

///|
pub fn Mat3::transpose(self : Mat3) -> Mat3 {
  let m = self.m
  { m: [m[0], m[3], m[6], m[1], m[4], m[7], m[2], m[5], m[8]], }
}

///|
pub fn Mat3::mul_vec(self : Mat3, v : Vec3) -> Vec3 {
  let m = self.m
  {
    x: m[0] * v.x + m[1] * v.y + m[2] * v.z,
    y: m[3] * v.x + m[4] * v.y + m[5] * v.z,
    z: m[6] * v.x + m[7] * v.y + m[8] * v.z,
  }
}

///|
pub fn Mat3::mul_mat(self : Mat3, other : Mat3) -> Mat3 {
  let a = self.m
  let b = other.m
  {
    m: [
      a[0] * b[0] + a[1] * b[3] + a[2] * b[6],
      a[0] * b[1] + a[1] * b[4] + a[2] * b[7],
      a[0] * b[2] + a[1] * b[5] + a[2] * b[8],
      a[3] * b[0] + a[4] * b[3] + a[5] * b[6],
      a[3] * b[1] + a[4] * b[4] + a[5] * b[7],
      a[3] * b[2] + a[4] * b[5] + a[5] * b[8],
      a[6] * b[0] + a[7] * b[3] + a[8] * b[6],
      a[6] * b[1] + a[7] * b[4] + a[8] * b[7],
      a[6] * b[2] + a[7] * b[5] + a[8] * b[8],
    ],
  }
}

///|
pub fn Mat3::inv(self : Mat3) -> Mat3 raise MatError {
  let d = self.det()
  if dbl_approx_zero(d, EPS) {
    raise MatError::Singular
  }
  let m = self.m
  let inv_d = 1.0 / d
  {
    m: [
      (m[4] * m[8] - m[5] * m[7]) * inv_d,
      (m[2] * m[7] - m[1] * m[8]) * inv_d,
      (m[1] * m[5] - m[2] * m[4]) * inv_d,
      (m[5] * m[6] - m[3] * m[8]) * inv_d,
      (m[0] * m[8] - m[2] * m[6]) * inv_d,
      (m[2] * m[3] - m[0] * m[5]) * inv_d,
      (m[3] * m[7] - m[4] * m[6]) * inv_d,
      (m[1] * m[6] - m[0] * m[7]) * inv_d,
      (m[0] * m[4] - m[1] * m[3]) * inv_d,
    ],
  }
}

///|
impl ApproxEq for Mat3 with fn approx_eq(self, other, tol) {
  let a = self.m
  let b = other.m
  let mut ok = true
  for i in 0..<9 {
    if !dbl_approx_eq(a[i], b[i], tol) {
      ok = false
    }
  }
  ok
}

///|
impl ApproxEq for Mat3 with fn approx_zero(self, tol) {
  let m = self.m
  let mut ok = true
  for i in 0..<9 {
    if !dbl_approx_eq(m[i], 0.0, tol) {
      ok = false
    }
  }
  ok
}

///|
pub extend Mat3 with @debug.Debug::{to_repr}

///|
pub extend Mat3 with ApproxEq::{approx_eq, approx_zero}

///|
pub(all) struct Mat4 {
  m : Array[Double] // row-major, 16 elements
} derive(Debug)

///|
pub fn Mat4::identity() -> Mat4 {
  {
    m: [
      1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
      1.0,
    ],
  }
}

///|
pub fn Mat4::new(
  m00 : Double,
  m01 : Double,
  m02 : Double,
  m03 : Double,
  m10 : Double,
  m11 : Double,
  m12 : Double,
  m13 : Double,
  m20 : Double,
  m21 : Double,
  m22 : Double,
  m23 : Double,
  m30 : Double,
  m31 : Double,
  m32 : Double,
  m33 : Double,
) -> Mat4 {
  {
    m: [
      m00, m01, m02, m03, m10, m11, m12, m13, m20, m21, m22, m23, m30, m31, m32,
      m33,
    ],
  }
}

///|
pub fn Mat4::translation(x : Double, y : Double, z : Double) -> Mat4 {
  {
    m: [
      1.0, 0.0, 0.0, x, 0.0, 1.0, 0.0, y, 0.0, 0.0, 1.0, z, 0.0, 0.0, 0.0, 1.0,
    ],
  }
}

///|
pub fn Mat4::scaling(x : Double, y : Double, z : Double) -> Mat4 {
  {
    m: [
      x, 0.0, 0.0, 0.0, 0.0, y, 0.0, 0.0, 0.0, 0.0, z, 0.0, 0.0, 0.0, 0.0, 1.0,
    ],
  }
}

///|
pub fn Mat4::transpose(self : Mat4) -> Mat4 {
  let m = self.m
  {
    m: [
      m[0],
      m[4],
      m[8],
      m[12],
      m[1],
      m[5],
      m[9],
      m[13],
      m[2],
      m[6],
      m[10],
      m[14],
      m[3],
      m[7],
      m[11],
      m[15],
    ],
  }
}

///|
pub fn Mat4::mul_vec(self : Mat4, v : Vec3) -> Vec3 {
  let m = self.m
  // 齐次坐标 w=1
  {
    x: m[0] * v.x + m[1] * v.y + m[2] * v.z + m[3],
    y: m[4] * v.x + m[5] * v.y + m[6] * v.z + m[7],
    z: m[8] * v.x + m[9] * v.y + m[10] * v.z + m[11],
  }
}

///|
pub fn Mat4::mul_mat(self : Mat4, other : Mat4) -> Mat4 {
  let a = self.m
  let b = other.m
  let r = Array::make(16, 0.0)
  for i in 0..<4 {
    for j in 0..<4 {
      let mut sum = 0.0
      for k in 0..<4 {
        sum = sum + a[i * 4 + k] * b[k * 4 + j]
      }
      r[i * 4 + j] = sum
    }
  }
  { m: r, }
}

///|
impl ApproxEq for Mat4 with fn approx_eq(self, other, tol) {
  let a = self.m
  let b = other.m
  let mut ok = true
  for i in 0..<16 {
    if !dbl_approx_eq(a[i], b[i], tol) {
      ok = false
    }
  }
  ok
}

///|
impl ApproxEq for Mat4 with fn approx_zero(self, tol) {
  let m = self.m
  let mut ok = true
  for i in 0..<16 {
    if !dbl_approx_eq(m[i], 0.0, tol) {
      ok = false
    }
  }
  ok
}

///|
pub extend Mat4 with @debug.Debug::{to_repr}

///|
pub extend Mat4 with ApproxEq::{approx_eq, approx_zero}
