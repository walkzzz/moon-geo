///|
test "convex_hull 公开API 正方形" {
  let pts = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(2.0, 0.0),
    @alg.Pt2::new(2.0, 2.0),
    @alg.Pt2::new(0.0, 2.0),
    @alg.Pt2::new(1.0, 1.0),
  ]
  let hull = convex_hull(pts)
  assert_eq(hull.length(), 4)
}

///|
test "convex_hull 公开API 三角形" {
  let pts = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(4.0, 0.0),
    @alg.Pt2::new(2.0, 4.0),
    @alg.Pt2::new(2.0, 1.0),
  ]
  let hull = convex_hull(pts)
  assert_eq(hull.length(), 3)
}

///|
test "convex_hull 公开API 空输入" {
  let hull = convex_hull([])
  assert_eq(hull.length(), 0)
}

///|
test "convex_hull 公开API 共线" {
  let pts = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(1.0, 1.0),
    @alg.Pt2::new(2.0, 2.0),
    @alg.Pt2::new(3.0, 3.0),
  ]
  let hull = convex_hull(pts)
  assert_eq(hull.length(), 2)
}
