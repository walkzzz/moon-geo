// space 白盒测试：Euclid3 + SpaceMap
// 白盒测试：本包类型直接引用（无 @space 前缀），能看到 impl

///|
test "Euclid3 dim" {
  let p = Euclid3::new(1.0, 2.0, 3.0)
  assert_eq(@atop.Dim::dim(p), 3)
}

///|
test "Euclid3 distance" {
  let a = Euclid3::new(0.0, 0.0, 0.0)
  let b = Euclid3::new(3.0, 4.0, 0.0)
  let d = @atop.MetricSpace::distance(a, b)
  assert_true(@util.dbl_approx_eq(d, 5.0, @util.EPS))
  let c = Euclid3::new(0.0, 0.0, 0.0)
  let e = Euclid3::new(1.0, 2.0, 2.0)
  let d2 = @atop.MetricSpace::distance(c, e)
  assert_true(@util.dbl_approx_eq(d2, 3.0, @util.EPS))
}

///|
test "Euclid3 distance symmetry" {
  let a = Euclid3::new(1.0, 2.0, 3.0)
  let b = Euclid3::new(4.0, 6.0, 3.0)
  let d_ab = @atop.MetricSpace::distance(a, b)
  let d_ba = @atop.MetricSpace::distance(b, a)
  assert_true(@util.dbl_approx_eq(d_ab, d_ba, @util.EPS))
  assert_true(
    @util.dbl_approx_eq(@atop.MetricSpace::distance(a, a), 0.0, @util.EPS),
  )
}

///|
test "Euclid3 neighborhood" {
  let center = Euclid3::new(0.0, 0.0, 0.0)
  let inside = Euclid3::new(0.5, 0.0, 0.0)
  let outside = Euclid3::new(2.0, 0.0, 0.0)
  assert_true(@atop.TopologicalSpace::is_in_neighborhood(inside, center, 1.0))
  assert_false(@atop.TopologicalSpace::is_in_neighborhood(outside, center, 1.0))
}

///|
test "Euclid3 space_kind" {
  let p = Euclid3::new(1.0, 1.0, 1.0)
  assert_true(Space::space_kind(p) is SpaceKind::Euclidean3)
}

///|
test "Euclid3 triangle inequality" {
  let a = Euclid3::new(0.0, 0.0, 0.0)
  let b = Euclid3::new(1.0, 0.0, 0.0)
  let c = Euclid3::new(1.0, 1.0, 1.0)
  let d_ab = @atop.MetricSpace::distance(a, b)
  let d_bc = @atop.MetricSpace::distance(b, c)
  let d_ac = @atop.MetricSpace::distance(a, c)
  assert_true(d_ac <= d_ab + d_bc + @util.EPS)
}

///|
test "Euclid3 coords" {
  let p = Euclid3::new(3.0, 5.0, 7.0)
  assert_true(@util.dbl_approx_eq(p.x(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(p.y(), 5.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(p.z(), 7.0, @util.EPS))
}

///|
test "Embed2In3 basic" {
  let embed = Embed2In3::new()
  let p = Euclid2::new(3.0, 4.0)
  let q = embed.map(p)
  assert_true(@util.dbl_approx_eq(q.x(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(q.y(), 4.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(q.z(), 0.0, @util.EPS))
  assert_true(SpaceMap::source_kind(embed) is SpaceKind::Euclidean2)
  assert_true(SpaceMap::target_kind(embed) is SpaceKind::Euclidean3)
  assert_true(SpaceMap::is_injective(embed))
  assert_false(SpaceMap::is_surjective(embed))
}

///|
test "Embed2In3 with z offset" {
  let embed = Embed2In3::with_z(5.0)
  let p = Euclid2::new(1.0, 2.0)
  let q = embed.map(p)
  assert_true(@util.dbl_approx_eq(q.z(), 5.0, @util.EPS))
}

///|
test "Embed2In3 isometry" {
  let embed = Embed2In3::new()
  let a = Euclid2::new(0.0, 0.0)
  let b = Euclid2::new(3.0, 4.0)
  let d_src = @atop.MetricSpace::distance(a, b)
  let fa = embed.map(a)
  let fb = embed.map(b)
  let d_dst = @atop.MetricSpace::distance(fa, fb)
  assert_true(@util.dbl_approx_eq(d_src, d_dst, @util.EPS))
}

///|
test "Project3To2 basic" {
  let proj = Project3To2::new()
  let p = Euclid3::new(3.0, 4.0, 5.0)
  let q = proj.map(p)
  assert_true(@util.dbl_approx_eq(q.x(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(q.y(), 4.0, @util.EPS))
  assert_true(SpaceMap::source_kind(proj) is SpaceKind::Euclidean3)
  assert_true(SpaceMap::target_kind(proj) is SpaceKind::Euclidean2)
  assert_false(SpaceMap::is_injective(proj))
  assert_true(SpaceMap::is_surjective(proj))
}

///|
test "Project3To2 non-expansive" {
  let proj = Project3To2::new()
  let a = Euclid3::new(0.0, 0.0, 0.0)
  let b = Euclid3::new(3.0, 4.0, 12.0)
  let d_src = @atop.MetricSpace::distance(a, b)
  let fa = proj.map(a)
  let fb = proj.map(b)
  let d_dst = @atop.MetricSpace::distance(fa, fb)
  assert_true(d_dst <= d_src + @util.EPS)
}

///|
test "Project3To2 after Embed2In3 is identity" {
  let embed = Embed2In3::new()
  let proj = Project3To2::new()
  let p = Euclid2::new(3.0, 4.0)
  let embedded = embed.map(p)
  let projected = proj.map(embedded)
  assert_true(@util.dbl_approx_eq(projected.x(), p.x(), @util.EPS))
  assert_true(@util.dbl_approx_eq(projected.y(), p.y(), @util.EPS))
}
