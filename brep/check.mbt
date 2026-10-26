// 拓扑有效性检查
// 第4层 brep，依赖 alg

///|
/// 检查结果
pub struct CheckResult {
  is_manifold : Bool
  is_closed : Bool
  is_oriented : Bool
  is_connected : Bool
}

///|
pub fn CheckResult::is_manifold(self : CheckResult) -> Bool {
  self.is_manifold
}

///|
pub fn CheckResult::is_closed(self : CheckResult) -> Bool {
  self.is_closed
}

///|
pub fn CheckResult::is_oriented(self : CheckResult) -> Bool {
  self.is_oriented
}

///|
pub fn CheckResult::is_connected(self : CheckResult) -> Bool {
  self.is_connected
}

///|
/// 全部检查通过
pub fn CheckResult::is_valid(self : CheckResult) -> Bool {
  self.is_manifold && self.is_closed && self.is_oriented && self.is_connected
}

///|
/// 检查定向一致性：twin.twin == self 且 twin.origin == next.origin
pub fn HEMesh::is_oriented(self : HEMesh) -> Bool {
  let mut i : Int32 = 0
  while i < self.half_edges.length() {
    let he = self.half_edges[i]
    let twin = self.half_edges[he.twin]
    if twin.twin != i {
      return false
    }
    let next_he = self.half_edges[he.next]
    if twin.origin != next_he.origin {
      return false
    }
    i += 1
  }
  true
}

///|
/// 检查面连通性：从面 0 BFS，能否到达所有面
pub fn HEMesh::is_connected(self : HEMesh) -> Bool {
  let n = self.faces.length()
  if n == 0 {
    return true
  }
  let visited = []
  let mut i : Int32 = 0
  while i < n {
    visited.push(false)
    i += 1
  }
  let queue = [0]
  visited[0] = true
  let mut head : Int32 = 0
  while head < queue.length() {
    let face_idx = queue[head]
    let he_list = self.face_half_edges(face_idx)
    let mut j : Int32 = 0
    while j < he_list.length() {
      let he = self.half_edges[he_list[j]]
      let twin_face = self.half_edges[he.twin].face
      if twin_face >= 0 && !visited[twin_face] {
        visited[twin_face] = true
        queue.push(twin_face)
      }
      j += 1
    }
    head += 1
  }
  let mut k : Int32 = 0
  while k < n {
    if !visited[k] {
      return false
    }
    k += 1
  }
  true
}

///|
/// 全面检查
pub fn HEMesh::check(self : HEMesh) -> CheckResult {
  {
    is_manifold: self.topo_is_manifold(),
    is_closed: self.is_closed(),
    is_oriented: self.is_oriented(),
    is_connected: self.is_connected(),
  }
}
