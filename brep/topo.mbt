// 拓扑核心抽象
// 第4层 brep，依赖 alg
// Topo Trait：统一拓扑接口，所有拓扑实体（顶点/边/面/体）实现此 Trait

///|
/// 拓扑维度
pub enum TopoDim {
  Vertex // 0 维：顶点
  Edge // 1 维：边
  Face // 2 维：面
  Cell // 3 维：胞腔
}

///|
/// 拓扑核心 Trait
/// 统一所有拓扑实体的接口：维度 + 闭合性 + 流形性
pub(open) trait Topo {
  /// 拓扑维度
  fn topo_dim(self : Self) -> TopoDim

  /// 是否闭合（无边界）
  fn topo_is_closed(self : Self) -> Bool

  /// 是否流形
  fn topo_is_manifold(self : Self) -> Bool
}
