// atop/topo 白盒测试：验证 Trait 设计可用性
// 用 2D 欧氏点 E2Pt 作为具体实现示例
// 白盒测试：trait 直接引用（无 @atop 前缀），可实现本包 trait

///|
struct E2Pt {
  x : Double
  y : Double
}

///|
fn E2Pt::new(x : Double, y : Double) -> E2Pt {
  { x, y, }
}

///|
fn e2_dist(a : E2Pt, b : E2Pt) -> Double {
  let dx = a.x - b.x
  let dy = a.y - b.y
  (dx * dx + dy * dy).sqrt()
}

///|
impl Dim for E2Pt with fn dim(_) {
  2
}

///|
impl TopologicalSpace for E2Pt with fn is_in_neighborhood(self, center, radius) {
  e2_dist(self, center) <= radius
}

///|
impl MetricSpace for E2Pt with fn distance(self, other) {
  e2_dist(self, other)
}

///|
impl Manifold for E2Pt with fn local_chart(self) {
  [self.x, self.y]
}

///|
test "Dim for E2Pt" {
  let p = E2Pt::new(1.0, 2.0)
  assert_eq(Dim::dim(p), 2)
}

///|
test "TopologicalSpace neighborhood" {
  let center = E2Pt::new(0.0, 0.0)
  let inside = E2Pt::new(0.5, 0.0)
  let outside = E2Pt::new(2.0, 0.0)
  assert_true(TopologicalSpace::is_in_neighborhood(inside, center, 1.0))
  assert_false(TopologicalSpace::is_in_neighborhood(outside, center, 1.0))
}

///|
test "MetricSpace distance" {
  let a = E2Pt::new(0.0, 0.0)
  let b = E2Pt::new(3.0, 4.0)
  let d = MetricSpace::distance(a, b)
  assert_true(@util.dbl_approx_eq(d, 5.0, @util.EPS))
  // 对称性
  let d2 = MetricSpace::distance(b, a)
  assert_true(@util.dbl_approx_eq(d, d2, @util.EPS))
  // 同一性
  assert_true(@util.dbl_approx_eq(MetricSpace::distance(a, a), 0.0, @util.EPS))
}

///|
test "MetricSpace triangle inequality" {
  let a = E2Pt::new(0.0, 0.0)
  let b = E2Pt::new(1.0, 0.0)
  let c = E2Pt::new(1.0, 1.0)
  let d_ab = MetricSpace::distance(a, b)
  let d_bc = MetricSpace::distance(b, c)
  let d_ac = MetricSpace::distance(a, c)
  assert_true(d_ac <= d_ab + d_bc + @util.EPS)
}

///|
test "in_metric_ball helper" {
  let center = E2Pt::new(0.0, 0.0)
  let p = E2Pt::new(0.3, 0.4)
  assert_true(in_metric_ball(p, center, 1.0))
  assert_false(in_metric_ball(p, center, 0.4))
}

///|
test "Manifold local_chart" {
  let p = E2Pt::new(3.0, 5.0)
  let chart = Manifold::local_chart(p)
  assert_eq(chart.length(), 2)
  assert_true(@util.dbl_approx_eq(chart[0], 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(chart[1], 5.0, @util.EPS))
}

///|
test "Manifold dimension consistency" {
  let p = E2Pt::new(1.0, 1.0)
  assert_eq(Dim::dim(p), 2)
  let chart = Manifold::local_chart(p)
  assert_eq(chart.length(), Dim::dim(p))
}
