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

///|
/// 相对公差近似相等：|a-b| <= max(|a|,|b|) * rel_tol
/// 适用于大尺度坐标（UTM 米、经纬度），公差随量级自适应
pub fn rel_approx_eq(a : Double, b : Double, rel_tol : Double) -> Bool {
  let diff = dbl_abs(a - b)
  let scale = if dbl_abs(a) > dbl_abs(b) { dbl_abs(a) } else { dbl_abs(b) }
  diff <= scale * rel_tol
}

///|
/// 混合公差近似相等：|a-b| <= max(abs_tol, max(|a|,|b|) * rel_tol)
/// 兼顾小量绝对精度和大量相对精度，推荐作为默认精度判定
pub fn mixed_approx_eq(
  a : Double,
  b : Double,
  abs_tol : Double,
  rel_tol : Double,
) -> Bool {
  let diff = dbl_abs(a - b)
  let scale = if dbl_abs(a) > dbl_abs(b) { dbl_abs(a) } else { dbl_abs(b) }
  let tol = if abs_tol > scale * rel_tol { abs_tol } else { scale * rel_tol }
  diff <= tol
}

///|
/// 精度模式
pub enum PrecisionMode {
  /// 工程级：绝对公差 1e-8，适用 CAD/GIS 一般场景
  Engineering
  /// 测绘级：绝对公差 1e-10，适用高精度测绘
  Surveying
  /// 游戏级：绝对公差 1e-4，适用实时渲染/物理
  Game
  /// 自定义：用户指定公差
  Custom
}

///|
/// 几何计算上下文：封装精度/并行/内存配置
/// 所有算法接受可选 context 参数，默认用 GeoContext::default()
pub struct GeoContext {
  /// 绝对公差
  abs_tol : Double
  /// 相对公差
  rel_tol : Double
  /// 精度模式
  precision_mode : PrecisionMode
  /// 并行度（0 = 自动）
  parallelism : Int32
  /// 内存上限（字节，0 = 无限制）
  memory_limit : Int64
}

///|
/// 默认上下文：工程级精度
pub fn GeoContext::default() -> GeoContext {
  {
    abs_tol: 1.0e-8,
    rel_tol: 1.0e-10,
    precision_mode: PrecisionMode::Engineering,
    parallelism: 0,
    memory_limit: 0L,
  }
}

///|
/// 测绘级上下文
pub fn GeoContext::surveying() -> GeoContext {
  {
    abs_tol: 1.0e-10,
    rel_tol: 1.0e-12,
    precision_mode: PrecisionMode::Surveying,
    parallelism: 0,
    memory_limit: 0L,
  }
}

///|
/// 游戏级上下文
pub fn GeoContext::game() -> GeoContext {
  {
    abs_tol: 1.0e-4,
    rel_tol: 1.0e-6,
    precision_mode: PrecisionMode::Game,
    parallelism: 0,
    memory_limit: 0L,
  }
}

///|
/// 自定义上下文
pub fn GeoContext::custom(abs_tol : Double, rel_tol : Double) -> GeoContext {
  {
    abs_tol,
    rel_tol,
    precision_mode: PrecisionMode::Custom,
    parallelism: 0,
    memory_limit: 0L,
  }
}

///|
/// 在给定上下文下判定近似相等（混合公差）
pub fn ctx_approx_eq(a : Double, b : Double, ctx : GeoContext) -> Bool {
  mixed_approx_eq(a, b, ctx.abs_tol, ctx.rel_tol)
}
