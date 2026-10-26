// 拓扑修复诊断
// 第4层 brep，依赖 alg
// 不可变原则：诊断函数返回问题列表，不修改原网格

///|
/// 查找重合顶点对（距离 <= tol）
pub fn HEMesh::find_coincident_vertices(
  self : HEMesh,
  tol : Double,
) -> Array[(Int32, Int32)] {
  let result = []
  let n = self.vertices.length()
  let mut i : Int32 = 0
  while i < n {
    let mut j : Int32 = i + 1
    while j < n {
      let dist = self.vertices[i].pos.distance_to(self.vertices[j].pos)
      if dist <= tol {
        result.push((i, j))
      }
      j += 1
    }
    i += 1
  }
  result
}

///|
/// 查找孤立顶点（he < 0，无出发半边）
pub fn HEMesh::find_isolated_vertices(self : HEMesh) -> Array[Int32] {
  let result = []
  let mut i : Int32 = 0
  while i < self.vertices.length() {
    if self.vertices[i].he < 0 {
      result.push(i)
    }
    i += 1
  }
  result
}

///|
/// 查找边界半边（face < 0）
pub fn HEMesh::find_boundary_half_edges(self : HEMesh) -> Array[Int32] {
  let result = []
  let mut i : Int32 = 0
  while i < self.half_edges.length() {
    if self.half_edges[i].face < 0 {
      result.push(i)
    }
    i += 1
  }
  result
}
