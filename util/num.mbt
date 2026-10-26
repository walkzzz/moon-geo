// 基础数值工具：数值扩展、近似相等、公差管理
// 第-1层 util，零几何语义，完全独立可编译

///|
/// 默认浮点计算公差
pub const EPS : Double = 1.0e-8

///|
/// 最小正数值
pub const MIN_POSITIVE : Double = 1.0e-12

///|
/// 浮点近似相等：所有几何比较的基准
pub trait ApproxEq {
  fn approx_eq(self : Self, other : Self, tol : Double) -> Bool
  fn approx_zero(self : Self, tol : Double) -> Bool
}

///|
/// 数值通用扩展（工程便利接口，非代数抽象）
pub trait NumExt {
  fn sq(self : Self) -> Self
  fn clamp(self : Self, min : Self, max : Self) -> Self
  fn lerp(self : Self, other : Self, t : Double) -> Self
}

///|
/// 数域抽象：实数、复数统一接口（abs 返回 Double 为务实选择，纯范畴定义应返回 Self 的有序子域）
pub trait Field: NumExt + ApproxEq {
  fn zero() -> Self
  fn one() -> Self
  fn abs(self : Self) -> Double
}

///|
/// Double 绝对值（内部辅助）
fn dbl_abs(x : Double) -> Double {
  if x < 0.0 {
    -x
  } else {
    x
  }
}

///|
/// Double 近似相等（导出自由函数，供黑盒测试与跨包使用）
pub fn dbl_approx_eq(a : Double, b : Double, tol : Double) -> Bool {
  dbl_abs(a - b) <= tol
}

///|
/// Double 近似为零
pub fn dbl_approx_zero(a : Double, tol : Double) -> Bool {
  dbl_abs(a) <= tol
}

///|
impl ApproxEq for Double with fn approx_eq(self, other, tol) {
  dbl_abs(self - other) <= tol
}

///|
impl ApproxEq for Double with fn approx_zero(self, tol) {
  dbl_abs(self) <= tol
}

///|
impl NumExt for Double with fn sq(self) {
  self * self
}

///|
impl NumExt for Double with fn clamp(self, min, max) {
  if self < min {
    min
  } else if self > max {
    max
  } else {
    self
  }
}

///|
impl NumExt for Double with fn lerp(self, other, t) {
  self + (other - self) * t
}

///|
impl Field for Double with fn zero() {
  0.0
}

///|
impl Field for Double with fn one() {
  1.0
}

///|
impl Field for Double with fn abs(self) {
  dbl_abs(self)
}
