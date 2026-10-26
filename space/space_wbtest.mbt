// space 白盒测试：Euclid2 实现 Space Trait
// 白盒测试：本包类型直接引用（无 @space 前缀），能看到 impl

///|
test "Euclid2 dim" {
  let p = Euclid2::new(1.0, 2.0)
  assert_eq(@atop.Dim::dim(p), 2)
}

///|
test "Euclid2 distance" {
  let a = Euclid2::new(0.0, 0.0)
  let b = Euclid2::new(3.0, 4.0)
  let d = @atop.MetricSpace::distance(a, b)
  assert_true(@util.dbl_approx_eq(d, 5.0, @util.EPS))
  let d2 = @atop.MetricSpace::distance(b, a)
  assert_true(@util.dbl_approx_eq(d, d2, @util.EPS))
  assert_true(
    @util.dbl_approx_eq(@atop.MetricSpace::distance(a, a), 0.0, @util.EPS),
  )
}

///|
test "Euclid2 neighborhood" {
  let center = Euclid2::new(0.0, 0.0)
  let inside = Euclid2::new(0.5, 0.0)
  let outside = Euclid2::new(2.0, 0.0)
  assert_true(@atop.TopologicalSpace::is_in_neighborhood(inside, center, 1.0))
  assert_false(@atop.TopologicalSpace::is_in_neighborhood(outside, center, 1.0))
}

///|
test "Euclid2 space_kind" {
  let p = Euclid2::new(1.0, 1.0)
  assert_true(Space::space_kind(p) is SpaceKind::Euclidean2)
}

///|
test "Euclid2 triangle inequality" {
  let a = Euclid2::new(0.0, 0.0)
  let b = Euclid2::new(1.0, 0.0)
  let c = Euclid2::new(1.0, 1.0)
  let d_ab = @atop.MetricSpace::distance(a, b)
  let d_bc = @atop.MetricSpace::distance(b, c)
  let d_ac = @atop.MetricSpace::distance(a, c)
  assert_true(d_ac <= d_ab + d_bc + @util.EPS)
}

///|
test "Euclid2 coords" {
  let p = Euclid2::new(3.0, 5.0)
  assert_true(@util.dbl_approx_eq(p.x(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(p.y(), 5.0, @util.EPS))
}
