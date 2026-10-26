// 包围体层次树（BVH）
// 第3层 bv，依赖 util, alg
// 简化版：二叉树结构，支持构建和查询

///|
/// BVH 节点
pub struct BVHNode {
  bbox : Aabb3
  left : BVHNode?
  right : BVHNode?
  leaf_index : Int32?
}

///|
/// 从叶子节点列表构建 BVH（中位数分割法）
pub fn BVHNode::build(leaves : Array[(Aabb3, Int32)]) -> BVHNode? {
  if leaves.length() == 0 {
    None
  } else if leaves.length() == 1 {
    Some({
      bbox: leaves[0].0,
      left: None,
      right: None,
      leaf_index: Some(leaves[0].1),
    })
  } else {
    let mut bbox = leaves[0].0
    for i in 1..<leaves.length() {
      bbox = bbox.union(leaves[i].0)
    }
    let sorted = leaves.copy()
    sorted.sort_by(fn(a, b) {
      let ca = a.0.center()
      let cb = b.0.center()
      ca.x().compare(cb.x())
    })
    let mid = sorted.length() / 2
    let left_arr = []
    let right_arr = []
    for i in 0..<mid {
      left_arr.push(sorted[i])
    }
    for i in mid..<sorted.length() {
      right_arr.push(sorted[i])
    }
    Some({
      bbox,
      left: BVHNode::build(left_arr),
      right: BVHNode::build(right_arr),
      leaf_index: None,
    })
  }
}

///|
/// 查询与给定 AABB 相交的所有叶子索引
pub fn BVHNode::query_intersect(
  self : BVHNode,
  query : Aabb3,
  result : Array[Int32],
) -> Unit {
  if not(self.bbox.intersect(query)) {
    return
  }
  match self.leaf_index {
    Some(idx) => result.push(idx)
    None => {
      match self.left {
        Some(l) => l.query_intersect(query, result)
        None => ()
      }
      match self.right {
        Some(r) => r.query_intersect(query, result)
        None => ()
      }
    }
  }
}

///|
pub fn BVHNode::bbox(self : BVHNode) -> Aabb3 {
  self.bbox
}
