// alg 白盒测试：Plane3 + Sphere + Quad3 + 幂定理
// 含 FAKE 类型测试 + E2E 链路测试

///|
test "Plane3 construction" {
  let p = Plane3::new(1.0, 2.0, 3.0, 4.0)
  assert_true(@util.dbl_approx_eq(p.a(), 1.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(p.d(), 4.0, @util.EPS))
}

///|
test "Plane3 from_three_points" {
  let p1 = Pt3::new(0.0, 0.0, 0.0)
  let p2 = Pt3::new(1.0, 0.0, 0.0)
  let p3 = Pt3::new(0.0, 1.0, 0.0)
  match Plane3::from_three_points(p1, p2, p3) {
    Ok(plane) => {
      assert_true(plane.contains(p1))
      assert_true(plane.contains(p2))
      assert_true(plane.contains(p3))
      assert_true(plane.contains(Pt3::new(0.5, 0.5, 0.0)))
      assert_false(plane.contains(Pt3::new(0.0, 0.0, 1.0)))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "Plane3 from_three_points collinear degenerate" {
  let p1 = Pt3::new(0.0, 0.0, 0.0)
  let p2 = Pt3::new(1.0, 1.0, 1.0)
  let p3 = Pt3::new(2.0, 2.0, 2.0)
  match Plane3::from_three_points(p1, p2, p3) {
    Ok(_) => assert_true(false)
    Err(e) => assert_true(e.code is @util.GeoErrorCode::DegenerateInput)
  }
}

///|
test "Plane3 eval and contains" {
  let p = Plane3::new(1.0, 0.0, 0.0, -5.0)
  assert_true(
    @util.dbl_approx_eq(p.eval(Pt3::new(5.0, 100.0, 200.0)), 0.0, @util.EPS),
  )
  assert_true(p.contains(Pt3::new(5.0, 0.0, 0.0)))
  assert_false(p.contains(Pt3::new(3.0, 0.0, 0.0)))
}

///|
test "Plane3 distance_to_point" {
  let p = Plane3::new(0.0, 0.0, 1.0, 0.0)
  assert_true(
    @util.dbl_approx_eq(
      p.distance_to_point(Pt3::new(1.0, 2.0, 5.0)),
      5.0,
      @util.EPS,
    ),
  )
  assert_true(
    @util.dbl_approx_eq(
      p.distance_to_point(Pt3::new(0.0, 0.0, 0.0)),
      0.0,
      @util.EPS,
    ),
  )
}

///|
test "Plane3 Geo trait" {
  let p = Plane3::new(1.0, 2.0, 3.0, 4.0)
  assert_true(Geo::geo_dim(p) is GeoDim::Surface)
  assert_false(Geo::is_degenerate(p))
  let d = Plane3::new(0.0, 0.0, 0.0, 5.0)
  assert_true(Geo::is_degenerate(d))
}

///|
test "Sphere construction" {
  let s = Sphere::new(1.0, 2.0, 3.0, 5.0)
  assert_true(@util.dbl_approx_eq(s.cx(), 1.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(s.r(), 5.0, @util.EPS))
}

///|
test "Sphere volume" {
  let s = Sphere::new(0.0, 0.0, 0.0, 3.0)
  assert_true(@util.dbl_approx_eq(s.volume(), 113.09733552923254, 1.0e-6))
}

///|
test "Sphere surface_area" {
  let s = Sphere::new(0.0, 0.0, 0.0, 3.0)
  assert_true(@util.dbl_approx_eq(s.surface_area(), 113.09733552923254, 1.0e-6))
}

///|
test "Sphere contains" {
  let s = Sphere::new(0.0, 0.0, 0.0, 5.0)
  assert_true(s.contains(Pt3::new(3.0, 0.0, 4.0)))
  assert_true(s.contains(Pt3::new(5.0, 0.0, 0.0)))
  assert_false(s.contains(Pt3::new(1.0, 1.0, 1.0)))
}

///|
test "Sphere contains_interior" {
  let s = Sphere::new(0.0, 0.0, 0.0, 5.0)
  assert_true(s.contains_interior(Pt3::new(1.0, 1.0, 1.0)))
  assert_false(s.contains_interior(Pt3::new(5.0, 0.0, 0.0)))
}

///|
test "Sphere power outside" {
  let s = Sphere::new(0.0, 0.0, 0.0, 3.0)
  let p = Pt3::new(5.0, 0.0, 0.0)
  let pow = s.power(p)
  assert_true(@util.dbl_approx_eq(pow, 16.0, @util.EPS))
}

///|
test "Sphere power on surface" {
  let s = Sphere::new(0.0, 0.0, 0.0, 3.0)
  let p = Pt3::new(3.0, 0.0, 0.0)
  let pow = s.power(p)
  assert_true(@util.dbl_approx_eq(pow, 0.0, @util.EPS))
}

///|
test "Sphere power inside" {
  let s = Sphere::new(0.0, 0.0, 0.0, 5.0)
  let p = Pt3::new(1.0, 0.0, 0.0)
  let pow = s.power(p)
  assert_true(pow < 0.0)
}

///|
test "Sphere tangent_length" {
  let s = Sphere::new(0.0, 0.0, 0.0, 3.0)
  let p = Pt3::new(5.0, 0.0, 0.0)
  let tl = s.tangent_length(p)
  assert_true(@util.dbl_approx_eq(tl, 4.0, @util.EPS))
}

///|
test "Sphere Geo trait" {
  let s = Sphere::new(0.0, 0.0, 0.0, 1.0)
  assert_true(Geo::geo_dim(s) is GeoDim::Surface)
  assert_false(Geo::is_degenerate(s))
  let d = Sphere::new(0.0, 0.0, 0.0, 0.0)
  assert_true(Geo::is_degenerate(d))
}

///|
test "Circle power" {
  let c = Circle::new(0.0, 0.0, 3.0)
  let p_out = Pt2::new(5.0, 0.0)
  let p_on = Pt2::new(3.0, 0.0)
  let p_in = Pt2::new(1.0, 0.0)
  assert_true(@util.dbl_approx_eq(c.power(p_out), 16.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(c.power(p_on), 0.0, @util.EPS))
  assert_true(c.power(p_in) < 0.0)
}

///|
test "Circle tangent_length" {
  let c = Circle::new(0.0, 0.0, 3.0)
  let p = Pt2::new(5.0, 0.0)
  assert_true(@util.dbl_approx_eq(c.tangent_length(p), 4.0, @util.EPS))
}

///|
test "Quad3 construction and eval" {
  let q = Quad3::new(1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -9.0)
  assert_true(q.contains(Pt3::new(3.0, 0.0, 0.0)))
  assert_true(q.contains(Pt3::new(0.0, 3.0, 0.0)))
  assert_true(q.contains(Pt3::new(0.0, 0.0, 3.0)))
  assert_false(q.contains(Pt3::new(1.0, 1.0, 1.0)))
}

///|
test "Quad3 from_sphere" {
  let s = Sphere::new(1.0, 2.0, 3.0, 5.0)
  let q = Quad3::from_sphere(s)
  assert_true(q.contains(Pt3::new(6.0, 2.0, 3.0)))
  assert_true(q.contains(Pt3::new(1.0, 7.0, 3.0)))
  assert_true(q.contains(Pt3::new(1.0, 2.0, 8.0)))
}

///|
test "Quad3 Geo trait" {
  let q = Quad3::new(1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, -1.0)
  assert_true(Geo::geo_dim(q) is GeoDim::Surface)
  assert_false(Geo::is_degenerate(q))
}

///|
test "FAKE: Plane3 field completeness" {
  let p = Plane3::new(1.0, 2.0, 3.0, 4.0)
  let _ = p.a()
  let _ = p.b()
  let _ = p.c()
  let _ = p.d()
  let _ = Geo::geo_dim(p)
  let _ = Geo::is_degenerate(p)
}

///|
test "FAKE: Sphere field completeness" {
  let s = Sphere::new(1.0, 2.0, 3.0, 4.0)
  let _ = s.cx()
  let _ = s.cy()
  let _ = s.cz()
  let _ = s.r()
  let _ = s.center()
  let _ = s.volume()
  let _ = s.surface_area()
  let _ = Geo::geo_dim(s)
  let _ = Geo::is_degenerate(s)
}

///|
test "E2E: Sphere -> Quad3 -> verify surface" {
  let s = Sphere::new(1.0, 2.0, 3.0, 5.0)
  let q = Quad3::from_sphere(s)
  let p = Pt3::new(6.0, 2.0, 3.0)
  assert_true(s.contains(p))
  assert_true(q.contains(p))
}

///|
test "E2E: power theorem - tangent length squared equals power" {
  let s = Sphere::new(0.0, 0.0, 0.0, 3.0)
  let p = Pt3::new(5.0, 0.0, 0.0)
  let pow = s.power(p)
  let tl = s.tangent_length(p)
  assert_true(@util.dbl_approx_eq(tl * tl, pow, @util.EPS))
}

///|
test "E2E: circle power theorem unified" {
  let c = Circle::new(1.0, 1.0, 3.0)
  let p = Pt2::new(5.0, 1.0)
  let pow = c.power(p)
  let tl = c.tangent_length(p)
  assert_true(@util.dbl_approx_eq(tl * tl, pow, @util.EPS))
  assert_true(pow > 0.0)
}
