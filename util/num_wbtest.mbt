// 白盒测试：Double 的 trait impl（foreign type impl 仅包内可见）

///|
test "wb: Double ApproxEq" {
  assert_true(ApproxEq::approx_eq(1.0, 1.0 + 1.0e-10, 1.0e-8))
  assert_false(ApproxEq::approx_eq(1.0, 1.1, 1.0e-8))
  assert_true(ApproxEq::approx_zero(1.0e-10, 1.0e-8))
  assert_false(ApproxEq::approx_zero(0.1, 1.0e-8))
}

///|
test "wb: Double NumExt" {
  assert_eq(NumExt::sq(3.0), 9.0)
  assert_eq(NumExt::sq(-2.0), 4.0)
  assert_eq(NumExt::clamp(5.0, 1.0, 4.0), 4.0)
  assert_eq(NumExt::clamp(0.0, 1.0, 4.0), 1.0)
  assert_eq(NumExt::clamp(2.0, 1.0, 4.0), 2.0)
  assert_true(ApproxEq::approx_eq(NumExt::lerp(0.0, 10.0, 0.5), 5.0, EPS))
}

///|
test "wb: Double Field" {
  assert_eq(Field::zero(), 0.0)
  assert_eq(Field::one(), 1.0)
  assert_eq(Field::abs(-3.0), 3.0)
  assert_eq(Field::abs(3.0), 3.0)
}
