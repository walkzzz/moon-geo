// 布尔运算白盒测试

///|
test "polygon_area triangle" {
  let tri = [(0.0, 0.0), (10.0, 0.0), (0.0, 10.0)]
  assert_true(@util.dbl_approx_eq(polygon_area(tri), 50.0, 1.0e-10))
}

///|
test "polygon_area square" {
  let sq = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  assert_true(@util.dbl_approx_eq(polygon_area(sq), 100.0, 1.0e-10))
}

///|
test "polygon_area degenerate" {
  let line = [(0.0, 0.0), (10.0, 10.0)]
  assert_true(@util.dbl_approx_eq(polygon_area(line), 0.0, 1.0e-10))
}

///|
test "polygon_signed_area ccw" {
  let ccw = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  assert_true(polygon_signed_area(ccw) > 0.0)
}

///|
test "polygon_signed_area cw" {
  let cw = [(0.0, 0.0), (0.0, 10.0), (10.0, 10.0), (10.0, 0.0)]
  assert_true(polygon_signed_area(cw) < 0.0)
}

///|
test "polygon_centroid square" {
  let sq = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  let (cx, cy) = polygon_centroid(sq)
  assert_true(@util.dbl_approx_eq(cx, 5.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(cy, 5.0, 1.0e-10))
}

///|
test "polygon_centroid triangle" {
  let tri = [(0.0, 0.0), (6.0, 0.0), (0.0, 6.0)]
  let (cx, cy) = polygon_centroid(tri)
  assert_true(@util.dbl_approx_eq(cx, 2.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(cy, 2.0, 1.0e-10))
}

///|
test "rect basic" {
  let r = Rect::new(0.0, 0.0, 10.0, 20.0)
  assert_true(@util.dbl_approx_eq(r.area(), 200.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(r.width(), 10.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(r.height(), 20.0, 1.0e-10))
  let (cx, cy) = r.center()
  assert_true(@util.dbl_approx_eq(cx, 5.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(cy, 10.0, 1.0e-10))
}

///|
test "rect intersect overlapping" {
  let a = Rect::new(0.0, 0.0, 10.0, 10.0)
  let b = Rect::new(5.0, 5.0, 15.0, 15.0)
  match a.intersect(b) {
    Some(r) => assert_true(@util.dbl_approx_eq(r.area(), 25.0, 1.0e-10))
    None => assert_true(false)
  }
}

///|
test "rect intersect disjoint" {
  let a = Rect::new(0.0, 0.0, 10.0, 10.0)
  let b = Rect::new(20.0, 20.0, 30.0, 30.0)
  assert_true(a.intersect(b) is None)
}

///|
test "rect intersect touching" {
  let a = Rect::new(0.0, 0.0, 10.0, 10.0)
  let b = Rect::new(10.0, 0.0, 20.0, 10.0)
  assert_true(a.intersect(b) is None)
}

///|
test "rect intersect contained" {
  let a = Rect::new(0.0, 0.0, 10.0, 10.0)
  let b = Rect::new(2.0, 2.0, 8.0, 8.0)
  match a.intersect(b) {
    Some(r) => assert_true(@util.dbl_approx_eq(r.area(), 36.0, 1.0e-10))
    None => assert_true(false)
  }
}

///|
test "rect union" {
  let a = Rect::new(0.0, 0.0, 10.0, 10.0)
  let b = Rect::new(5.0, 5.0, 15.0, 15.0)
  let r = a.union(b)
  assert_true(@util.dbl_approx_eq(r.min_x, 0.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(r.min_y, 0.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(r.max_x, 15.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(r.max_y, 15.0, 1.0e-10))
}

///|
test "rect intersects" {
  let a = Rect::new(0.0, 0.0, 10.0, 10.0)
  let b = Rect::new(5.0, 5.0, 15.0, 15.0)
  let c = Rect::new(20.0, 20.0, 30.0, 30.0)
  assert_true(a.intersects(b))
  assert_false(a.intersects(c))
}

///|
test "rect contains" {
  let r = Rect::new(0.0, 0.0, 10.0, 10.0)
  assert_true(r.contains(5.0, 5.0))
  assert_true(r.contains(0.0, 0.0))
  assert_true(r.contains(10.0, 10.0))
  assert_false(r.contains(15.0, 15.0))
}

///|
test "rect to_polygon" {
  let r = Rect::new(0.0, 0.0, 10.0, 10.0)
  let poly = r.to_polygon()
  assert_eq(poly.length(), 4)
  assert_true(@util.dbl_approx_eq(polygon_area(poly), 100.0, 1.0e-10))
}

///|
test "clip polygon contained" {
  let big = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  let small = [(2.0, 2.0), (8.0, 2.0), (8.0, 8.0), (2.0, 8.0)]
  let result = clip_polygon(big, small)
  assert_eq(result.length(), 4)
  assert_true(@util.dbl_approx_eq(polygon_area(result), 36.0, 1.0e-8))
}

///|
test "clip polygon partial" {
  let subject = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  let clip = [(5.0, 5.0), (15.0, 5.0), (15.0, 15.0), (5.0, 15.0)]
  let result = clip_polygon(subject, clip)
  assert_eq(result.length(), 4)
  assert_true(@util.dbl_approx_eq(polygon_area(result), 25.0, 1.0e-8))
}

///|
test "clip polygon disjoint" {
  let subject = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  let clip = [(20.0, 20.0), (30.0, 20.0), (30.0, 30.0), (20.0, 30.0)]
  let result = clip_polygon(subject, clip)
  assert_eq(result.length(), 0)
}

///|
test "intersect convex squares" {
  let a = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  let b = [(5.0, 5.0), (15.0, 5.0), (15.0, 15.0), (5.0, 15.0)]
  let result = intersect_convex(a, b)
  assert_eq(result.length(), 4)
  assert_true(@util.dbl_approx_eq(polygon_area(result), 25.0, 1.0e-8))
}

///|
test "intersect convex contained" {
  let big = [(0.0, 0.0), (20.0, 0.0), (20.0, 20.0), (0.0, 20.0)]
  let small = [(5.0, 5.0), (10.0, 5.0), (10.0, 10.0), (5.0, 10.0)]
  let result = intersect_convex(big, small)
  assert_true(@util.dbl_approx_eq(polygon_area(result), 25.0, 1.0e-8))
}

///|
test "is counterclockwise" {
  let ccw = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  assert_true(is_counterclockwise(ccw))
  let cw = [(0.0, 0.0), (0.0, 10.0), (10.0, 10.0), (10.0, 0.0)]
  assert_false(is_counterclockwise(cw))
}

///|
test "ensure counterclockwise" {
  let cw = [(0.0, 0.0), (0.0, 10.0), (10.0, 10.0), (10.0, 0.0)]
  let result = ensure_counterclockwise(cw)
  assert_true(is_counterclockwise(result))
  let ccw = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  let result2 = ensure_counterclockwise(ccw)
  assert_true(is_counterclockwise(result2))
}

///|
test "clip polygon triangle" {
  let subject = [(0.0, 0.0), (10.0, 0.0), (5.0, 10.0)]
  let clip = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  let result = clip_polygon(subject, clip)
  assert_true(@util.dbl_approx_eq(polygon_area(result), 50.0, 1.0e-8))
}

///|
test "polygon area hexagon" {
  let hex = [
    (0.0, 1.0),
    (0.866, 0.5),
    (0.866, -0.5),
    (0.0, -1.0),
    (-0.866, -0.5),
    (-0.866, 0.5),
  ]
  let area = polygon_area(hex)
  assert_true(@util.dbl_approx_eq(area, 2.598, 0.001))
}
