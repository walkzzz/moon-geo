// brep 白盒测试：Topo Trait + Vtx/HEdge/Face/HEMesh + Shell/Solid + check/repair + BRep API
// 含 FAKE 类型测试 + E2E 链路测试

///|
test "HEMesh from_triangle basic" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  assert_eq(mesh.vertex_count(), 3)
  assert_eq(mesh.edge_count(), 3)
  assert_eq(mesh.face_count(), 1)
  assert_eq(mesh.half_edge_count(), 6)
}

///|
test "HEMesh face_half_edges" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  let he_list = mesh.face_half_edges(0)
  assert_eq(he_list.length(), 3)
  assert_eq(he_list[0], 0)
  assert_eq(he_list[1], 2)
  assert_eq(he_list[2], 4)
}

///|
test "HEMesh vertex_half_edges single triangle" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  let v0_he = mesh.vertex_half_edges(0)
  assert_eq(v0_he.length(), 2)
  let v1_he = mesh.vertex_half_edges(1)
  assert_eq(v1_he.length(), 2)
  let v2_he = mesh.vertex_half_edges(2)
  assert_eq(v2_he.length(), 2)
}

///|
test "HEMesh vertex_neighbors single triangle" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  let v0_nb = mesh.vertex_neighbors(0)
  assert_eq(v0_nb.length(), 2)
  let v1_nb = mesh.vertex_neighbors(1)
  assert_eq(v1_nb.length(), 2)
  let v2_nb = mesh.vertex_neighbors(2)
  assert_eq(v2_nb.length(), 2)
}

///|
test "HEMesh is_closed single triangle" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  assert_false(mesh.is_closed())
}

///|
test "HEMesh from_two_triangles basic" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let p3 = @alg.Pt3::new(1.0, 1.0, 0.0)
  let mesh = HEMesh::from_two_triangles(p0, p1, p2, p3)
  assert_eq(mesh.vertex_count(), 4)
  assert_eq(mesh.edge_count(), 5)
  assert_eq(mesh.face_count(), 2)
  assert_eq(mesh.half_edge_count(), 10)
}

///|
test "HEMesh from_two_triangles shared edge twin" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let p3 = @alg.Pt3::new(1.0, 1.0, 0.0)
  let mesh = HEMesh::from_two_triangles(p0, p1, p2, p3)
  let he2 = mesh.half_edge(2)
  let he3 = mesh.half_edge(3)
  assert_eq(he2.twin(), 3)
  assert_eq(he3.twin(), 2)
  assert_eq(he2.face(), 0)
  assert_eq(he3.face(), 1)
}

///|
test "HEMesh from_two_triangles face_half_edges" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let p3 = @alg.Pt3::new(1.0, 1.0, 0.0)
  let mesh = HEMesh::from_two_triangles(p0, p1, p2, p3)
  let f0_he = mesh.face_half_edges(0)
  assert_eq(f0_he.length(), 3)
  assert_eq(f0_he[0], 0)
  assert_eq(f0_he[1], 2)
  assert_eq(f0_he[2], 4)
  let f1_he = mesh.face_half_edges(1)
  assert_eq(f1_he.length(), 3)
  assert_eq(f1_he[0], 6)
  assert_eq(f1_he[1], 8)
  assert_eq(f1_he[2], 3)
}

///|
test "HEMesh from_two_triangles vertex_neighbors" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let p3 = @alg.Pt3::new(1.0, 1.0, 0.0)
  let mesh = HEMesh::from_two_triangles(p0, p1, p2, p3)
  let v1_nb = mesh.vertex_neighbors(1)
  assert_eq(v1_nb.length(), 3)
  let v2_nb = mesh.vertex_neighbors(2)
  assert_eq(v2_nb.length(), 3)
  let v0_nb = mesh.vertex_neighbors(0)
  assert_eq(v0_nb.length(), 2)
  let v3_nb = mesh.vertex_neighbors(3)
  assert_eq(v3_nb.length(), 2)
}

///|
test "HEMesh from_two_triangles is_closed" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let p3 = @alg.Pt3::new(1.0, 1.0, 0.0)
  let mesh = HEMesh::from_two_triangles(p0, p1, p2, p3)
  assert_false(mesh.is_closed())
}

///|
test "HEMesh Topo trait" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  assert_true(Topo::topo_dim(mesh) is TopoDim::Face)
  assert_false(Topo::topo_is_closed(mesh))
  assert_true(Topo::topo_is_manifold(mesh))
}

///|
test "HEMesh pub extend dot syntax" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  assert_true(mesh.topo_dim() is TopoDim::Face)
  assert_false(mesh.topo_is_closed())
  assert_true(mesh.topo_is_manifold())
}

///|
test "FAKE: HEMesh field completeness" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  let _ = mesh.vertex_count()
  let _ = mesh.edge_count()
  let _ = mesh.face_count()
  let _ = mesh.half_edge_count()
  let _ = mesh.is_closed()
  let _ = mesh.vertex(0)
  let _ = mesh.half_edge(0)
  let _ = mesh.face(0)
  let _ = mesh.face_half_edges(0)
  let _ = mesh.vertex_half_edges(0)
  let _ = mesh.vertex_neighbors(0)
  let _ = Topo::topo_dim(mesh)
  let _ = Topo::topo_is_closed(mesh)
  let _ = Topo::topo_is_manifold(mesh)
}

///|
test "E2E: two triangles -> neighbor traversal -> verify shared edge" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let p3 = @alg.Pt3::new(1.0, 1.0, 0.0)
  let mesh = HEMesh::from_two_triangles(p0, p1, p2, p3)
  let v1_nb = mesh.vertex_neighbors(1)
  assert_eq(v1_nb.length(), 3)
  let v2_nb = mesh.vertex_neighbors(2)
  assert_eq(v2_nb.length(), 3)
  let f0_he = mesh.face_half_edges(0)
  let f1_he = mesh.face_half_edges(1)
  assert_eq(f0_he.length(), 3)
  assert_eq(f1_he.length(), 3)
  let he2 = mesh.half_edge(2)
  let he3 = mesh.half_edge(3)
  assert_eq(he2.twin(), 3)
  assert_eq(he3.twin(), 2)
}

///|
test "Shell basic" {
  let shell = Shell::from_faces([0, 1, 2])
  assert_eq(shell.face_count(), 3)
  assert_eq(shell.faces().length(), 3)
}

///|
test "Solid from_mesh" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  let solid = Solid::from_mesh(mesh)
  assert_eq(solid.outer().face_count(), 1)
  assert_eq(solid.inner().length(), 0)
  assert_eq(solid.mesh().vertex_count(), 3)
}

///|
test "Solid tetrahedron basic" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let solid = Solid::tetrahedron(v0, v1, v2, v3)
  let mesh = solid.mesh()
  assert_eq(mesh.vertex_count(), 4)
  assert_eq(mesh.edge_count(), 6)
  assert_eq(mesh.face_count(), 4)
  assert_eq(mesh.half_edge_count(), 12)
  assert_eq(solid.outer().face_count(), 4)
}

///|
test "Solid tetrahedron is_closed" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let solid = Solid::tetrahedron(v0, v1, v2, v3)
  assert_true(solid.mesh().is_closed())
}

///|
test "Solid tetrahedron vertex_neighbors" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let mesh = Solid::tetrahedron(v0, v1, v2, v3).mesh()
  // 每个顶点在四面体中连接其他 3 个顶点
  assert_eq(mesh.vertex_neighbors(0).length(), 3)
  assert_eq(mesh.vertex_neighbors(1).length(), 3)
  assert_eq(mesh.vertex_neighbors(2).length(), 3)
  assert_eq(mesh.vertex_neighbors(3).length(), 3)
}

///|
test "Solid Topo trait" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let solid = Solid::tetrahedron(v0, v1, v2, v3)
  assert_true(Topo::topo_dim(solid) is TopoDim::Cell)
  assert_true(Topo::topo_is_closed(solid))
  assert_true(Topo::topo_is_manifold(solid))
}

///|
test "Solid pub extend dot syntax" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let solid = Solid::tetrahedron(v0, v1, v2, v3)
  assert_true(solid.topo_dim() is TopoDim::Cell)
  assert_true(solid.topo_is_closed())
  assert_true(solid.topo_is_manifold())
}

///|
test "HEMesh is_oriented triangle" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  assert_true(mesh.is_oriented())
}

///|
test "HEMesh is_oriented tetrahedron" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let mesh = Solid::tetrahedron(v0, v1, v2, v3).mesh()
  assert_true(mesh.is_oriented())
}

///|
test "HEMesh is_connected triangle" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  assert_true(mesh.is_connected())
}

///|
test "HEMesh is_connected two_triangles" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let p3 = @alg.Pt3::new(1.0, 1.0, 0.0)
  let mesh = HEMesh::from_two_triangles(p0, p1, p2, p3)
  assert_true(mesh.is_connected())
}

///|
test "HEMesh is_connected tetrahedron" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let mesh = Solid::tetrahedron(v0, v1, v2, v3).mesh()
  assert_true(mesh.is_connected())
}

///|
test "HEMesh check tetrahedron" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let mesh = Solid::tetrahedron(v0, v1, v2, v3).mesh()
  let result = mesh.check()
  assert_true(result.is_manifold())
  assert_true(result.is_closed())
  assert_true(result.is_oriented())
  assert_true(result.is_connected())
  assert_true(result.is_valid())
}

///|
test "HEMesh check triangle not_closed" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  let result = mesh.check()
  assert_true(result.is_manifold())
  assert_false(result.is_closed())
  assert_true(result.is_oriented())
  assert_true(result.is_connected())
  assert_false(result.is_valid())
}

///|
test "HEMesh find_coincident_vertices none" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let mesh = Solid::tetrahedron(v0, v1, v2, v3).mesh()
  let pairs = mesh.find_coincident_vertices(1.0e-10)
  assert_eq(pairs.length(), 0)
}

///|
test "HEMesh find_coincident_vertices with tolerance" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let mesh = Solid::tetrahedron(v0, v1, v2, v3).mesh()
  // tol=2.0 应找到所有 6 对（C(4,2)=6）
  let pairs = mesh.find_coincident_vertices(2.0)
  assert_eq(pairs.length(), 6)
}

///|
test "HEMesh find_isolated_vertices none" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let mesh = Solid::tetrahedron(v0, v1, v2, v3).mesh()
  let isolated = mesh.find_isolated_vertices()
  assert_eq(isolated.length(), 0)
}

///|
test "HEMesh find_boundary_half_edges triangle" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  let boundary = mesh.find_boundary_half_edges()
  assert_eq(boundary.length(), 3)
}

///|
test "HEMesh find_boundary_half_edges tetrahedron" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let mesh = Solid::tetrahedron(v0, v1, v2, v3).mesh()
  let boundary = mesh.find_boundary_half_edges()
  assert_eq(boundary.length(), 0)
}

///|
test "BRep tetrahedron" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let brep = BRep::tetrahedron(v0, v1, v2, v3)
  assert_eq(brep.vertex_count(), 4)
  assert_eq(brep.edge_count(), 6)
  assert_eq(brep.face_count(), 4)
  assert_true(brep.is_closed())
  assert_true(brep.is_manifold())
}

///|
test "BRep check" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let brep = BRep::tetrahedron(v0, v1, v2, v3)
  let result = brep.check()
  assert_true(result.is_valid())
}

///|
test "BRep from_mesh" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  let brep = BRep::from_mesh(mesh)
  assert_eq(brep.vertex_count(), 3)
  assert_eq(brep.face_count(), 1)
  assert_false(brep.is_closed())
}

///|
test "BRep Topo trait" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let brep = BRep::tetrahedron(v0, v1, v2, v3)
  assert_true(Topo::topo_dim(brep) is TopoDim::Cell)
  assert_true(Topo::topo_is_closed(brep))
  assert_true(Topo::topo_is_manifold(brep))
}

///|
test "BRep pub extend dot syntax" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let brep = BRep::tetrahedron(v0, v1, v2, v3)
  assert_true(brep.topo_dim() is TopoDim::Cell)
  assert_true(brep.topo_is_closed())
  assert_true(brep.topo_is_manifold())
}

///|
test "FAKE: Shell/Solid/CheckResult/BRep field completeness" {
  let shell = Shell::from_faces([0])
  let _ = shell.faces()
  let _ = shell.face_count()
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let solid = Solid::tetrahedron(v0, v1, v2, v3)
  let _ = solid.mesh()
  let _ = solid.outer()
  let _ = solid.inner()
  let _ = Topo::topo_dim(solid)
  let _ = Topo::topo_is_closed(solid)
  let _ = Topo::topo_is_manifold(solid)
  let mesh = solid.mesh()
  let result = mesh.check()
  let _ = result.is_manifold()
  let _ = result.is_closed()
  let _ = result.is_oriented()
  let _ = result.is_connected()
  let _ = result.is_valid()
  let brep = BRep::tetrahedron(v0, v1, v2, v3)
  let _ = brep.solid()
  let _ = brep.mesh()
  let _ = brep.vertex_count()
  let _ = brep.edge_count()
  let _ = brep.face_count()
  let _ = brep.is_closed()
  let _ = brep.is_manifold()
  let _ = brep.check()
  let _ = brep.find_coincident_vertices(1.0e-10)
  let _ = brep.find_isolated_vertices()
  let _ = brep.find_boundary_half_edges()
  let _ = Topo::topo_dim(brep)
  let _ = Topo::topo_is_closed(brep)
  let _ = Topo::topo_is_manifold(brep)
}

///|
test "E2E: tetrahedron -> check -> repair diagnostics -> all valid" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let brep = BRep::tetrahedron(v0, v1, v2, v3)
  let check_result = brep.check()
  assert_true(check_result.is_valid())
  let coincident = brep.find_coincident_vertices(1.0e-10)
  assert_eq(coincident.length(), 0)
  let isolated = brep.find_isolated_vertices()
  assert_eq(isolated.length(), 0)
  let boundary = brep.find_boundary_half_edges()
  assert_eq(boundary.length(), 0)
}

///|
test "Topo trait topo_is_oriented HEMesh" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  assert_true(Topo::topo_is_oriented(mesh))
  assert_true(mesh.topo_is_oriented())
}

///|
test "Topo trait topo_is_connected HEMesh" {
  let p0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let p1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let p2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let mesh = HEMesh::from_triangle(p0, p1, p2)
  assert_true(Topo::topo_is_connected(mesh))
  assert_true(mesh.topo_is_connected())
}

///|
test "Topo trait topo_is_oriented Solid" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let solid = Solid::tetrahedron(v0, v1, v2, v3)
  assert_true(Topo::topo_is_oriented(solid))
  assert_true(solid.topo_is_oriented())
}

///|
test "Topo trait topo_is_connected Solid" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let solid = Solid::tetrahedron(v0, v1, v2, v3)
  assert_true(Topo::topo_is_connected(solid))
  assert_true(solid.topo_is_connected())
}

///|
test "Topo trait topo_is_oriented BRep" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let brep = BRep::tetrahedron(v0, v1, v2, v3)
  assert_true(Topo::topo_is_oriented(brep))
  assert_true(brep.topo_is_oriented())
}

///|
test "Topo trait topo_is_connected BRep" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let brep = BRep::tetrahedron(v0, v1, v2, v3)
  assert_true(Topo::topo_is_connected(brep))
  assert_true(brep.topo_is_connected())
}

///|
test "FREEZE: Topo Trait interface stability" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let mesh = HEMesh::from_triangle(v0, v1, v2)
  let solid = Solid::tetrahedron(v0, v1, v2, v3)
  let brep = BRep::tetrahedron(v0, v1, v2, v3)
  // 调用全部 5 个 Topo Trait 方法（签名稳定性编译检查）
  let _ = Topo::topo_dim(mesh)
  let _ = Topo::topo_is_closed(mesh)
  let _ = Topo::topo_is_manifold(mesh)
  let _ = Topo::topo_is_oriented(mesh)
  let _ = Topo::topo_is_connected(mesh)
  let _ = Topo::topo_dim(solid)
  let _ = Topo::topo_is_closed(solid)
  let _ = Topo::topo_is_manifold(solid)
  let _ = Topo::topo_is_oriented(solid)
  let _ = Topo::topo_is_connected(solid)
  let _ = Topo::topo_dim(brep)
  let _ = Topo::topo_is_closed(brep)
  let _ = Topo::topo_is_manifold(brep)
  let _ = Topo::topo_is_oriented(brep)
  let _ = Topo::topo_is_connected(brep)
  // pub extend 点语法稳定性
  let _ = mesh.topo_dim()
  let _ = mesh.topo_is_closed()
  let _ = mesh.topo_is_manifold()
  let _ = mesh.topo_is_oriented()
  let _ = mesh.topo_is_connected()
  let _ = solid.topo_dim()
  let _ = solid.topo_is_closed()
  let _ = solid.topo_is_manifold()
  let _ = solid.topo_is_oriented()
  let _ = solid.topo_is_connected()
  let _ = brep.topo_dim()
  let _ = brep.topo_is_closed()
  let _ = brep.topo_is_manifold()
  let _ = brep.topo_is_oriented()
  let _ = brep.topo_is_connected()
}

///|
test "FREEZE: Geo Trait interface stability" {
  let p2 = @alg.Pt2::new(1.0, 2.0)
  let p3 = @alg.Pt3::new(1.0, 2.0, 3.0)
  // pub extend 点语法稳定性（跨包可见）
  let _ = p2.geo_dim()
  let _ = p2.is_degenerate()
  let _ = p3.geo_dim()
  let _ = p3.is_degenerate()
}

///|
test "Solid tetrahedron face normals point outward" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let v3 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let mesh = Solid::tetrahedron(v0, v1, v2, v3).mesh()
  let cx = 0.25
  let cy = 0.25
  let cz = 0.25
  for fi in 0..<mesh.face_count() {
    let hes = mesh.face_half_edges(fi)
    let p0 = mesh.vertex(mesh.half_edge(hes[0]).origin()).pos()
    let p1 = mesh.vertex(mesh.half_edge(hes[1]).origin()).pos()
    let p2 = mesh.vertex(mesh.half_edge(hes[2]).origin()).pos()
    let e1x = p1.x() - p0.x()
    let e1y = p1.y() - p0.y()
    let e1z = p1.z() - p0.z()
    let e2x = p2.x() - p0.x()
    let e2y = p2.y() - p0.y()
    let e2z = p2.z() - p0.z()
    let nx = e1y * e2z - e1z * e2y
    let ny = e1z * e2x - e1x * e2z
    let nz = e1x * e2y - e1y * e2x
    let fcx = (p0.x() + p1.x() + p2.x()) / 3.0
    let fcy = (p0.y() + p1.y() + p2.y()) / 3.0
    let fcz = (p0.z() + p1.z() + p2.z()) / 3.0
    let ox = fcx - cx
    let oy = fcy - cy
    let oz = fcz - cz
    let dot = nx * ox + ny * oy + nz * oz
    assert_true(dot > 0.0)
  }
}

///|
test "Solid tetrahedron face normals point outward (offset tetrahedron)" {
  let v0 = @alg.Pt3::new(5.0, 5.0, 5.0)
  let v1 = @alg.Pt3::new(6.0, 5.0, 5.0)
  let v2 = @alg.Pt3::new(5.0, 6.0, 5.0)
  let v3 = @alg.Pt3::new(5.0, 5.0, 6.0)
  let mesh = Solid::tetrahedron(v0, v1, v2, v3).mesh()
  let cx = 5.25
  let cy = 5.25
  let cz = 5.25
  for fi in 0..<mesh.face_count() {
    let hes = mesh.face_half_edges(fi)
    let p0 = mesh.vertex(mesh.half_edge(hes[0]).origin()).pos()
    let p1 = mesh.vertex(mesh.half_edge(hes[1]).origin()).pos()
    let p2 = mesh.vertex(mesh.half_edge(hes[2]).origin()).pos()
    let e1x = p1.x() - p0.x()
    let e1y = p1.y() - p0.y()
    let e1z = p1.z() - p0.z()
    let e2x = p2.x() - p0.x()
    let e2y = p2.y() - p0.y()
    let e2z = p2.z() - p0.z()
    let nx = e1y * e2z - e1z * e2y
    let ny = e1z * e2x - e1x * e2z
    let nz = e1x * e2y - e1y * e2x
    let fcx = (p0.x() + p1.x() + p2.x()) / 3.0
    let fcy = (p0.y() + p1.y() + p2.y()) / 3.0
    let fcz = (p0.z() + p1.z() + p2.z()) / 3.0
    let ox = fcx - cx
    let oy = fcy - cy
    let oz = fcz - cz
    let dot = nx * ox + ny * oy + nz * oz
    assert_true(dot > 0.0)
  }
}

///|
test "HEMesh::from_triangles 单三角形" {
  let pts : Array[@alg.Pt3] = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(0.0, 1.0, 0.0),
  ]
  let tris : Array[(Int32, Int32, Int32)] = [(0, 1, 2)]
  let mesh = HEMesh::from_triangles(pts, tris)
  assert_eq(mesh.vertex_count(), 3)
  assert_eq(mesh.face_count(), 1)
  assert_eq(mesh.half_edge_count(), 6)
}

///|
test "HEMesh::from_triangles 两三角形共享边" {
  let pts : Array[@alg.Pt3] = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(0.0, 1.0, 0.0),
    @alg.Pt3::new(1.0, 1.0, 0.0),
  ]
  let tris : Array[(Int32, Int32, Int32)] = [(0, 1, 2), (1, 3, 2)]
  let mesh = HEMesh::from_triangles(pts, tris)
  assert_eq(mesh.vertex_count(), 4)
  assert_eq(mesh.face_count(), 2)
  assert_eq(mesh.half_edge_count(), 10)
}

///|
test "HEMesh::from_triangles 三角形条带" {
  let pts : Array[@alg.Pt3] = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(2.0, 0.0, 0.0),
    @alg.Pt3::new(0.5, 1.0, 0.0),
    @alg.Pt3::new(1.5, 1.0, 0.0),
  ]
  let tris : Array[(Int32, Int32, Int32)] = [(0, 1, 3), (1, 4, 3), (1, 2, 4)]
  let mesh = HEMesh::from_triangles(pts, tris)
  assert_eq(mesh.vertex_count(), 5)
  assert_eq(mesh.face_count(), 3)
  assert_eq(mesh.half_edge_count(), 14)
}

///|
test "HEMesh::from_triangles twin 对称性" {
  let pts : Array[@alg.Pt3] = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(0.0, 1.0, 0.0),
    @alg.Pt3::new(1.0, 1.0, 0.0),
  ]
  let tris : Array[(Int32, Int32, Int32)] = [(0, 1, 2), (1, 3, 2)]
  let mesh = HEMesh::from_triangles(pts, tris)
  let n = mesh.half_edge_count()
  for i in 0..<n {
    let he = mesh.half_edge(i)
    let twin = he.twin()
    assert_true(twin >= 0 && twin < n)
    let twin_he = mesh.half_edge(twin)
    assert_eq(twin_he.twin(), i)
  }
}

///|
fn safe_from_triangles(
  pts : Array[@alg.Pt3],
  tris : Array[(Int32, Int32, Int32)],
) -> HEMesh? {
  Some(HEMesh::from_triangles(pts, tris)) catch {
    _ => None
  }
}

///|
test "from_triangles 负向：越界顶点索引" {
  let pts : Array[@alg.Pt3] = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(0.0, 1.0, 0.0),
  ]
  let tris : Array[(Int32, Int32, Int32)] = [(0, 1, 5)]
  match safe_from_triangles(pts, tris) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "from_triangles 负向：负顶点索引" {
  let pts : Array[@alg.Pt3] = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(0.0, 1.0, 0.0),
  ]
  let tris : Array[(Int32, Int32, Int32)] = [(-1, 1, 2)]
  match safe_from_triangles(pts, tris) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "from_triangles 负向：非流形输入（3三角形共享边）" {
  let pts : Array[@alg.Pt3] = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(0.5, 1.0, 0.0),
    @alg.Pt3::new(0.5, -1.0, 0.0),
  ]
  // 3 个三角形共享边 0→1
  let tris : Array[(Int32, Int32, Int32)] = [(0, 1, 2), (1, 0, 3), (0, 1, 3)]
  match safe_from_triangles(pts, tris) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "from_triangles 负向：空输入" {
  let pts : Array[@alg.Pt3] = []
  let tris : Array[(Int32, Int32, Int32)] = []
  match safe_from_triangles(pts, tris) {
    Some(mesh) => {
      assert_eq(mesh.vertex_count(), 0)
      assert_eq(mesh.face_count(), 0)
    }
    None => assert_true(false)
  }
}

///|
test "from_triangles 负向：重复三角形产出独立网格" {
  let pts : Array[@alg.Pt3] = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(0.0, 1.0, 0.0),
  ]
  // 同一三角形重复两次 — 无反向半边，两三角形独立
  let tris : Array[(Int32, Int32, Int32)] = [(0, 1, 2), (0, 1, 2)]
  match safe_from_triangles(pts, tris) {
    Some(mesh) => {
      assert_eq(mesh.face_count(), 2)
      // 6 面内 + 6 边界 = 12 半边
      assert_eq(mesh.half_edge_count(), 12)
    }
    None => assert_true(false)
  }
}
