// 流形 Trait
// 第0层 atop

///|
/// 流形空间：局部同胚于欧氏空间的拓扑空间
/// Self = 点类型；流形结构由维度 + 局部坐标卡定义
pub trait Manifold: TopologicalSpace + Dim {
  /// 局部坐标映射：流形点映射到切空间欧氏坐标（R^n）
  fn local_chart(self : Self) -> Array[Double]
}
