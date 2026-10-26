///|
test "convex_hull 空输入" {
  let hull = convex_hull([])
  assert_eq(hull.length(), 0)
}

///|
test "convex_hull 单点" {
  let hull = convex_hull([@alg.Pt2::new(1.0, 2.0)])
  assert_eq(hull.length(), 1)
  assert_true(approx(hull[0].x(), 1.0, 0.001))
  assert_true(approx(hull[0].y(), 2.0, 0.001))
}

///|
test "convex_hull 两点" {
  let hull = convex_hull([@alg.Pt2::new(0.0, 0.0), @alg.Pt2::new(1.0, 1.0)])
  assert_eq(hull.length(), 2)
}

///|
test "convex_hull 正方形+内部点" {
  let pts = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(1.0, 0.0),
    @alg.Pt2::new(1.0, 1.0),
    @alg.Pt2::new(0.0, 1.0),
    @alg.Pt2::new(0.5, 0.5),
  ]
  let hull = convex_hull(pts)
  assert_eq(hull.length(), 4)
  let area = polygon_signed_area(hull)
  assert_true(area > 0.0)
}

///|
test "convex_hull 三角形+内部点" {
  let pts = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(4.0, 0.0),
    @alg.Pt2::new(2.0, 3.0),
    @alg.Pt2::new(2.0, 1.0),
  ]
  let hull = convex_hull(pts)
  assert_eq(hull.length(), 3)
  let area = polygon_signed_area(hull)
  assert_true(area > 0.0)
}

///|
test "convex_hull 共线点" {
  let pts = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(1.0, 0.0),
    @alg.Pt2::new(2.0, 0.0),
    @alg.Pt2::new(3.0, 0.0),
  ]
  let hull = convex_hull(pts)
  assert_eq(hull.length(), 2)
}

///|
test "convex_hull 重复点" {
  let pts = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(1.0, 0.0),
    @alg.Pt2::new(1.0, 1.0),
    @alg.Pt2::new(0.0, 1.0),
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(1.0, 0.0),
    @alg.Pt2::new(1.0, 1.0),
  ]
  let hull = convex_hull(pts)
  assert_eq(hull.length(), 4)
}

///|
test "convex_hull 正五边形" {
  let pts = [
    @alg.Pt2::new(0.0, 1.0),
    @alg.Pt2::new(0.951, 0.309),
    @alg.Pt2::new(0.588, -0.809),
    @alg.Pt2::new(-0.588, -0.809),
    @alg.Pt2::new(-0.951, 0.309),
  ]
  let hull = convex_hull(pts)
  assert_eq(hull.length(), 5)
  let area = polygon_signed_area(hull)
  assert_true(area > 0.0)
}

///|
test "convex_hull 凸包包含所有点" {
  let pts = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
    @alg.Pt2::new(0.0, 10.0),
    @alg.Pt2::new(3.0, 3.0),
    @alg.Pt2::new(7.0, 2.0),
    @alg.Pt2::new(5.0, 8.0),
  ]
  let hull = convex_hull(pts)
  assert_eq(hull.length(), 4)
  for p in pts {
    let mut inside = true
    let n = hull.length()
    for i in 0..<n {
      let j = (i + 1) % n
      let cross = (hull[j].x() - hull[i].x()) * (p.y() - hull[i].y()) -
        (hull[j].y() - hull[i].y()) * (p.x() - hull[i].x())
      if cross < -0.001 {
        inside = false
      }
      let _ = j
    }
    assert_true(inside)
  }
}

///|
fn approx(a : Double, b : Double, tol : Double) -> Bool {
  (a - b).abs() < tol
}
