// bv 白盒测试：Aabb2/Aabb3/SphereBv/BVH
// 含 FAKE 类型测试 + E2E 链路测试

///|
test "Aabb2 construction" {
  let b = Aabb2::new(0.0, 0.0, 10.0, 20.0)
  assert_true(@util.dbl_approx_eq(b.min_x(), 0.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(b.max_x(), 10.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(b.min_y(), 0.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(b.max_y(), 20.0, @util.EPS))
}

///|
test "Aabb2 from_two_points" {
  let p1 = @alg.Pt2::new(5.0, 10.0)
  let p2 = @alg.Pt2::new(-3.0, 7.0)
  let b = Aabb2::from_two_points(p1, p2)
  assert_true(@util.dbl_approx_eq(b.min_x(), -3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(b.max_x(), 5.0, @util.EPS))
}

///|
test "Aabb2 contains" {
  let b = Aabb2::new(0.0, 0.0, 10.0, 10.0)
  assert_true(b.contains(@alg.Pt2::new(5.0, 5.0)))
  assert_true(b.contains(@alg.Pt2::new(0.0, 0.0)))
  assert_true(b.contains(@alg.Pt2::new(10.0, 10.0)))
  assert_false(b.contains(@alg.Pt2::new(11.0, 5.0)))
}

///|
test "Aabb2 intersect" {
  let b1 = Aabb2::new(0.0, 0.0, 10.0, 10.0)
  let b2 = Aabb2::new(5.0, 5.0, 15.0, 15.0)
  let b3 = Aabb2::new(20.0, 20.0, 30.0, 30.0)
  assert_true(b1.intersect(b2))
  assert_false(b1.intersect(b3))
}

///|
test "Aabb2 union" {
  let b1 = Aabb2::new(0.0, 0.0, 5.0, 5.0)
  let b2 = Aabb2::new(3.0, 3.0, 10.0, 10.0)
  let u = b1.union(b2)
  assert_true(@util.dbl_approx_eq(u.min_x(), 0.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(u.max_x(), 10.0, @util.EPS))
}

///|
test "Aabb2 Bv trait" {
  let b = Aabb2::new(0.0, 0.0, 10.0, 20.0)
  assert_true(@util.dbl_approx_eq(Bv::bv_volume(b), 200.0, @util.EPS))
  assert_false(Bv::bv_is_empty(b))
}

///|
test "Aabb3 construction" {
  let b = Aabb3::new(0.0, 0.0, 0.0, 10.0, 20.0, 30.0)
  assert_true(@util.dbl_approx_eq(b.max_z(), 30.0, @util.EPS))
}

///|
test "Aabb3 contains" {
  let b = Aabb3::new(0.0, 0.0, 0.0, 10.0, 10.0, 10.0)
  assert_true(b.contains(@alg.Pt3::new(5.0, 5.0, 5.0)))
  assert_false(b.contains(@alg.Pt3::new(11.0, 5.0, 5.0)))
}

///|
test "Aabb3 intersect" {
  let b1 = Aabb3::new(0.0, 0.0, 0.0, 10.0, 10.0, 10.0)
  let b2 = Aabb3::new(5.0, 5.0, 5.0, 15.0, 15.0, 15.0)
  let b3 = Aabb3::new(20.0, 20.0, 20.0, 30.0, 30.0, 30.0)
  assert_true(b1.intersect(b2))
  assert_false(b1.intersect(b3))
}

///|
test "Aabb3 union" {
  let b1 = Aabb3::new(0.0, 0.0, 0.0, 5.0, 5.0, 5.0)
  let b2 = Aabb3::new(3.0, 3.0, 3.0, 10.0, 10.0, 10.0)
  let u = b1.union(b2)
  assert_true(@util.dbl_approx_eq(u.max_x(), 10.0, @util.EPS))
}

///|
test "Aabb3 Bv trait" {
  let b = Aabb3::new(0.0, 0.0, 0.0, 10.0, 20.0, 30.0)
  assert_true(@util.dbl_approx_eq(Bv::bv_volume(b), 6000.0, @util.EPS))
  assert_false(Bv::bv_is_empty(b))
}

///|
test "SphereBv construction" {
  let s = SphereBv::new(1.0, 2.0, 3.0, 5.0)
  assert_true(@util.dbl_approx_eq(s.r(), 5.0, @util.EPS))
}

///|
test "SphereBv from_aabb" {
  let aabb = Aabb3::new(-1.0, -1.0, -1.0, 1.0, 1.0, 1.0)
  let s = SphereBv::from_aabb(aabb)
  assert_true(@util.dbl_approx_eq(s.cx(), 0.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(s.r(), 1.7320508075688772, 1.0e-6))
}

///|
test "SphereBv contains" {
  let s = SphereBv::new(0.0, 0.0, 0.0, 5.0)
  assert_true(s.contains(@alg.Pt3::new(3.0, 0.0, 4.0)))
  assert_false(s.contains(@alg.Pt3::new(10.0, 0.0, 0.0)))
}

///|
test "SphereBv intersect" {
  let s1 = SphereBv::new(0.0, 0.0, 0.0, 5.0)
  let s2 = SphereBv::new(8.0, 0.0, 0.0, 5.0)
  let s3 = SphereBv::new(20.0, 0.0, 0.0, 5.0)
  assert_true(s1.intersect(s2))
  assert_false(s1.intersect(s3))
}

///|
test "SphereBv union" {
  let s1 = SphereBv::new(0.0, 0.0, 0.0, 3.0)
  let s2 = SphereBv::new(8.0, 0.0, 0.0, 3.0)
  let u = s1.union(s2)
  assert_true(u.r() >= 5.0)
}

///|
test "SphereBv Bv trait" {
  let s = SphereBv::new(0.0, 0.0, 0.0, 3.0)
  let vol = Bv::bv_volume(s)
  assert_true(vol > 0.0)
  assert_false(Bv::bv_is_empty(s))
}

///|
test "BVH build and query" {
  let leaves = [
    (Aabb3::new(0.0, 0.0, 0.0, 1.0, 1.0, 1.0), 0),
    (Aabb3::new(5.0, 5.0, 5.0, 6.0, 6.0, 6.0), 1),
    (Aabb3::new(10.0, 10.0, 10.0, 11.0, 11.0, 11.0), 2),
    (Aabb3::new(0.5, 0.5, 0.5, 1.5, 1.5, 1.5), 3),
  ]
  match BVHNode::build(leaves) {
    Some(root) => {
      let query = Aabb3::new(0.0, 0.0, 0.0, 2.0, 2.0, 4.0)
      let result = []
      root.query_intersect(query, result)
      assert_true(result.length() >= 2)
    }
    None => assert_true(false)
  }
}

///|
test "FAKE: Aabb2 field completeness" {
  let b = Aabb2::new(0.0, 0.0, 1.0, 1.0)
  let _ = b.min_x()
  let _ = b.max_x()
  let _ = b.min_y()
  let _ = b.max_y()
  let _ = b.center()
  let _ = Bv::bv_volume(b)
  let _ = Bv::bv_is_empty(b)
}

///|
test "FAKE: Aabb3 field completeness" {
  let b = Aabb3::new(0.0, 0.0, 0.0, 1.0, 1.0, 1.0)
  let _ = b.min_x()
  let _ = b.max_z()
  let _ = b.center()
  let _ = Bv::bv_volume(b)
  let _ = Bv::bv_is_empty(b)
}

///|
test "FAKE: SphereBv field completeness" {
  let s = SphereBv::new(0.0, 0.0, 0.0, 1.0)
  let _ = s.cx()
  let _ = s.r()
  let _ = Bv::bv_volume(s)
  let _ = Bv::bv_is_empty(s)
}

///|
test "E2E: Aabb3 -> SphereBv -> contain check" {
  let aabb = Aabb3::new(-3.0, -3.0, -3.0, 3.0, 3.0, 3.0)
  let sphere = SphereBv::from_aabb(aabb)
  let p = @alg.Pt3::new(2.0, 2.0, 2.0)
  assert_true(aabb.contains(p))
  assert_true(sphere.contains(p))
}

///|
test "E2E: BVH query finds overlapping leaves" {
  let leaves = [
    (Aabb3::new(0.0, 0.0, 0.0, 2.0, 2.0, 2.0), 0),
    (Aabb3::new(1.0, 1.0, 1.0, 3.0, 3.0, 3.0), 1),
    (Aabb3::new(100.0, 100.0, 100.0, 102.0, 102.0, 102.0), 2),
  ]
  match BVHNode::build(leaves) {
    Some(root) => {
      let query = Aabb3::new(0.0, 0.0, 0.0, 5.0, 5.0, 5.0)
      let result = []
      root.query_intersect(query, result)
      let has0 = result.contains(0)
      let has1 = result.contains(1)
      let has2 = result.contains(2)
      assert_true(has0)
      assert_true(has1)
      assert_false(has2)
    }
    None => assert_true(false)
  }
}
