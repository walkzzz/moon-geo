// 壳与实体
// 第4层 brep，依赖 alg
// Shell：HEMesh 中一组连通面的集合
// Solid：HEMesh + 外壳 + 内壳（孔洞）

///|
/// 壳：一组面索引，表示 HEMesh 中的连通曲面
pub struct Shell {
  faces : Array[Int32]
}

///|
pub fn Shell::faces(self : Shell) -> Array[Int32] {
  self.faces
}

///|
pub fn Shell::face_count(self : Shell) -> Int32 {
  self.faces.length()
}

///|
/// 从面索引列表构造壳
pub fn Shell::from_faces(faces : Array[Int32]) -> Shell {
  { faces, }
}

///|
/// 实体：包含 HEMesh + 外壳 + 内壳（孔洞）
pub struct Solid {
  mesh : HEMesh
  outer : Shell
  inner : Array[Shell]
}

///|
pub fn Solid::mesh(self : Solid) -> HEMesh {
  self.mesh
}

///|
pub fn Solid::outer(self : Solid) -> Shell {
  self.outer
}

///|
pub fn Solid::inner(self : Solid) -> Array[Shell] {
  self.inner
}

///|
/// 从 HEMesh 构造单壳实体（所有面属于外壳）
pub fn Solid::from_mesh(mesh : HEMesh) -> Solid {
  let faces = []
  let mut i : Int32 = 0
  while i < mesh.face_count() {
    faces.push(i)
    i += 1
  }
  { mesh, outer: Shell::from_faces(faces), inner: [], }
}

///|
/// 从四面体构造闭合实体
/// 4 个面朝外法向，12 条半边，闭合流形
pub fn Solid::tetrahedron(
  v0 : @alg.Pt3,
  v1 : @alg.Pt3,
  v2 : @alg.Pt3,
  v3 : @alg.Pt3,
) -> Solid {
  let vertices = [
    { pos: v0, he: 0, }, // v0 → he0 (v0→v2)
    { pos: v1, he: 9, }, // v1 → he9 (v1→v2)
    { pos: v2, he: 10, }, // v2 → he10 (v2→v3)
    { pos: v3, he: 11, }, // v3 → he11 (v3→v1)
  ]
  // Face 0: v0→v2→v1（底面，外法向 -z）
  // Face 1: v0→v1→v3（前面，外法向 -y）
  // Face 2: v0→v3→v2（左面，外法向 -x）
  // Face 3: v1→v2→v3（斜面，外法向 +++)
  let half_edges = [
    { origin: 0, twin: 8, next: 1, face: 0, }, // 0: v0→v2
    { origin: 2, twin: 9, next: 2, face: 0, }, // 1: v2→v1
    { origin: 1, twin: 3, next: 0, face: 0, }, // 2: v1→v0
    { origin: 0, twin: 2, next: 4, face: 1, }, // 3: v0→v1
    { origin: 1, twin: 11, next: 5, face: 1, }, // 4: v1→v3
    { origin: 3, twin: 6, next: 3, face: 1, }, // 5: v3→v0
    { origin: 0, twin: 5, next: 7, face: 2, }, // 6: v0→v3
    { origin: 3, twin: 10, next: 8, face: 2, }, // 7: v3→v2
    { origin: 2, twin: 0, next: 6, face: 2, }, // 8: v2→v0
    { origin: 1, twin: 1, next: 10, face: 3, }, // 9: v1→v2
    { origin: 2, twin: 7, next: 11, face: 3, }, // 10: v2→v3
    { origin: 3, twin: 4, next: 9, face: 3, }, // 11: v3→v1
  ]
  let faces = [{ he: 0, }, { he: 3, }, { he: 6, }, { he: 9, }]
  {
    mesh: { vertices, half_edges, faces, },
    outer: Shell::from_faces([0, 1, 2, 3]),
    inner: [],
  }
}

///|
impl Topo for Solid with fn topo_dim(_) {
  TopoDim::Cell
}

///|
impl Topo for Solid with fn topo_is_closed(self) {
  self.mesh.is_closed()
}

///|
impl Topo for Solid with fn topo_is_manifold(self) {
  self.mesh.topo_is_manifold()
}

///|
pub extend Solid with Topo::{topo_dim, topo_is_closed, topo_is_manifold}
