// 半边数据结构（Half-Edge Data Structure）
// 第4层 brep，依赖 alg
// 用于表示流形表面的拓扑关系
// 参考：CGAL Polyhedron, OpenMesh HalfEdge
// 索引用 Int 索引代替指针，-1 表示无效/边界

///|
/// 顶点
pub struct Vtx {
  pos : @alg.Pt3
  he : Int32 // 从该顶点出发的半边索引，-1 表示无
}

///|
pub fn Vtx::pos(self : Vtx) -> @alg.Pt3 {
  self.pos
}

///|
pub fn Vtx::he(self : Vtx) -> Int32 {
  self.he
}

///|
/// 半边
pub struct HEdge {
  origin : Int32 // 起始顶点索引
  twin : Int32 // 对偶半边索引
  next : Int32 // 同面下一条半边索引
  face : Int32 // 所属面索引，-1 表示边界
}

///|
pub fn HEdge::origin(self : HEdge) -> Int32 {
  self.origin
}

///|
pub fn HEdge::twin(self : HEdge) -> Int32 {
  self.twin
}

///|
pub fn HEdge::next(self : HEdge) -> Int32 {
  self.next
}

///|
pub fn HEdge::face(self : HEdge) -> Int32 {
  self.face
}

///|
/// 面
pub struct Face {
  he : Int32 // 边界起始半边索引
}

///|
pub fn Face::he(self : Face) -> Int32 {
  self.he
}

///|
/// 半边网格
pub struct HEMesh {
  vertices : Array[Vtx]
  half_edges : Array[HEdge]
  faces : Array[Face]
}

///|
pub fn HEMesh::vertex_count(self : HEMesh) -> Int32 {
  self.vertices.length()
}

///|
pub fn HEMesh::half_edge_count(self : HEMesh) -> Int32 {
  self.half_edges.length()
}

///|
pub fn HEMesh::edge_count(self : HEMesh) -> Int32 {
  self.half_edges.length() / 2
}

///|
pub fn HEMesh::face_count(self : HEMesh) -> Int32 {
  self.faces.length()
}

///|
pub fn HEMesh::vertex(self : HEMesh, i : Int32) -> Vtx {
  self.vertices[i]
}

///|
pub fn HEMesh::half_edge(self : HEMesh, i : Int32) -> HEdge {
  self.half_edges[i]
}

///|
pub fn HEMesh::face(self : HEMesh, i : Int32) -> Face {
  self.faces[i]
}

///|
/// 绕面的半边环
pub fn HEMesh::face_half_edges(self : HEMesh, face_idx : Int32) -> Array[Int32] {
  let result = []
  let start = self.faces[face_idx].he
  let mut current = start
  let mut first = true
  while first || current != start {
    result.push(current)
    current = self.half_edges[current].next
    first = false
  }
  result
}

///|
/// 绕顶点的半边环（通过 twin.next 旋转）
pub fn HEMesh::vertex_half_edges(
  self : HEMesh,
  vtx_idx : Int32,
) -> Array[Int32] {
  let result = []
  let start = self.vertices[vtx_idx].he
  if start < 0 {
    return result
  }
  let mut current = start
  let mut first = true
  while first || current != start {
    result.push(current)
    let twin_idx = self.half_edges[current].twin
    current = self.half_edges[twin_idx].next
    first = false
  }
  result
}

///|
/// 顶点的邻居顶点索引
pub fn HEMesh::vertex_neighbors(self : HEMesh, vtx_idx : Int32) -> Array[Int32] {
  let half_edges = self.vertex_half_edges(vtx_idx)
  let result = []
  let mut i = 0
  while i < half_edges.length() {
    let he_idx = half_edges[i]
    let he = self.half_edges[he_idx]
    let twin = self.half_edges[he.twin]
    result.push(twin.origin)
    i += 1
  }
  result
}

///|
/// 是否闭合（所有半边都属于某个面，无边界）
pub fn HEMesh::is_closed(self : HEMesh) -> Bool {
  let mut i = 0
  while i < self.half_edges.length() {
    if self.half_edges[i].face < 0 {
      return false
    }
    i += 1
  }
  true
}

///|
/// 从三角形构造单面网格
/// 顶点顺序 p0 → p1 → p2（逆时针为正面）
pub fn HEMesh::from_triangle(
  p0 : @alg.Pt3,
  p1 : @alg.Pt3,
  p2 : @alg.Pt3,
) -> HEMesh {
  let vertices = [{ pos: p0, he: 0, }, { pos: p1, he: 2, }, { pos: p2, he: 4, }]
  // 面 0: he0→he2→he4（逆时针）
  // 边界外环: he1→he5→he3（顺时针）
  let half_edges = [
    { origin: 0, twin: 1, next: 2, face: 0, }, // 0: v0→v1
    { origin: 1, twin: 0, next: 5, face: -1, }, // 1: v1→v0 (边界)
    { origin: 1, twin: 3, next: 4, face: 0, }, // 2: v1→v2
    { origin: 2, twin: 2, next: 1, face: -1, }, // 3: v2→v1 (边界)
    { origin: 2, twin: 5, next: 0, face: 0, }, // 4: v2→v0
    { origin: 0, twin: 4, next: 3, face: -1, }, // 5: v0→v2 (边界)
  ]
  let faces = [{ he: 0, }]
  { vertices, half_edges, faces, }
}

///|
/// 从两个共享边的三角形构造网格
/// 三角形 1: p0→p1→p2，三角形 2: p1→p3→p2（共享边 p1-p2）
pub fn HEMesh::from_two_triangles(
  p0 : @alg.Pt3,
  p1 : @alg.Pt3,
  p2 : @alg.Pt3,
  p3 : @alg.Pt3,
) -> HEMesh {
  let vertices = [
    { pos: p0, he: 0, },
    { pos: p1, he: 2, },
    { pos: p2, he: 4, },
    { pos: p3, he: 8, },
  ]
  // 面 0: he0→he2→he4（p0→p1→p2）
  // 面 1: he6→he8→he3（p1→p3→p2）
  // 共享边: he2(v1→v2) twin=he3(v2→v1)
  // 边界外环: he1→he5→he9→he7
  let half_edges = [
    { origin: 0, twin: 1, next: 2, face: 0, }, // 0: v0→v1
    { origin: 1, twin: 0, next: 5, face: -1, }, // 1: v1→v0 (边界)
    { origin: 1, twin: 3, next: 4, face: 0, }, // 2: v1→v2 (共享边)
    { origin: 2, twin: 2, next: 6, face: 1, }, // 3: v2→v1 (共享边)
    { origin: 2, twin: 5, next: 0, face: 0, }, // 4: v2→v0
    { origin: 0, twin: 4, next: 9, face: -1, }, // 5: v0→v2 (边界)
    { origin: 1, twin: 7, next: 8, face: 1, }, // 6: v1→v3
    { origin: 3, twin: 6, next: 1, face: -1, }, // 7: v3→v1 (边界)
    { origin: 3, twin: 9, next: 3, face: 1, }, // 8: v3→v2
    { origin: 2, twin: 8, next: 7, face: -1, }, // 9: v2→v3 (边界)
  ]
  let faces = [{ he: 0, }, { he: 6, }]
  { vertices, half_edges, faces, }
}

///|
impl Topo for HEMesh with fn topo_dim(_) {
  TopoDim::Face
}

///|
impl Topo for HEMesh with fn topo_is_closed(self) {
  self.is_closed()
}

///|
impl Topo for HEMesh with fn topo_is_manifold(self) {
  let mut i = 0
  while i < self.vertices.length() {
    if self.vertices[i].he < 0 {
      return false
    }
    i += 1
  }
  true
}

///|
impl Topo for HEMesh with fn topo_is_oriented(self) {
  self.is_oriented()
}

///|
impl Topo for HEMesh with fn topo_is_connected(self) {
  self.is_connected()
}

///|
pub extend HEMesh with Topo::{
  topo_dim,
  topo_is_closed,
  topo_is_manifold,
  topo_is_oriented,
  topo_is_connected,
}

///|
/// 从三角形列表构造半边网格
/// points: 顶点坐标数组；triangles: 三角形顶点索引三元组（逆时针）
/// 自动匹配共享边、创建边界半边、设置 next 关系
/// // reference impl, O(E²) twin matching, not for large meshes
/// raise GeoError::OutOfBounds — 顶点索引越界
/// raise GeoError::TopoInconsistent — 非流形输入（3+ 三角形共享同一边）
pub fn HEMesh::from_triangles(
  points : Array[@alg.Pt3],
  triangles : Array[(Int32, Int32, Int32)],
) -> HEMesh raise @util.GeoError {
  let n_verts = points.length()
  // P0: 越界校验
  for tri_idx in 0..<triangles.length() {
    let tri = triangles[tri_idx]
    let v0 = tri.0
    let v1 = tri.1
    let v2 = tri.2
    if v0 < 0 ||
      v0 >= n_verts ||
      v1 < 0 ||
      v1 >= n_verts ||
      v2 < 0 ||
      v2 >= n_verts {
      raise @util.GeoError::OutOfBounds(
        "from_triangles: 三角形 \{tri_idx} 顶点索引越界 (\{v0},\{v1},\{v2}), n_verts=\{n_verts}",
      )
    }
  }
  let vertices : Array[Vtx] = []
  for i in 0..<n_verts {
    vertices.push({ pos: points[i], he: -1, })
  }
  let half_edges : Array[HEdge] = []
  let faces : Array[Face] = []
  // 创建面内半边
  for tri_idx in 0..<triangles.length() {
    let tri = triangles[tri_idx]
    let v0 = tri.0
    let v1 = tri.1
    let v2 = tri.2
    let he_base = half_edges.length()
    half_edges.push({ origin: v0, twin: -1, next: he_base + 1, face: tri_idx, })
    half_edges.push({ origin: v1, twin: -1, next: he_base + 2, face: tri_idx, })
    half_edges.push({ origin: v2, twin: -1, next: he_base, face: tri_idx, })
    faces.push({ he: he_base, })
    if vertices[v0].he == -1 {
      vertices[v0] = { ..vertices[v0], he: he_base, }
    }
    if vertices[v1].he == -1 {
      vertices[v1] = { ..vertices[v1], he: he_base + 1, }
    }
    if vertices[v2].he == -1 {
      vertices[v2] = { ..vertices[v2], he: he_base + 2, }
    }
  }
  // P2: 非流形检测 — 每条无向边最多 2 条半边
  let n_interior = half_edges.length()
  for i in 0..<n_interior {
    let v_start = half_edges[i].origin
    let v_end = half_edges[half_edges[i].next].origin
    let mut edge_count = 0
    for j in 0..<n_interior {
      let j_end = half_edges[half_edges[j].next].origin
      if (half_edges[j].origin == v_start && j_end == v_end) ||
        (half_edges[j].origin == v_end && j_end == v_start) {
        edge_count += 1
      }
    }
    if edge_count > 2 {
      raise @util.GeoError::TopoInconsistent(
        "from_triangles: 非流形输入 — 边 (\{v_start}—\{v_end}) 被 \{edge_count} 条半边共享（最多 2）",
      )
    }
  }
  // 匹配 twin：对每条面内半边找反向半边
  for i in 0..<n_interior {
    if half_edges[i].twin != -1 {
      continue
    }
    let v_start = half_edges[i].origin
    let v_end = half_edges[half_edges[i].next].origin
    for j in 0..<n_interior {
      if j == i || half_edges[j].twin != -1 {
        continue
      }
      let j_end = half_edges[half_edges[j].next].origin
      if half_edges[j].origin == v_end && j_end == v_start {
        half_edges[i] = { ..half_edges[i], twin: j, }
        half_edges[j] = { ..half_edges[j], twin: i, }
        break
      }
    }
  }
  // 为无 twin 的面内半边创建边界半边
  for i in 0..<n_interior {
    if half_edges[i].twin == -1 {
      let v_end = half_edges[half_edges[i].next].origin
      let boundary_he = half_edges.length()
      half_edges.push({ origin: v_end, twin: i, next: -1, face: -1, })
      half_edges[i] = { ..half_edges[i], twin: boundary_he, }
    }
  }
  // 设置边界半边的 next：boundary.next = twin.prev.twin
  // 其中 prev = twin.next.next（面内半边的前驱）
  let n_total = half_edges.length()
  for i in n_interior..<n_total {
    let twin = half_edges[i].twin
    let prev_interior = half_edges[half_edges[twin].next].next
    let prev_boundary = half_edges[prev_interior].twin
    half_edges[i] = { ..half_edges[i], next: prev_boundary, }
  }
  { vertices, half_edges, faces, }
}
