// 拓扑空间核心 Trait
// 第0层 atop，代数拓扑内核，终身冻结
// 设计说明：MoonBit 无关联类型，Self = 点类型
// 空间结构由 Trait 方法定义，点集 = Self 的全体取值

///|
/// 维度标记 Trait
pub trait Dim {
  /// 空间维度
  fn dim(self : Self) -> Int32
}

///|
/// 拓扑空间抽象：最普适的空间抽象
/// Self = 点类型；邻域以中心和半径描述（度量诱导拓扑）
pub trait TopologicalSpace {
  /// 邻域判定：self 是否在 center 的 radius 邻域内
  fn is_in_neighborhood(self : Self, center : Self, radius : Double) -> Bool
}
