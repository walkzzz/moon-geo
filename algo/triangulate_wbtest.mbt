// 三角剖分 + 缓冲区 + 拓扑修复 测试

///|
test "delaunay triangle" {
  let points = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(5.0, 10.0),
  ]
  let tris = delaunay(points)
  assert_eq(tris.length(), 1)
  let area = triangulation_total_area(points, tris)
  assert_true(@util.dbl_approx_eq(area, 50.0, 1.0e-8))
}

///|
test "delaunay square" {
  let points = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
    @alg.Pt2::new(0.0, 10.0),
  ]
  let tris = delaunay(points)
  assert_eq(tris.length(), 2)
  let area = triangulation_total_area(points, tris)
  assert_true(@util.dbl_approx_eq(area, 100.0, 1.0e-8))
}

///|
test "delaunay square with center" {
  let points = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
    @alg.Pt2::new(0.0, 10.0),
    @alg.Pt2::new(5.0, 5.0),
  ]
  let tris = delaunay(points)
  assert_eq(tris.length(), 4)
  let area = triangulation_total_area(points, tris)
  assert_true(@util.dbl_approx_eq(area, 100.0, 1.0e-8))
}

///|
test "delaunay collinear" {
  let points = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(5.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
  ]
  let tris = delaunay(points)
  assert_eq(tris.length(), 0)
}

///|
test "delaunay five points" {
  let points = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
    @alg.Pt2::new(0.0, 10.0),
    @alg.Pt2::new(3.0, 3.0),
  ]
  let tris = delaunay(points)
  assert_true(tris.length() >= 3)
  let area = triangulation_total_area(points, tris)
  assert_true(@util.dbl_approx_eq(area, 100.0, 1.0e-6))
}

///|
test "delaunay six points grid" {
  let points = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(5.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(0.0, 5.0),
    @alg.Pt2::new(5.0, 5.0),
    @alg.Pt2::new(10.0, 5.0),
  ]
  let tris = delaunay(points)
  assert_true(tris.length() >= 4)
  let area = triangulation_total_area(points, tris)
  assert_true(@util.dbl_approx_eq(area, 50.0, 1.0e-6))
}

///|
test "delaunay cocircular four points" {
  // 四个共圆点（正方形顶点），Bowyer-Watson 经典退化场景
  let points = [
    @alg.Pt2::new(1.0, 0.0),
    @alg.Pt2::new(0.0, 1.0),
    @alg.Pt2::new(-1.0, 0.0),
    @alg.Pt2::new(0.0, -1.0),
  ]
  let tris = delaunay(points)
  assert_true(tris.length() >= 2)
  let area = triangulation_total_area(points, tris)
  assert_true(@util.dbl_approx_eq(area, 2.0, 1.0e-6))
}

///|
test "buffer point circle" {
  let buf = buffer_point(@alg.Pt2::new(0.0, 0.0), 10.0, 64)
  assert_eq(buf.length(), 64)
  let area = polygon_area(buf)
  let expected = @math.PI * 100.0
  assert_true(@util.dbl_approx_eq(area, expected, 1.0))
}

///|
test "buffer point small segments" {
  let buf = buffer_point(@alg.Pt2::new(0.0, 0.0), 5.0, 2)
  assert_eq(buf.length(), 16)
}

///|
test "buffer point offset" {
  let buf = buffer_point(@alg.Pt2::new(100.0, 200.0), 10.0, 32)
  let c = polygon_centroid(buf)
  assert_true(@util.dbl_approx_eq(c.x(), 100.0, 0.01))
  assert_true(@util.dbl_approx_eq(c.y(), 200.0, 0.01))
}

///|
test "buffer line segment horizontal" {
  let buf = buffer_line_segment(
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    2.0,
  )
  assert_true(buf.length() > 10)
  let area = polygon_area(buf)
  let expected = 10.0 * 4.0 + @math.PI * 4.0
  assert_true(@util.dbl_approx_eq(area, expected, 3.0))
}

///|
test "buffer line segment vertical" {
  let buf = buffer_line_segment(
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(0.0, 10.0),
    2.0,
  )
  assert_true(buf.length() > 10)
  let area = polygon_area(buf)
  let expected = 10.0 * 4.0 + @math.PI * 4.0
  assert_true(@util.dbl_approx_eq(area, expected, 3.0))
}

///|
test "buffer line segment zero length" {
  let buf = buffer_line_segment(
    @alg.Pt2::new(5.0, 5.0),
    @alg.Pt2::new(5.0, 5.0),
    3.0,
  )
  assert_eq(buf.length(), 32)
  let area = polygon_area(buf)
  let expected = @math.PI * 9.0
  assert_true(@util.dbl_approx_eq(area, expected, 0.5))
}

///|
test "buffer polyline" {
  let coords = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
  ]
  let bufs = buffer_polyline(coords, 2.0)
  assert_eq(bufs.length(), 2)
}

///|
test "merge duplicate vertices" {
  let coords = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
  ]
  let (unique, mapping) = merge_duplicate_vertices(coords, 0.001)
  assert_eq(unique.length(), 3)
  assert_eq(mapping.length(), 4)
  assert_eq(mapping[1], mapping[2])
}

///|
test "merge no duplicates" {
  let coords = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
  ]
  let (unique, mapping) = merge_duplicate_vertices(coords, 0.001)
  assert_eq(unique.length(), 3)
  assert_eq(mapping[0], 0)
  assert_eq(mapping[1], 1)
  assert_eq(mapping[2], 2)
}

///|
test "has duplicate vertices" {
  let coords = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(0.0, 0.0),
  ]
  assert_true(has_duplicate_vertices(coords, 0.001))
  let clean = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
  ]
  assert_false(has_duplicate_vertices(clean, 0.001))
}

///|
test "remove duplicate vertices" {
  let coords = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
  ]
  let result = remove_duplicate_vertices(coords, 0.001)
  assert_eq(result.length(), 3)
}

///|
test "fix orientation" {
  let cw = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(0.0, 10.0),
    @alg.Pt2::new(10.0, 10.0),
    @alg.Pt2::new(10.0, 0.0),
  ]
  let fixed = fix_orientation(cw)
  assert_true(is_counterclockwise(fixed))
}

///|
test "polyline length" {
  let coords = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(3.0, 0.0),
    @alg.Pt2::new(3.0, 4.0),
  ]
  let len = polyline_length(coords)
  assert_true(@util.dbl_approx_eq(len, 7.0, 1.0e-10))
}

///|
test "polygon perimeter" {
  let coords = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
    @alg.Pt2::new(0.0, 10.0),
  ]
  let peri = polygon_perimeter(coords)
  assert_true(@util.dbl_approx_eq(peri, 40.0, 1.0e-10))
}

///|
test "polygon perimeter triangle" {
  let coords = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(6.0, 0.0),
    @alg.Pt2::new(0.0, 8.0),
  ]
  let peri = polygon_perimeter(coords)
  assert_true(@util.dbl_approx_eq(peri, 24.0, 1.0e-10))
}

///|
test "triangulation total area" {
  let points = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
    @alg.Pt2::new(0.0, 10.0),
  ]
  let tris = [(0, 1, 2), (0, 2, 3)]
  let area = triangulation_total_area(points, tris)
  assert_true(@util.dbl_approx_eq(area, 100.0, 1.0e-10))
}

///|
test "delaunay random points" {
  let points = [
    @alg.Pt2::new(1.0, 2.0),
    @alg.Pt2::new(5.0, 1.0),
    @alg.Pt2::new(8.0, 4.0),
    @alg.Pt2::new(3.0, 7.0),
    @alg.Pt2::new(7.0, 8.0),
    @alg.Pt2::new(2.0, 5.0),
  ]
  let tris = delaunay(points)
  assert_true(tris.length() >= 4)
  for tri in tris {
    let (a, b, c) = tri
    assert_true(a >= 0 && a < 6)
    assert_true(b >= 0 && b < 6)
    assert_true(c >= 0 && c < 6)
    assert_true(a != b && b != c && a != c)
  }
}

///|
test "delaunay_to_hemesh 基本三角剖分" {
  let pts : Array[@alg.Pt2] = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(1.0, 0.0),
    @alg.Pt2::new(0.0, 1.0),
    @alg.Pt2::new(1.0, 1.0),
  ]
  let mesh = delaunay_to_hemesh(pts)
  assert_eq(mesh.vertex_count(), 4)
  assert_true(mesh.face_count() >= 2)
  for fi in 0..<mesh.face_count() {
    let hes = mesh.face_half_edges(fi)
    assert_eq(hes.length(), 3)
  }
}

///|
test "delaunay_to_hemesh twin 对称性" {
  let pts : Array[@alg.Pt2] = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(2.0, 0.0),
    @alg.Pt2::new(1.0, 2.0),
    @alg.Pt2::new(3.0, 2.0),
  ]
  let mesh = delaunay_to_hemesh(pts)
  let n = mesh.half_edge_count()
  for i in 0..<n {
    let he = mesh.half_edge(i)
    let twin = he.twin()
    assert_true(twin >= 0 && twin < n)
    assert_eq(mesh.half_edge(twin).twin(), i)
  }
}

///|
test "delaunay_to_hemesh 顶点坐标保持" {
  let pts : Array[@alg.Pt2] = [
    @alg.Pt2::new(1.5, 2.5),
    @alg.Pt2::new(4.0, 5.0),
    @alg.Pt2::new(7.0, 8.0),
  ]
  let mesh = delaunay_to_hemesh(pts)
  assert_eq(mesh.vertex_count(), 3)
  let v0 = mesh.vertex(0).pos()
  assert_true((v0.x() - 1.5).abs() < 1.0e-10)
  assert_true((v0.y() - 2.5).abs() < 1.0e-10)
  assert_true(v0.z().abs() < 1.0e-10)
}
