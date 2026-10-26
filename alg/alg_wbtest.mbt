// alg 白盒测试：Pt2/Pt3/Line2 + FAKE 类型测试 + E2E 链路测试
// 白盒测试：本包类型直接引用（无 @alg 前缀），能看到 impl

///|
test "Pt2 construction and coords" {
  let p = Pt2::new(3.0, 5.0)
  assert_true(@util.dbl_approx_eq(p.x(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(p.y(), 5.0, @util.EPS))
}

///|
test "Pt2 distance" {
  let a = Pt2::new(0.0, 0.0)
  let b = Pt2::new(3.0, 4.0)
  assert_true(@util.dbl_approx_eq(a.distance_to(b), 5.0, @util.EPS))
}

///|
test "Pt2 coincident" {
  let a = Pt2::new(1.0, 2.0)
  let b = Pt2::new(1.0 + 1.0e-10, 2.0)
  let c = Pt2::new(10.0, 20.0)
  assert_true(a.coincident(b))
  assert_false(a.coincident(c))
}

///|
test "Pt2 Geo trait" {
  let p = Pt2::new(1.0, 2.0)
  assert_true(Geo::geo_dim(p) is GeoDim::Point)
  assert_false(Geo::is_degenerate(p))
}

///|
test "Pt2 Euclid2 conversion" {
  let p = Pt2::new(3.0, 4.0)
  let e = p.to_euclid()
  assert_true(@util.dbl_approx_eq(e.x(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(e.y(), 4.0, @util.EPS))
  let p2 = Pt2::from_euclid(e)
  assert_true(p.coincident(p2))
}

///|
test "Pt3 construction and coords" {
  let p = Pt3::new(3.0, 5.0, 7.0)
  assert_true(@util.dbl_approx_eq(p.x(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(p.y(), 5.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(p.z(), 7.0, @util.EPS))
}

///|
test "Pt3 distance" {
  let a = Pt3::new(0.0, 0.0, 0.0)
  let b = Pt3::new(3.0, 4.0, 12.0)
  assert_true(@util.dbl_approx_eq(a.distance_to(b), 13.0, @util.EPS))
}

///|
test "Pt3 coincident" {
  let a = Pt3::new(1.0, 2.0, 3.0)
  let b = Pt3::new(1.0 + 1.0e-10, 2.0, 3.0)
  let c = Pt3::new(10.0, 20.0, 30.0)
  assert_true(a.coincident(b))
  assert_false(a.coincident(c))
}

///|
test "Pt3 Geo trait" {
  let p = Pt3::new(1.0, 2.0, 3.0)
  assert_true(Geo::geo_dim(p) is GeoDim::Point)
  assert_false(Geo::is_degenerate(p))
}

///|
test "Pt3 Euclid3 conversion" {
  let p = Pt3::new(3.0, 4.0, 5.0)
  let e = p.to_euclid()
  assert_true(@util.dbl_approx_eq(e.z(), 5.0, @util.EPS))
  let p2 = Pt3::from_euclid(e)
  assert_true(p.coincident(p2))
}

///|
test "Line2 construction" {
  let l = Line2::new(1.0, 2.0, 3.0)
  assert_true(@util.dbl_approx_eq(l.a(), 1.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(l.b(), 2.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(l.c(), 3.0, @util.EPS))
}

///|
test "Line2 from_two_points" {
  let p1 = Pt2::new(0.0, 0.0)
  let p2 = Pt2::new(1.0, 1.0)
  match Line2::from_two_points(p1, p2) {
    Ok(l) => {
      assert_true(l.contains(Pt2::new(0.5, 0.5)))
      assert_true(l.contains(Pt2::new(2.0, 2.0)))
      assert_false(l.contains(Pt2::new(0.0, 1.0)))
    }
    Err(_) => assert_true(false)
  }
}

///|
test "Line2 from_two_points coincident degenerate" {
  let p1 = Pt2::new(1.0, 2.0)
  let p2 = Pt2::new(1.0 + 1.0e-12, 2.0)
  match Line2::from_two_points(p1, p2) {
    Ok(_) => assert_true(false)
    Err(e) => assert_true(e.code is @util.GeoErrorCode::DegenerateInput)
  }
}

///|
test "Line2 eval" {
  let l = Line2::new(1.0, -1.0, 0.0)
  assert_true(@util.dbl_approx_eq(l.eval(Pt2::new(3.0, 3.0)), 0.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(l.eval(Pt2::new(3.0, 0.0)), 3.0, @util.EPS))
}

///|
test "Line2 contains" {
  let l = Line2::new(2.0, 3.0, -6.0)
  assert_true(l.contains(Pt2::new(0.0, 2.0)))
  assert_true(l.contains(Pt2::new(3.0, 0.0)))
  assert_false(l.contains(Pt2::new(1.0, 1.0)))
}

///|
test "Line2 distance_to_point" {
  let l = Line2::new(0.0, 1.0, 0.0)
  let p = Pt2::new(5.0, 3.0)
  assert_true(@util.dbl_approx_eq(l.distance_to_point(p), 3.0, @util.EPS))
  let p2 = Pt2::new(5.0, 0.0)
  assert_true(@util.dbl_approx_eq(l.distance_to_point(p2), 0.0, @util.EPS))
}

///|
test "Line2 intersect basic" {
  let l1 = Line2::new(1.0, 0.0, -2.0) // x = 2
  let l2 = Line2::new(0.0, 1.0, -3.0) // y = 3
  match l1.intersect(l2) {
    Some(p) => {
      assert_true(@util.dbl_approx_eq(p.x(), 2.0, @util.EPS))
      assert_true(@util.dbl_approx_eq(p.y(), 3.0, @util.EPS))
    }
    None => assert_true(false)
  }
}

///|
test "Line2 intersect parallel" {
  let l1 = Line2::new(1.0, 1.0, 0.0)
  let l2 = Line2::new(1.0, 1.0, -5.0)
  assert_true(l1.intersect(l2) is None)
  assert_true(l1.is_parallel(l2))
}

///|
test "Line2 intersect diagonal" {
  match Line2::from_two_points(Pt2::new(0.0, 0.0), Pt2::new(1.0, 1.0)) {
    Ok(l1) =>
      match Line2::from_two_points(Pt2::new(0.0, 1.0), Pt2::new(1.0, 0.0)) {
        Ok(l2) =>
          match l1.intersect(l2) {
            Some(p) => {
              assert_true(@util.dbl_approx_eq(p.x(), 0.5, @util.EPS))
              assert_true(@util.dbl_approx_eq(p.y(), 0.5, @util.EPS))
            }
            None => assert_true(false)
          }
        Err(_) => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}

///|
test "Line2 Geo trait" {
  let l = Line2::new(1.0, 2.0, 3.0)
  assert_true(Geo::geo_dim(l) is GeoDim::Curve)
  assert_false(Geo::is_degenerate(l))
}

///|
test "Line2 is_degenerate" {
  let l = Line2::new(0.0, 0.0, 5.0)
  assert_true(Geo::is_degenerate(l))
}

///|
test "Line2 is_parallel" {
  let l1 = Line2::new(2.0, 4.0, 1.0)
  let l2 = Line2::new(1.0, 2.0, 3.0)
  let l3 = Line2::new(1.0, -2.0, 3.0)
  assert_true(l1.is_parallel(l2))
  assert_false(l1.is_parallel(l3))
}

///|
test "FAKE: Pt2 field completeness" {
  let p = Pt2::new(1.0, 2.0)
  let _ = p.x()
  let _ = p.y()
  let _ = Geo::geo_dim(p)
  let _ = Geo::is_degenerate(p)
}

///|
test "FAKE: Pt3 field completeness" {
  let p = Pt3::new(1.0, 2.0, 3.0)
  let _ = p.x()
  let _ = p.y()
  let _ = p.z()
  let _ = Geo::geo_dim(p)
  let _ = Geo::is_degenerate(p)
}

///|
test "FAKE: Line2 field completeness" {
  let l = Line2::new(1.0, 2.0, 3.0)
  let _ = l.a()
  let _ = l.b()
  let _ = l.c()
  let _ = Geo::geo_dim(l)
  let _ = Geo::is_degenerate(l)
}

///|
test "E2E: two points -> line -> intersect -> verify" {
  let p1 = Pt2::new(1.0, 1.0)
  let p2 = Pt2::new(3.0, 3.0)
  let p3 = Pt2::new(1.0, 3.0)
  let p4 = Pt2::new(3.0, 1.0)
  match Line2::from_two_points(p1, p2) {
    Ok(l1) =>
      match Line2::from_two_points(p3, p4) {
        Ok(l2) =>
          match l1.intersect(l2) {
            Some(ip) => {
              assert_true(l1.contains(ip))
              assert_true(l2.contains(ip))
              assert_true(@util.dbl_approx_eq(ip.x(), 2.0, @util.EPS))
              assert_true(@util.dbl_approx_eq(ip.y(), 2.0, @util.EPS))
            }
            None => assert_true(false)
          }
        Err(_) => assert_true(false)
      }
    Err(_) => assert_true(false)
  }
}

///|
test "E2E: Pt2 -> Euclid2 -> distance cross-layer" {
  let p1 = Pt2::new(0.0, 0.0)
  let p2 = Pt2::new(3.0, 4.0)
  let d_geo = p1.distance_to(p2)
  let e1 = p1.to_euclid()
  let e2 = p2.to_euclid()
  let dx = e1.x() - e2.x()
  let dy = e1.y() - e2.y()
  let d_space = (dx * dx + dy * dy).sqrt()
  assert_true(@util.dbl_approx_eq(d_geo, d_space, @util.EPS))
}
