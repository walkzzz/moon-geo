// platform/mesh 白盒测试
// 顶点/法向用 @alg.Pt3，通过 x()/y()/z() 访问

///|
fn approx(a : Double, b : Double, tol : Double) -> Bool {
  (a - b).abs() < tol
}

///|
test "IndexedMesh::new 空网格" {
  let m = IndexedMesh::new()
  assert_eq(m.vertex_count(), 0)
  assert_eq(m.triangle_count(), 0)
  assert_eq(m.normal_count(), 0)
}

///|
test "IndexedMesh::add_vertex" {
  let m = IndexedMesh::new()
  let (m2, idx) = m.add_vertex(1.0, 2.0, 3.0)
  assert_eq(m2.vertex_count(), 1)
  assert_eq(idx, 0)
  match m2.get_vertex(0) {
    Some(v) => {
      assert_true(approx(v.x(), 1.0, 0.000001))
      assert_true(approx(v.y(), 2.0, 0.000001))
      assert_true(approx(v.z(), 3.0, 0.000001))
    }
    None => assert_true(false)
  }
}

///|
test "IndexedMesh::add_triangle" {
  let m = IndexedMesh::new()
  let (m1, i0) = m.add_vertex(0.0, 0.0, 0.0)
  let (m2, i1) = m1.add_vertex(1.0, 0.0, 0.0)
  let (m3, i2) = m2.add_vertex(0.0, 1.0, 0.0)
  let m4 = m3.add_triangle(i0, i1, i2)
  assert_eq(m4.triangle_count(), 1)
  match m4.get_triangle(0) {
    Some(t) => {
      assert_eq(t.v0, 0)
      assert_eq(t.v1, 1)
      assert_eq(t.v2, 2)
    }
    None => assert_true(false)
  }
}

///|
test "IndexedMesh::add_normal" {
  let m = IndexedMesh::new().add_normal(0.0, 0.0, 1.0)
  assert_eq(m.normal_count(), 1)
  match m.get_normal(0) {
    Some(n) => assert_true(approx(n.z(), 1.0, 0.000001))
    None => assert_true(false)
  }
}

///|
test "IndexedMesh 不可变性" {
  let m = IndexedMesh::new()
  let (m2, _) = m.add_vertex(1.0, 2.0, 3.0)
  assert_eq(m.vertex_count(), 0)
  assert_eq(m2.vertex_count(), 1)
}

///|
test "compute_normal XY平面" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 0.0)
  let n = compute_normal(v0, v1, v2)
  assert_true(approx(n.x(), 0.0, 0.001))
  assert_true(approx(n.y(), 0.0, 0.001))
  assert_true(approx(n.z(), 1.0, 0.001))
}

///|
test "compute_normal XZ平面" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 0.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 0.0, 1.0)
  let n = compute_normal(v0, v1, v2)
  assert_true(approx(n.y(), -1.0, 0.001))
}

///|
test "compute_normal 单位长度" {
  let v0 = @alg.Pt3::new(0.0, 0.0, 0.0)
  let v1 = @alg.Pt3::new(1.0, 1.0, 0.0)
  let v2 = @alg.Pt3::new(0.0, 1.0, 1.0)
  let n = compute_normal(v0, v1, v2)
  let len = (n.x() * n.x() + n.y() * n.y() + n.z() * n.z()).sqrt()
  assert_true(approx(len, 1.0, 0.001))
}

///|
test "IndexedMesh::recompute_normals" {
  let m = IndexedMesh::new()
  let (m1, i0) = m.add_vertex(0.0, 0.0, 0.0)
  let (m2, i1) = m1.add_vertex(1.0, 0.0, 0.0)
  let (m3, i2) = m2.add_vertex(0.0, 1.0, 0.0)
  let m4 = m3.add_triangle(i0, i1, i2)
  let m5 = m4.recompute_normals()
  assert_eq(m5.normal_count(), 1)
  match m5.get_normal(0) {
    Some(n) => assert_true(approx(n.z(), 1.0, 0.001))
    None => assert_true(false)
  }
}

///|
test "IndexedMesh 多面片" {
  let m = IndexedMesh::new()
  let (m1, i0) = m.add_vertex(0.0, 0.0, 0.0)
  let (m2, i1) = m1.add_vertex(1.0, 0.0, 0.0)
  let (m3, i2) = m2.add_vertex(0.0, 1.0, 0.0)
  let (m4, i3) = m3.add_vertex(0.0, 0.0, 1.0)
  let m5 = m4.add_triangle(i0, i1, i2).add_triangle(i0, i1, i3)
  assert_eq(m5.vertex_count(), 4)
  assert_eq(m5.triangle_count(), 2)
}

///|
test "IndexedMesh 越界访问" {
  let m = IndexedMesh::new()
  assert_true(m.get_vertex(0) is None)
  assert_true(m.get_triangle(0) is None)
  assert_true(m.get_normal(0) is None)
}

///|
test "Triangle::new" {
  let t = Triangle::new(0, 1, 2)
  assert_eq(t.v0, 0)
  assert_eq(t.v1, 1)
  assert_eq(t.v2, 2)
}

///|
test "Pt3 顶点构造" {
  let v = @alg.Pt3::new(1.0, 2.0, 3.0)
  assert_true(approx(v.x(), 1.0, 0.000001))
  assert_true(approx(v.y(), 2.0, 0.000001))
  assert_true(approx(v.z(), 3.0, 0.000001))
}
