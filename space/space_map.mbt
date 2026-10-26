// 跨空间映射抽象
// 第1层 space，依赖 atop
// SpaceMap：从源空间到目标空间的映射
// 注：MoonBit 当前不支持泛型 trait 类型参数，map 方法由具体类型直接提供
// 应用：嵌入（Euclid2 → Euclid3, z=0）、投影（Euclid3 → Euclid2, 丢弃 z）、
//       坐标变换、CRS 变换（前端 platform/crs 层将复用此模式）

///|
/// 跨空间映射 Trait：映射的元数据接口
/// Self = 映射类型；具体 map 方法由各映射类型直接提供（类型安全）
/// source_kind/target_kind 标识映射的源/目标空间类型
pub trait SpaceMap {
  /// 源空间类型
  fn source_kind(self : Self) -> SpaceKind

  /// 目标空间类型
  fn target_kind(self : Self) -> SpaceKind

  /// 是否单射（injective）：不同源点映射到不同目标点
  fn is_injective(self : Self) -> Bool

  /// 是否满射（surjective）：目标空间每点都有原像
  fn is_surjective(self : Self) -> Bool
}

///|
/// Euclid2 → Euclid3 嵌入映射（z = z_offset）
/// 等距嵌入：保持距离 d(f(a), f(b)) = d(a, b)，单射非满射
pub struct Embed2In3 {
  z_offset : Double
}

///|
pub fn Embed2In3::new() -> Embed2In3 {
  { z_offset: 0.0, }
}

///|
/// 带 z 偏移的嵌入
pub fn Embed2In3::with_z(z_offset : Double) -> Embed2In3 {
  { z_offset, }
}

///|
/// 嵌入映射：Euclid2 → Euclid3
pub fn Embed2In3::map(self : Embed2In3, src : Euclid2) -> Euclid3 {
  Euclid3::new(src.x(), src.y(), self.z_offset)
}

///|
impl SpaceMap for Embed2In3 with fn source_kind(_) {
  SpaceKind::Euclidean2
}

///|
impl SpaceMap for Embed2In3 with fn target_kind(_) {
  SpaceKind::Euclidean3
}

///|
impl SpaceMap for Embed2In3 with fn is_injective(_) {
  true
}

///|
impl SpaceMap for Embed2In3 with fn is_surjective(_) {
  false
}

///|
/// Euclid3 → Euclid2 正交投影（丢弃 z）
/// 非等距：d(f(a), f(b)) <= d(a, b)，满射非单射
pub struct Project3To2 {
  dummy : Unit
}

///|
pub fn Project3To2::new() -> Project3To2 {
  { dummy: (), }
}

///|
/// 投影映射：Euclid3 → Euclid2
pub fn Project3To2::map(self : Project3To2, src : Euclid3) -> Euclid2 {
  ignore(self)
  Euclid2::new(src.x(), src.y())
}

///|
impl SpaceMap for Project3To2 with fn source_kind(_) {
  SpaceKind::Euclidean3
}

///|
impl SpaceMap for Project3To2 with fn target_kind(_) {
  SpaceKind::Euclidean2
}

///|
impl SpaceMap for Project3To2 with fn is_injective(_) {
  false
}

///|
impl SpaceMap for Project3To2 with fn is_surjective(_) {
  true
}
