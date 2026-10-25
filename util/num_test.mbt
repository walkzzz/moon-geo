// util/num 黑盒测试
// Double 为内置类型，trait impl 不导出到黑盒；用内置方法 + 导出自由函数测试

///|
test "constants" {
  assert_true(@util.EPS > 0.0)
  assert_true(@util.MIN_POSITIVE > 0.0)
  assert_true(@util.EPS > @util.MIN_POSITIVE)
}

///|
test "Double builtin clamp" {
  assert_eq(5.0.clamp(min=1.0, max=4.0), 4.0)
  assert_eq(0.0.clamp(min=1.0, max=4.0), 1.0)
  assert_eq(2.0.clamp(min=1.0, max=4.0), 2.0)
}

///|
test "Double builtin lerp" {
  assert_true(@util.dbl_approx_eq(0.0.lerp(target=10.0, t=0.5), 5.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(0.0.lerp(target=10.0, t=0.0), 0.0, @util.EPS))
  assert_true(
    @util.dbl_approx_eq(0.0.lerp(target=10.0, t=1.0), 10.0, @util.EPS),
  )
}

///|
test "Double builtin abs" {
  let n = -3.0
  assert_eq(n.abs(), 3.0)
  assert_eq(3.0.abs(), 3.0)
}

///|
test "dbl_approx_eq / dbl_approx_zero" {
  assert_true(@util.dbl_approx_eq(1.0, 1.0 + 1.0e-10, 1.0e-8))
  assert_false(@util.dbl_approx_eq(1.0, 1.1, 1.0e-8))
  assert_true(@util.dbl_approx_zero(1.0e-10, 1.0e-8))
  assert_false(@util.dbl_approx_zero(0.1, 1.0e-8))
}
