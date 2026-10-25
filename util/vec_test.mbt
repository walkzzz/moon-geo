// util/vec 黑盒测试

///|
test "Vec2 basic" {
  let v = @util.Vec2::new(3.0, 4.0)
  assert_eq(v.x, 3.0)
  assert_eq(v.y, 4.0)
  assert_true(@util.dbl_approx_eq(v.len_sq(), 25.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(v.len(), 5.0, @util.EPS))
}

///|
test "Vec2 dot cross" {
  let a = @util.Vec2::new(1.0, 2.0)
  let b = @util.Vec2::new(3.0, 4.0)
  assert_true(@util.dbl_approx_eq(a.dot(b), 11.0, @util.EPS))
  // (1,0) × (0,1) = 1
  assert_true(
    @util.dbl_approx_eq(
      @util.Vec2::new(1.0, 0.0).cross(@util.Vec2::new(0.0, 1.0)),
      1.0,
      @util.EPS,
    ),
  )
}

///|
test "Vec2 normalize" {
  let v = @util.Vec2::new(3.0, 4.0)
  let n = v.normalize()
  assert_true(@util.dbl_approx_eq(n.len(), 1.0, @util.EPS))
}

///|
test "Vec2 add sub scale" {
  let a = @util.Vec2::new(1.0, 2.0)
  let b = @util.Vec2::new(3.0, 4.0)
  let s = a.add(b)
  assert_true(s.approx_eq(@util.Vec2::new(4.0, 6.0), @util.EPS))
  let d = a.sub(b)
  assert_true(d.approx_eq(@util.Vec2::new(-2.0, -2.0), @util.EPS))
  let sc = a.scale(2.0)
  assert_true(sc.approx_eq(@util.Vec2::new(2.0, 4.0), @util.EPS))
}

///|
test "Vec3 basic" {
  let v = @util.Vec3::new(1.0, 2.0, 2.0)
  assert_true(@util.dbl_approx_eq(v.len_sq(), 9.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(v.len(), 3.0, @util.EPS))
}

///|
test "Vec3 dot" {
  let a = @util.Vec3::new(1.0, 2.0, 3.0)
  let b = @util.Vec3::new(4.0, 5.0, 6.0)
  assert_true(@util.dbl_approx_eq(a.dot(b), 32.0, @util.EPS))
}

///|
test "Vec3 cross" {
  // (1,0,0) × (0,1,0) = (0,0,1)
  let r = @util.Vec3::new(1.0, 0.0, 0.0).cross(@util.Vec3::new(0.0, 1.0, 0.0))
  assert_true(r.approx_eq(@util.Vec3::new(0.0, 0.0, 1.0), @util.EPS))
}

///|
test "Vec3 normalize" {
  let v = @util.Vec3::new(0.0, 3.0, 4.0)
  let n = v.normalize()
  assert_true(@util.dbl_approx_eq(n.len(), 1.0, @util.EPS))
}
