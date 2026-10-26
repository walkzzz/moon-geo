// 顶层 BRep API：统一入口
// 第4层 brep，依赖 alg
// 封装 Solid + 检查 + 修复诊断，提供简洁接口

///|
/// BRep 顶层容器
pub struct BRep {
  solid : Solid
}

///|
pub fn BRep::solid(self : BRep) -> Solid {
  self.solid
}

///|
pub fn BRep::mesh(self : BRep) -> HEMesh {
  self.solid.mesh
}

///|
/// 从 Solid 构造
pub fn BRep::from_solid(solid : Solid) -> BRep {
  { solid, }
}

///|
/// 从 HEMesh 构造
pub fn BRep::from_mesh(mesh : HEMesh) -> BRep {
  { solid: Solid::from_mesh(mesh), }
}

///|
/// 从四面体构造
pub fn BRep::tetrahedron(
  v0 : @alg.Pt3,
  v1 : @alg.Pt3,
  v2 : @alg.Pt3,
  v3 : @alg.Pt3,
) -> BRep {
  { solid: Solid::tetrahedron(v0, v1, v2, v3), }
}

///|
pub fn BRep::vertex_count(self : BRep) -> Int32 {
  self.solid.mesh.vertex_count()
}

///|
pub fn BRep::edge_count(self : BRep) -> Int32 {
  self.solid.mesh.edge_count()
}

///|
pub fn BRep::face_count(self : BRep) -> Int32 {
  self.solid.mesh.face_count()
}

///|
pub fn BRep::is_closed(self : BRep) -> Bool {
  self.solid.mesh.is_closed()
}

///|
pub fn BRep::is_manifold(self : BRep) -> Bool {
  self.solid.mesh.topo_is_manifold()
}

///|
/// 全面检查
pub fn BRep::check(self : BRep) -> CheckResult {
  self.solid.mesh.check()
}

///|
/// 查找重合顶点
pub fn BRep::find_coincident_vertices(
  self : BRep,
  tol : Double,
) -> Array[(Int32, Int32)] {
  self.solid.mesh.find_coincident_vertices(tol)
}

///|
/// 查找孤立顶点
pub fn BRep::find_isolated_vertices(self : BRep) -> Array[Int32] {
  self.solid.mesh.find_isolated_vertices()
}

///|
/// 查找边界半边
pub fn BRep::find_boundary_half_edges(self : BRep) -> Array[Int32] {
  self.solid.mesh.find_boundary_half_edges()
}

///|
impl Topo for BRep with fn topo_dim(_) {
  TopoDim::Cell
}

///|
impl Topo for BRep with fn topo_is_closed(self) {
  self.solid.mesh.is_closed()
}

///|
impl Topo for BRep with fn topo_is_manifold(self) {
  self.solid.mesh.topo_is_manifold()
}

///|
pub extend BRep with Topo::{topo_dim, topo_is_closed, topo_is_manifold}
