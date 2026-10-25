// util/quat 黑盒测试

///|
test "Quat identity" {
  let q = @util.Quat::identity()
  assert_true(@util.dbl_approx_eq(q.norm(), 1.0, @util.EPS))
  assert_eq(q.w, 1.0)
}

///|
test "Quat from_axis_angle" {
  // 绕 Z 轴旋转 90 度
  let q = @util.Quat::from_axis_angle(
    @util.Vec3::new(0.0, 0.0, 1.0),
    1.5707963267948966,
  )
  assert_true(@util.dbl_approx_eq(q.norm(), 1.0, @util.EPS))
  // w = cos(45°) ≈ 0.7071
  assert_true(@util.dbl_approx_eq(q.w, 0.7071067811865476, 1.0e-8))
}

///|
test "Quat mul identity" {
  let q = @util.Quat::new(0.5, 0.5, 0.5, 0.5)
  let r = @util.Quat::identity().mul(q)
  assert_true(r.approx_eq(q, @util.EPS))
}

///|
test "Quat conjugate" {
  let q = @util.Quat::from_axis_angle(@util.Vec3::new(0.0, 0.0, 1.0), 0.5)
  let n = q.normalize()
  // q * conj(q) ≈ identity（单位四元数）
  let prod = n.mul(n.conjugate())
  assert_true(prod.approx_eq(@util.Quat::identity(), 1.0e-8))
}

///|
test "Quat to_mat4 identity" {
  let q = @util.Quat::identity()
  let m = q.to_mat4()
  assert_true(m.approx_eq(@util.Mat4::identity(), @util.EPS))
}

///|
test "Quat slerp endpoints" {
  let q1 = @util.Quat::identity()
  let q2 = @util.Quat::from_axis_angle(
    @util.Vec3::new(0.0, 0.0, 1.0),
    1.5707963267948966,
  )
  // t=0 返回 q1
  let r0 = q1.slerp(q2, 0.0)
  assert_true(r0.approx_eq(q1, 1.0e-8))
  // t=1 返回 q2
  let r1 = q1.slerp(q2, 1.0)
  assert_true(r1.approx_eq(q2, 1.0e-8))
}

///|
test "Quat from_euler zero" {
  let q = @util.Quat::from_euler(0.0, 0.0, 0.0)
  assert_true(q.approx_eq(@util.Quat::identity(), @util.EPS))
}
