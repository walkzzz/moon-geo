// 几何图元核心抽象
// 第2层 alg，依赖 util, space
// Geo Trait：统一几何图元接口，所有图元（点/线/圆/圆锥曲线/平面/球/二次曲面）实现此 Trait

///|
/// 几何维度
pub enum GeoDim {
  Point // 0 维：点
  Curve // 1 维：曲线（直线/圆/圆锥曲线）
  Surface // 2 维：曲面（平面/球/二次曲面）
  Volume // 3 维：体
}

///|
/// 几何图元核心 Trait
/// 统一所有几何图元的接口：维度 + 退化判定
/// 后续迭代扩展：area/length/transform/bbox 等
pub(open) trait Geo {
  /// 几何维度
  fn geo_dim(self : Self) -> GeoDim

  /// 是否退化（如零长线段、零面积圆等）
  fn is_degenerate(self : Self) -> Bool
}
