// brep 白盒测试：Topo Trait + Vtx/HEdge/Face/HEMesh + 邻接关系
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
