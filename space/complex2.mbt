// 二维复空间
// 点类型 Complex2，实现 Space Trait（Dim + MetricSpace + TopologicalSpace + Space）
// 复平面点 z = re + im*i，作为实 2D 空间维度=2，度量=模长

///|
/// 二维复空间点
pub struct Complex2 {
  re : Double
  im : Double
}

///|
pub fn Complex2::new(re : Double, im : Double) -> Complex2 {
  { re, im, }
}

///|
pub fn Complex2::re(self : Complex2) -> Double {
  self.re
}

///|
pub fn Complex2::im(self : Complex2) -> Double {
  self.im
}

///|
/// 从实数构造（虚部=0）
pub fn Complex2::from_real(re : Double) -> Complex2 {
  { re, im: 0.0, }
}

///|
/// 从 @util.Cpx 构造
pub fn Complex2::from_cpx(c : @util.Cpx) -> Complex2 {
  { re: c.re, im: c.im, }
}

///|
/// 转为 @util.Cpx
pub fn Complex2::to_cpx(self : Complex2) -> @util.Cpx {
  @util.Cpx::new(self.re, self.im)
}

///|
/// 共轭复数 re - im*i
pub fn Complex2::conj(self : Complex2) -> Complex2 {
  { re: self.re, im: -self.im, }
}

///|
/// 模长 |z| = sqrt(re^2 + im^2)
pub fn Complex2::modulus(self : Complex2) -> Double {
  (self.re * self.re + self.im * self.im).sqrt()
}

///|
/// 辐角 arg(z) = atan2(im, re)
pub fn Complex2::argument(self : Complex2) -> Double {
  @math.atan2(self.im, self.re)
}

///|
/// 复数加法
pub fn Complex2::add(self : Complex2, other : Complex2) -> Complex2 {
  { re: self.re + other.re, im: self.im + other.im, }
}

///|
/// 复数减法
pub fn Complex2::sub(self : Complex2, other : Complex2) -> Complex2 {
  { re: self.re - other.re, im: self.im - other.im, }
}

///|
/// 复数乘法 (a+bi)(c+di) = (ac-bd) + (ad+bc)i
pub fn Complex2::mul(self : Complex2, other : Complex2) -> Complex2 {
  {
    re: self.re * other.re - self.im * other.im,
    im: self.re * other.im + self.im * other.re,
  }
}

///|
/// 标量乘法
pub fn Complex2::scale(self : Complex2, s : Double) -> Complex2 {
  { re: self.re * s, im: self.im * s, }
}

///|
/// 旋转：乘以 e^(i*angle) = cos(angle) + sin(angle)*i
pub fn Complex2::rotate(self : Complex2, angle : Double) -> Complex2 {
  let c = @math.cos(angle)
  let s = @math.sin(angle)
  { re: self.re * c - self.im * s, im: self.re * s + self.im * c, }
}

///|
/// 模平方 |z|^2 = re^2 + im^2
pub fn Complex2::norm_sq(self : Complex2) -> Double {
  self.re * self.re + self.im * self.im
}

///|
/// 维度 = 2（实维度）
impl @atop.Dim for Complex2 with fn dim(_) {
  2
}

///|
/// 度量诱导邻域：distance(self, center) <= radius
impl @atop.TopologicalSpace for Complex2 with fn is_in_neighborhood(
  self,
  center,
  radius,
) {
  @atop.MetricSpace::distance(self, center) <= radius
}

///|
/// 度量：|z1 - z2|（复数差的模长）
impl @atop.MetricSpace for Complex2 with fn distance(self, other) {
  let dr = self.re - other.re
  let di = self.im - other.im
  (dr * dr + di * di).sqrt()
}

///|
/// 空间类型标识
impl Space for Complex2 with fn space_kind(_) {
  SpaceKind::Complex2
}

///|
pub extend Complex2 with Space::{space_kind}
