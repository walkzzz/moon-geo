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
