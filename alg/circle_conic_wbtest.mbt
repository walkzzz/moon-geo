// alg 白盒测试：Circle + Conic2 + discriminant
// 含 FAKE 类型测试 + E2E 链路测试

///|
test "Circle construction" {
  let c = Circle::new(1.0, 2.0, 3.0)
  assert_true(@util.dbl_approx_eq(c.cx(), 1.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(c.cy(), 2.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(c.r(), 3.0, @util.EPS))
}

///|
test "Circle area" {
  let c = Circle::new(0.0, 0.0, 2.0)
  assert_true(@util.dbl_approx_eq(c.area(), 12.566370614359172, 1.0e-6))
}

///|
test "Circle circumference" {
  let c = Circle::new(0.0, 0.0, 2.0)
  assert_true(
    @util.dbl_approx_eq(c.circumference(), 12.566370614359172, 1.0e-6),
  )
}

///|
test "Circle contains" {
  let c = Circle::new(0.0, 0.0, 5.0)
  assert_true(c.contains(Pt2::new(3.0, 4.0)))
  assert_true(c.contains(Pt2::new(5.0, 0.0)))
  assert_false(c.contains(Pt2::new(3.0, 3.0)))
}

///|
test "Circle contains_interior" {
  let c = Circle::new(0.0, 0.0, 5.0)
  assert_true(c.contains_interior(Pt2::new(3.0, 3.0)))
  assert_false(c.contains_interior(Pt2::new(5.0, 0.0)))
  assert_false(c.contains_interior(Pt2::new(10.0, 0.0)))
}

///|
test "Circle distance_to_point" {
  let c = Circle::new(0.0, 0.0, 5.0)
  assert_true(
    @util.dbl_approx_eq(c.distance_to_point(Pt2::new(0.0, 0.0)), 5.0, @util.EPS),
  )
  assert_true(
    @util.dbl_approx_eq(
      c.distance_to_point(Pt2::new(10.0, 0.0)),
      5.0,
      @util.EPS,
    ),
  )
  assert_true(
    @util.dbl_approx_eq(c.distance_to_point(Pt2::new(3.0, 4.0)), 0.0, @util.EPS),
  )
}

///|
test "Circle from_three_points" {
  let p1 = Pt2::new(1.0, 0.0)
  let p2 = Pt2::new(0.0, 1.0)
  let p3 = Pt2::new(-1.0, 0.0)
  match Circle::from_three_points(p1, p2, p3) {
    Ok(c) => {
      assert_true(@util.dbl_approx_eq(c.cx(), 0.0, @util.EPS))
      assert_true(@util.dbl_approx_eq(c.cy(), 0.0, @util.EPS))
      assert_true(@util.dbl_approx_eq(c.r(), 1.0, @util.EPS))
      assert_true(c.contains(p1))
      assert_true(c.contains(p2))
      assert_true(c.contains(p3))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "Circle from_three_points collinear degenerate" {
  let p1 = Pt2::new(0.0, 0.0)
  let p2 = Pt2::new(1.0, 0.0)
  let p3 = Pt2::new(2.0, 0.0)
  match Circle::from_three_points(p1, p2, p3) {
    Ok(_) => assert_true(false)
    Err(e) => assert_true(e.code is @util.GeoErrorCode::DegenerateInput)
  }
}

///|
test "Circle Geo trait" {
  let c = Circle::new(0.0, 0.0, 1.0)
  assert_true(Geo::geo_dim(c) is GeoDim::Surface)
  assert_false(Geo::is_degenerate(c))
  let d = Circle::new(0.0, 0.0, 0.0)
  assert_true(Geo::is_degenerate(d))
}

///|
test "Conic2 construction" {
  let c = Conic2::new(1.0, 0.0, 1.0, 0.0, 0.0, -1.0)
  assert_true(@util.dbl_approx_eq(c.a(), 1.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(c.f(), -1.0, @util.EPS))
}

///|
test "Conic2 discriminant ellipse" {
  let c = Conic2::new(1.0, 0.0, 1.0, 0.0, 0.0, -1.0)
  let disc = c.discriminant()
  assert_true(disc < 0.0)
}

///|
test "Conic2 discriminant parabola" {
  let c = Conic2::new(1.0, 0.0, 0.0, 0.0, -1.0, 0.0)
  let disc = c.discriminant()
  assert_true(@util.dbl_approx_eq(disc, 0.0, @util.EPS))
}

///|
test "Conic2 discriminant hyperbola" {
  let c = Conic2::new(1.0, 0.0, -1.0, 0.0, 0.0, -1.0)
  let disc = c.discriminant()
  assert_true(disc > 0.0)
}

///|
test "Conic2 classify" {
  let ellipse = Conic2::new(1.0, 0.0, 1.0, 0.0, 0.0, -1.0)
  assert_true(ellipse.classify() is ConicType::Ellipse)
  let parabola = Conic2::new(1.0, 0.0, 0.0, 0.0, -1.0, 0.0)
  assert_true(parabola.classify() is ConicType::Parabola)
  let hyperbola = Conic2::new(1.0, 0.0, -1.0, 0.0, 0.0, -1.0)
  assert_true(hyperbola.classify() is ConicType::Hyperbola)
}

///|
test "Conic2 eval and contains" {
  let c = Conic2::new(1.0, 0.0, 1.0, 0.0, 0.0, -25.0)
  assert_true(c.contains(Pt2::new(3.0, 4.0)))
  assert_true(c.contains(Pt2::new(5.0, 0.0)))
  assert_false(c.contains(Pt2::new(1.0, 1.0)))
}

///|
test "Conic2 from_circle" {
  let circle = Circle::new(1.0, 2.0, 3.0)
  let conic = Conic2::from_circle(circle)
  assert_true(conic.classify() is ConicType::Ellipse)
  assert_true(conic.contains(Pt2::new(4.0, 2.0)))
  assert_true(conic.contains(Pt2::new(1.0, 5.0)))
}

///|
test "Conic2 Geo trait" {
  let c = Conic2::new(1.0, 0.0, 1.0, 0.0, 0.0, -1.0)
  assert_true(Geo::geo_dim(c) is GeoDim::Curve)
  assert_false(Geo::is_degenerate(c))
  let d = Conic2::new(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
  assert_true(Geo::is_degenerate(d))
}

///|
test "FAKE: Circle field completeness" {
  let c = Circle::new(1.0, 2.0, 3.0)
  let _ = c.cx()
  let _ = c.cy()
  let _ = c.r()
  let _ = c.center()
  let _ = c.area()
  let _ = c.circumference()
  let _ = Geo::geo_dim(c)
  let _ = Geo::is_degenerate(c)
}

///|
test "FAKE: Conic2 field completeness" {
  let c = Conic2::new(1.0, 2.0, 3.0, 4.0, 5.0, 6.0)
  let _ = c.a()
  let _ = c.b()
  let _ = c.c()
  let _ = c.d()
  let _ = c.e()
  let _ = c.f()
  let _ = c.discriminant()
  let _ = c.classify()
  let _ = Geo::geo_dim(c)
  let _ = Geo::is_degenerate(c)
}

///|
test "E2E: Circle -> Conic2 -> classify -> verify" {
  let circle = Circle::new(0.0, 0.0, 5.0)
  let conic = Conic2::from_circle(circle)
  assert_true(conic.classify() is ConicType::Ellipse)
  let p_on = Pt2::new(3.0, 4.0)
  assert_true(circle.contains(p_on))
  assert_true(conic.contains(p_on))
}

///|
test "E2E: three points -> circle -> conic -> all on curve" {
  let p1 = Pt2::new(5.0, 0.0)
  let p2 = Pt2::new(0.0, 5.0)
  let p3 = Pt2::new(-5.0, 0.0)
  match Circle::from_three_points(p1, p2, p3) {
    Ok(circle) => {
      let conic = Conic2::from_circle(circle)
      assert_true(circle.contains(p1))
      assert_true(circle.contains(p2))
      assert_true(circle.contains(p3))
      assert_true(conic.contains(p1))
      assert_true(conic.contains(p2))
      assert_true(conic.contains(p3))
    }
    Err(_) => assert_true(false)
  }
}
