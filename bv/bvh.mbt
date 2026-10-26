// 包围体层次树（BVH）
// 第3层 bv，依赖 util, alg
// reference implementation, not optimized for scale — 递归 Option 结构 + 每层 sort + array copy，O(n log²n) 高常数，10⁶ 叶子不可用

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
    let ext_x = bbox.max_x() - bbox.min_x()
    let ext_y = bbox.max_y() - bbox.min_y()
    let ext_z = bbox.max_z() - bbox.min_z()
    let axis = if ext_x >= ext_y && ext_x >= ext_z {
      0
    } else if ext_y >= ext_z {
      1
    } else {
      2
    }
    let sorted = leaves.copy()
    sorted.sort_by(fn(a, b) {
      let ca = a.0.center()
      let cb = b.0.center()
      let va = if axis == 0 {
        ca.x()
      } else if axis == 1 {
        ca.y()
      } else {
        ca.z()
      }
      let vb = if axis == 0 {
        cb.x()
      } else if axis == 1 {
        cb.y()
      } else {
        cb.z()
      }
      va.compare(vb)
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
  if !self.bbox.intersect(query) {
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
