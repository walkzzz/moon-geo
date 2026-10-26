// STL 读写测试
// 顶点/法向用 @alg.Pt3，通过 x()/y()/z() 访问

///|
fn safe_stl_read(stl : String) -> @mesh.IndexedMesh? {
  try {
    let m = mesh_from_stl_ascii(stl)
    Some(m)
  } catch {
    _ => None
  }
}

///|
test "STL 写基本网格" {
  let m = @mesh.IndexedMesh::new()
  let (m1, i0) = m.add_vertex(0.0, 0.0, 0.0)
  let (m2, i1) = m1.add_vertex(1.0, 0.0, 0.0)
  let (m3, i2) = m2.add_vertex(0.0, 1.0, 0.0)
  let m4 = m3.add_triangle(i0, i1, i2)
  let stl = mesh_to_stl_ascii(m4, "test")
  assert_true(stl.contains("solid test"))
  assert_true(stl.contains("endsolid test"))
  assert_true(stl.contains("facet normal"))
  assert_true(stl.contains("outer loop"))
  assert_true(stl.contains("vertex"))
  assert_true(stl.contains("endloop"))
  assert_true(stl.contains("endfacet"))
}

///|
test "STL 写顶点坐标" {
  let m = @mesh.IndexedMesh::new()
  let (m1, i0) = m.add_vertex(1.0, 2.0, 3.0)
  let (m2, i1) = m1.add_vertex(4.0, 5.0, 6.0)
  let (m3, i2) = m2.add_vertex(7.0, 8.0, 9.0)
  let m4 = m3.add_triangle(i0, i1, i2)
  let stl = mesh_to_stl_ascii(m4, "test")
  assert_true(stl.contains("1"))
  assert_true(stl.contains("2"))
  assert_true(stl.contains("3"))
}

///|
test "STL 写多面片" {
  let m = @mesh.IndexedMesh::new()
  let (m1, i0) = m.add_vertex(0.0, 0.0, 0.0)
  let (m2, i1) = m1.add_vertex(1.0, 0.0, 0.0)
  let (m3, i2) = m2.add_vertex(0.0, 1.0, 0.0)
  let (m4, i3) = m3.add_vertex(0.0, 0.0, 1.0)
  let m5 = m4.add_triangle(i0, i1, i2).add_triangle(i0, i1, i3)
  let stl = mesh_to_stl_ascii(m5, "test")
  let facet_count = count_substring(stl, "facet normal")
  assert_eq(facet_count, 2)
}

///|
test "STL 读基本网格" {
  let stl = "solid test\n  facet normal 0 0 1\n    outer loop\n      vertex 0 0 0\n      vertex 1 0 0\n      vertex 0 1 0\n    endloop\n  endfacet\nendsolid test\n"
  match safe_stl_read(stl) {
    Some(m) => {
      assert_eq(m.triangle_count(), 1)
      assert_eq(m.vertex_count(), 3)
    }
    None => assert_true(false)
  }
}

///|
test "STL 读顶点坐标" {
  let stl = "solid test\n  facet normal 0 0 1\n    outer loop\n      vertex 1 2 3\n      vertex 4 5 6\n      vertex 7 8 9\n    endloop\n  endfacet\nendsolid test\n"
  match safe_stl_read(stl) {
    Some(m) =>
      match m.get_vertex(0) {
        Some(v) => {
          assert_true(approx(v.x(), 1.0, 0.001))
          assert_true(approx(v.y(), 2.0, 0.001))
          assert_true(approx(v.z(), 3.0, 0.001))
        }
        None => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "STL 读多面片" {
  let stl = "solid test\n  facet normal 0 0 1\n    outer loop\n      vertex 0 0 0\n      vertex 1 0 0\n      vertex 0 1 0\n    endloop\n  endfacet\n  facet normal 0 1 0\n    outer loop\n      vertex 0 0 0\n      vertex 1 0 0\n      vertex 0 0 1\n    endloop\n  endfacet\nendsolid test\n"
  match safe_stl_read(stl) {
    Some(m) => assert_eq(m.triangle_count(), 2)
    None => assert_true(false)
  }
}

///|
test "STL 读法向量" {
  let stl = "solid test\n  facet normal 0 0 1\n    outer loop\n      vertex 0 0 0\n      vertex 1 0 0\n      vertex 0 1 0\n    endloop\n  endfacet\nendsolid test\n"
  match safe_stl_read(stl) {
    Some(m) => {
      assert_eq(m.normal_count(), 1)
      match m.get_normal(0) {
        Some(n) => assert_true(approx(n.z(), 1.0, 0.001))
        None => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "STL 往返测试" {
  let m = @mesh.IndexedMesh::new()
  let (m1, i0) = m.add_vertex(0.0, 0.0, 0.0)
  let (m2, i1) = m1.add_vertex(1.0, 0.0, 0.0)
  let (m3, i2) = m2.add_vertex(0.0, 1.0, 0.0)
  let m4 = m3.add_triangle(i0, i1, i2).add_normal(0.0, 0.0, 1.0)
  let stl = mesh_to_stl_ascii(m4, "test")
  match safe_stl_read(stl) {
    Some(m5) => {
      assert_eq(m5.triangle_count(), 1)
      assert_eq(m5.vertex_count(), 3)
      match m5.get_vertex(0) {
        Some(v) => assert_true(approx(v.x(), 0.0, 0.001))
        None => assert_true(false)
      }
      match m5.get_vertex(1) {
        Some(v) => assert_true(approx(v.x(), 1.0, 0.001))
        None => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "STL 读大写关键字" {
  let stl = "SOLID test\n  FACET NORMAL 0 0 1\n    OUTER LOOP\n      VERTEX 0 0 0\n      VERTEX 1 0 0\n      VERTEX 0 1 0\n    ENDLOOP\n  ENDFACET\nENDSOLID test\n"
  match safe_stl_read(stl) {
    Some(m) => assert_eq(m.triangle_count(), 1)
    None => assert_true(false)
  }
}

///|
test "STL 读空网格报错" {
  let stl = "solid empty\nendsolid empty\n"
  match safe_stl_read(stl) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "STL 写带法向量" {
  let m = @mesh.IndexedMesh::new()
  let (m1, i0) = m.add_vertex(0.0, 0.0, 0.0)
  let (m2, i1) = m1.add_vertex(1.0, 0.0, 0.0)
  let (m3, i2) = m2.add_vertex(0.0, 1.0, 0.0)
  let m4 = m3.add_triangle(i0, i1, i2).add_normal(0.0, 0.0, 1.0)
  let stl = mesh_to_stl_ascii(m4, "test")
  assert_true(stl.contains("facet normal"))
}

///|
test "STL 写空网格" {
  let m = @mesh.IndexedMesh::new()
  let stl = mesh_to_stl_ascii(m, "empty")
  assert_true(stl.contains("solid empty"))
  assert_true(stl.contains("endsolid empty"))
}

///|
test "STL 浮点坐标" {
  let stl = "solid test\n  facet normal 0 0 1\n    outer loop\n      vertex 1.5 2.5 3.5\n      vertex 4.5 5.5 6.5\n      vertex 7.5 8.5 9.5\n    endloop\n  endfacet\nendsolid test\n"
  match safe_stl_read(stl) {
    Some(m) =>
      match m.get_vertex(0) {
        Some(v) => assert_true(approx(v.x(), 1.5, 0.001))
        None => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "STL 负坐标" {
  let stl = "solid test\n  facet normal 0 0 1\n    outer loop\n      vertex -1 -2 -3\n      vertex 1 0 0\n      vertex 0 1 0\n    endloop\n  endfacet\nendsolid test\n"
  match safe_stl_read(stl) {
    Some(m) =>
      match m.get_vertex(0) {
        Some(v) => {
          assert_true(approx(v.x(), -1.0, 0.001))
          assert_true(approx(v.y(), -2.0, 0.001))
          assert_true(approx(v.z(), -3.0, 0.001))
        }
        None => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "STL 往返多面片" {
  let m = @mesh.IndexedMesh::new()
  let (m1, i0) = m.add_vertex(0.0, 0.0, 0.0)
  let (m2, i1) = m1.add_vertex(1.0, 0.0, 0.0)
  let (m3, i2) = m2.add_vertex(0.0, 1.0, 0.0)
  let (m4, i3) = m3.add_vertex(0.0, 0.0, 1.0)
  let m5 = m4.add_triangle(i0, i1, i2).add_triangle(i0, i1, i3)
  let stl = mesh_to_stl_ascii(m5, "test")
  match safe_stl_read(stl) {
    Some(m6) => assert_eq(m6.triangle_count(), 2)
    None => assert_true(false)
  }
}

///|
/// 计算子串出现次数
fn count_substring(s : String, sub : String) -> Int32 {
  let mut count = 0
  let mut i = 0
  let n = s.length()
  let sub_len = sub.length()
  while i <= n - sub_len {
    if s.substring(start=i, end=i + sub_len) == sub {
      count += 1
      i += sub_len
    } else {
      i += 1
    }
  }
  count
}
