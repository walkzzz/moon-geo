// 流形 Trait
// 第0层 atop

///|
/// 流形空间：局部同胚于欧氏空间的拓扑空间
/// Self = 点类型；流形结构由维度 + 局部坐标卡定义
/// 注：当前仅正向 local_chart，逆映射 chart_inv（局部坐标→流形点）远期补充，流形优化算法需要双向
pub(open) trait Manifold: TopologicalSpace + Dim {
  /// 局部坐标映射：流形点映射到切空间欧氏坐标（R^n）
  fn local_chart(self : Self) -> Array[Double]
}
