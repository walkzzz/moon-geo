// 复数类型与全量运算
// 第-1层 util

///|
/// 复数错误
pub(all) suberror CpxError {
  ZeroInverse
  ZeroDivide
}

///|
/// 复数：re + im*i
pub(all) struct Cpx {
  re : Double
  im : Double
} derive(Eq, Debug)

///|
/// 构造复数
pub fn Cpx::new(re : Double, im : Double) -> Cpx {
  { re, im, }
}

///|
/// 实数构造复数（虚部为0）
pub fn Cpx::from_real(re : Double) -> Cpx {
  { re, im: 0.0, }
}

///|
/// 共轭复数
pub fn Cpx::conj(self : Cpx) -> Cpx {
  { re: self.re, im: -self.im, }
}

///|
/// 模平方
pub fn Cpx::norm_sq(self : Cpx) -> Double {
  self.re * self.re + self.im * self.im
}

///|
/// 模长
pub fn Cpx::norm(self : Cpx) -> Double {
  self.norm_sq().sqrt()
}

///|
/// 逆（非零复数）
pub fn Cpx::inv(self : Cpx) -> Cpx raise CpxError {
  let d = self.norm_sq()
  if ApproxEq::approx_zero(d, EPS * EPS) {
    raise CpxError::ZeroInverse
  }
  let inv_d = 1.0 / d
  { re: self.re * inv_d, im: -self.im * inv_d, }
}

///|
/// 加法
pub fn Cpx::add(self : Cpx, other : Cpx) -> Cpx {
  { re: self.re + other.re, im: self.im + other.im, }
}

///|
/// 减法
pub fn Cpx::sub(self : Cpx, other : Cpx) -> Cpx {
  { re: self.re - other.re, im: self.im - other.im, }
}

///|
/// 乘法
pub fn Cpx::mul(self : Cpx, other : Cpx) -> Cpx {
  {
    re: self.re * other.re - self.im * other.im,
    im: self.re * other.im + self.im * other.re,
  }
}

///|
/// 除法
pub fn Cpx::div(self : Cpx, other : Cpx) -> Cpx raise CpxError {
  let d = other.norm_sq()
  if ApproxEq::approx_zero(d, EPS * EPS) {
    raise CpxError::ZeroDivide
  }
  let inv_d = 1.0 / d
  {
    re: (self.re * other.re + self.im * other.im) * inv_d,
    im: (self.im * other.re - self.re * other.im) * inv_d,
  }
}

///|
/// 负数
pub fn Cpx::neg(self : Cpx) -> Cpx {
  { re: -self.re, im: -self.im, }
}

///|
impl ApproxEq for Cpx with fn approx_eq(self, other, tol) {
  dbl_approx_eq(self.re, other.re, tol) && dbl_approx_eq(self.im, other.im, tol)
}

///|
impl ApproxEq for Cpx with fn approx_zero(self, tol) {
  dbl_approx_eq(self.re, 0.0, tol) && dbl_approx_eq(self.im, 0.0, tol)
}

///|
impl NumExt for Cpx with fn sq(self) {
  self.mul(self)
}

///|
impl NumExt for Cpx with fn clamp(self, min, max) {
  {
    re: self.re.clamp(min=min.re, max=max.re),
    im: self.im.clamp(min=min.im, max=max.im),
  }
}

///|
impl NumExt for Cpx with fn lerp(self, other, t) {
  {
    re: self.re + (other.re - self.re) * t,
    im: self.im + (other.im - self.im) * t,
  }
}

///|
impl Field for Cpx with fn zero() {
  { re: 0.0, im: 0.0, }
}

///|
impl Field for Cpx with fn one() {
  { re: 1.0, im: 0.0, }
}

///|
impl Field for Cpx with fn abs(self) {
  self.norm()
}

///|
pub extend Cpx with Eq::{not_equal, equal}

///|
pub extend Cpx with @moonbitlang/core/debug.Debug::{to_repr}

///|
pub extend Cpx with ApproxEq::{approx_eq, approx_zero}

///|
pub extend Cpx with NumExt::{sq, clamp, lerp}

///|
pub extend Cpx with Field::{zero, one, abs}
