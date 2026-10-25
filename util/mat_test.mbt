// util/mat 黑盒测试

///|
test "Mat3 identity" {
  let id = @util.Mat3::identity()
  assert_true(@util.dbl_approx_eq(id.det(), 1.0, @util.EPS))
  let v = @util.Vec3::new(1.0, 2.0, 3.0)
  let r = id.mul_vec(v)
  assert_true(r.approx_eq(v, @util.EPS))
}

///|
test "Mat3 det" {
  // [2 0 0; 0 3 0; 0 0 4] det = 24
  let m = @util.Mat3::new(2.0, 0.0, 0.0, 0.0, 3.0, 0.0, 0.0, 0.0, 4.0)
  assert_true(@util.dbl_approx_eq(m.det(), 24.0, @util.EPS))
}

///|
test "Mat3 inv" {
  let m = @util.Mat3::new(2.0, 0.0, 0.0, 0.0, 4.0, 0.0, 0.0, 0.0, 8.0)
  let inv = m.inv()
  let prod = m.mul_mat(inv)
  assert_true(prod.approx_eq(@util.Mat3::identity(), @util.EPS))
}

///|
test "Mat3 transpose" {
  let m = @util.Mat3::new(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  let t = m.transpose()
  // t[0][1] == m[1][0] == 4
  assert_true(@util.dbl_approx_eq(t.get(0, 1), 4.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(t.get(1, 0), 2.0, @util.EPS))
}

///|
test "Mat3 mul_vec" {
  // [1 2 3; 4 5 6; 7 8 9] * (1,1,1) = (6,15,24)
  let m = @util.Mat3::new(1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0)
  let r = m.mul_vec(@util.Vec3::new(1.0, 1.0, 1.0))
  assert_true(r.approx_eq(@util.Vec3::new(6.0, 15.0, 24.0), @util.EPS))
}

///|
test "Mat4 identity mul_vec" {
  let id = @util.Mat4::identity()
  let v = @util.Vec3::new(1.0, 2.0, 3.0)
  let r = id.mul_vec(v)
  assert_true(r.approx_eq(v, @util.EPS))
}

///|
test "Mat4 translation" {
  let t = @util.Mat4::translation(10.0, 20.0, 30.0)
  let r = t.mul_vec(@util.Vec3::new(0.0, 0.0, 0.0))
  assert_true(r.approx_eq(@util.Vec3::new(10.0, 20.0, 30.0), @util.EPS))
}

///|
test "Mat4 scaling" {
  let s = @util.Mat4::scaling(2.0, 3.0, 4.0)
  let r = s.mul_vec(@util.Vec3::new(1.0, 1.0, 1.0))
  assert_true(r.approx_eq(@util.Vec3::new(2.0, 3.0, 4.0), @util.EPS))
}

///|
test "Mat4 mul_mat identity" {
  let id = @util.Mat4::identity()
  let t = @util.Mat4::translation(1.0, 2.0, 3.0)
  let p = id.mul_mat(t)
  assert_true(p.approx_eq(t, @util.EPS))
}
