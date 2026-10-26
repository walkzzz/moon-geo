// alg 白盒测试：intersect 求交 + xform Transform 变换
// 含 FAKE 类型测试 + E2E 链路测试

///|
test "intersect_line_circle two points" {
  let line = Line2::new(1.0, 0.0, 0.0) // x = 0
  let circle = Circle::new(0.0, 0.0, 5.0) // x² + y² = 25
  let pts = intersect_line_circle(line, circle)
  assert_eq(pts.length(), 2)
  assert_true(@util.dbl_approx_eq(pts[0].x(), 0.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(pts[1].x(), 0.0, @util.EPS))
  assert_true(circle.contains(pts[0]))
  assert_true(circle.contains(pts[1]))
}

///|
test "intersect_line_circle offset center" {
  let line = Line2::new(1.0, 0.0, 0.0) // x = 0
  let circle = Circle::new(0.0, 3.0, 5.0) // center (0,3), r=5
  let pts = intersect_line_circle(line, circle)
  assert_eq(pts.length(), 2)
  let y0 = pts[0].y()
  let y1 = pts[1].y()
  let has_8 = @util.dbl_approx_eq(y0, 8.0, @util.EPS) ||
    @util.dbl_approx_eq(y1, 8.0, @util.EPS)
  let has_neg2 = @util.dbl_approx_eq(y0, -2.0, @util.EPS) ||
    @util.dbl_approx_eq(y1, -2.0, @util.EPS)
  assert_true(has_8)
  assert_true(has_neg2)
}

///|
test "intersect_line_circle one point (tangent)" {
  let line = Line2::new(1.0, 0.0, -5.0) // x = 5
  let circle = Circle::new(0.0, 0.0, 5.0)
  let pts = intersect_line_circle(line, circle)
  assert_eq(pts.length(), 1)
  assert_true(circle.contains(pts[0]))
}

///|
test "intersect_line_circle zero points" {
  let line = Line2::new(1.0, 0.0, -10.0) // x = 10
  let circle = Circle::new(0.0, 0.0, 5.0)
  let pts = intersect_line_circle(line, circle)
  assert_eq(pts.length(), 0)
}

///|
test "intersect_circle_circle two points" {
  let c1 = Circle::new(0.0, 0.0, 5.0)
  let c2 = Circle::new(6.0, 0.0, 5.0)
  let pts = intersect_circle_circle(c1, c2)
  assert_eq(pts.length(), 2)
  assert_true(c1.contains(pts[0]))
  assert_true(c2.contains(pts[0]))
  assert_true(c1.contains(pts[1]))
  assert_true(c2.contains(pts[1]))
}

///|
test "intersect_circle_circle one point" {
  let c1 = Circle::new(0.0, 0.0, 5.0)
  let c2 = Circle::new(10.0, 0.0, 5.0)
  let pts = intersect_circle_circle(c1, c2)
  assert_eq(pts.length(), 1)
}

///|
test "intersect_circle_circle zero points" {
  let c1 = Circle::new(0.0, 0.0, 1.0)
  let c2 = Circle::new(10.0, 0.0, 1.0)
  let pts = intersect_circle_circle(c1, c2)
  assert_eq(pts.length(), 0)
}

///|
test "Transform2 identity" {
  let t = Transform2::identity()
  let p = Pt2::new(3.0, 4.0)
  let r = t.apply(p)
  assert_true(@util.dbl_approx_eq(r.x(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.y(), 4.0, @util.EPS))
}

///|
test "Transform2 translation" {
  let t = Transform2::translation(5.0, 10.0)
  let p = Pt2::new(3.0, 4.0)
  let r = t.apply(p)
  assert_true(@util.dbl_approx_eq(r.x(), 8.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.y(), 14.0, @util.EPS))
}

///|
test "Transform2 scaling" {
  let t = Transform2::scaling(2.0, 3.0)
  let p = Pt2::new(5.0, 4.0)
  let r = t.apply(p)
  assert_true(@util.dbl_approx_eq(r.x(), 10.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.y(), 12.0, @util.EPS))
}

///|
test "Transform2 rotation 90 degrees" {
  let t = Transform2::rotation(1.5707963267948966)
  let p = Pt2::new(1.0, 0.0)
  let r = t.apply(p)
  assert_true(@util.dbl_approx_eq(r.x(), 0.0, 1.0e-6))
  assert_true(@util.dbl_approx_eq(r.y(), 1.0, 1.0e-6))
}

///|
test "Transform2 compose" {
  let t1 = Transform2::translation(5.0, 0.0)
  let t2 = Transform2::translation(0.0, 10.0)
  let composed = t1.compose(t2)
  let p = Pt2::new(0.0, 0.0)
  let r = composed.apply(p)
  assert_true(@util.dbl_approx_eq(r.x(), 5.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.y(), 10.0, @util.EPS))
}

///|
test "Transform3 identity" {
  let t = Transform3::identity()
  let p = Pt3::new(3.0, 4.0, 5.0)
  let r = t.apply(p)
  assert_true(@util.dbl_approx_eq(r.x(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.y(), 4.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.z(), 5.0, @util.EPS))
}

///|
test "Transform3 translation" {
  let t = Transform3::translation(1.0, 2.0, 3.0)
  let p = Pt3::new(10.0, 20.0, 30.0)
  let r = t.apply(p)
  assert_true(@util.dbl_approx_eq(r.x(), 11.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.y(), 22.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.z(), 33.0, @util.EPS))
}

///|
test "Transform3 scaling" {
  let t = Transform3::scaling(2.0, 3.0, 4.0)
  let p = Pt3::new(1.0, 1.0, 1.0)
  let r = t.apply(p)
  assert_true(@util.dbl_approx_eq(r.x(), 2.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.y(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.z(), 4.0, @util.EPS))
}

///|
test "Transform3 rotation_z 90 degrees" {
  let t = Transform3::rotation_z(1.5707963267948966)
  let p = Pt3::new(1.0, 0.0, 5.0)
  let r = t.apply(p)
  assert_true(@util.dbl_approx_eq(r.x(), 0.0, 1.0e-6))
  assert_true(@util.dbl_approx_eq(r.y(), 1.0, 1.0e-6))
  assert_true(@util.dbl_approx_eq(r.z(), 5.0, @util.EPS))
}

///|
test "Transform3 compose" {
  let t1 = Transform3::translation(1.0, 0.0, 0.0)
  let t2 = Transform3::translation(0.0, 2.0, 0.0)
  let composed = t1.compose(t2)
  let p = Pt3::new(0.0, 0.0, 0.0)
  let r = composed.apply(p)
  assert_true(@util.dbl_approx_eq(r.x(), 1.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r.y(), 2.0, @util.EPS))
}

///|
test "FAKE: Transform2 field completeness" {
  let t = Transform2::identity()
  let _ = t.apply(Pt2::new(0.0, 0.0))
  let _ = Transform2::translation(1.0, 2.0)
  let _ = Transform2::scaling(1.0, 1.0)
  let _ = Transform2::rotation(0.0)
}

///|
test "FAKE: Transform3 field completeness" {
  let t = Transform3::identity()
  let _ = t.apply(Pt3::new(0.0, 0.0, 0.0))
  let _ = Transform3::translation(1.0, 2.0, 3.0)
  let _ = Transform3::scaling(1.0, 1.0, 1.0)
  let _ = Transform3::rotation_x(0.0)
  let _ = Transform3::rotation_y(0.0)
  let _ = Transform3::rotation_z(0.0)
}

///|
test "E2E: transform point then verify on transformed circle" {
  let circle = Circle::new(0.0, 0.0, 5.0)
  let p = Pt2::new(3.0, 4.0)
  assert_true(circle.contains(p))
  let t = Transform2::translation(10.0, 20.0)
  let p2 = t.apply(p)
  let circle2_center = t.apply(circle.center())
  let circle2 = Circle::new(circle2_center.x(), circle2_center.y(), 5.0)
  assert_true(circle2.contains(p2))
}

///|
test "E2E: line-circle intersect then verify on both" {
  let line = Line2::new(0.0, 1.0, 0.0) // y = 0
  let circle = Circle::new(0.0, 0.0, 5.0)
  let pts = intersect_line_circle(line, circle)
  assert_eq(pts.length(), 2)
  for i in 0..<pts.length() {
    assert_true(line.contains(pts[i]))
    assert_true(circle.contains(pts[i]))
  }
}
