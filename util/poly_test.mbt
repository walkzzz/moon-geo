// util/poly 黑盒测试

///|
test "Poly1 construct and degree" {
  let p = @util.Poly1::new([1.0, 2.0, 3.0]) // 1 + 2x + 3x^2
  assert_eq(p.degree(), 2)
  let c = @util.Poly1::constant(5.0)
  assert_eq(c.degree(), 0)
  let z = @util.Poly1::zero()
  assert_eq(z.degree(), -1)
}

///|
test "Poly1 eval" {
  let p = @util.Poly1::new([1.0, 2.0, 3.0]) // 1 + 2x + 3x^2
  // p(0) = 1
  assert_true(@util.dbl_approx_eq(p.eval(0.0), 1.0, @util.EPS))
  // p(1) = 1 + 2 + 3 = 6
  assert_true(@util.dbl_approx_eq(p.eval(1.0), 6.0, @util.EPS))
  // p(2) = 1 + 4 + 12 = 17
  assert_true(@util.dbl_approx_eq(p.eval(2.0), 17.0, @util.EPS))
  // p(-1) = 1 - 2 + 3 = 2
  assert_true(@util.dbl_approx_eq(p.eval(-1.0), 2.0, @util.EPS))
  // 零多项式
  assert_true(
    @util.dbl_approx_eq(@util.Poly1::zero().eval(42.0), 0.0, @util.EPS),
  )
}

///|
test "Poly1 add" {
  let a = @util.Poly1::new([1.0, 2.0, 3.0]) // 1 + 2x + 3x^2
  let b = @util.Poly1::new([4.0, 5.0]) // 4 + 5x
  let s = a.add(b) // 5 + 7x + 3x^2
  assert_true(@util.dbl_approx_eq(s.eval(1.0), 15.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(s.eval(2.0), 31.0, @util.EPS))
}

///|
test "Poly1 sub" {
  let a = @util.Poly1::new([5.0, 7.0, 3.0]) // 5 + 7x + 3x^2
  let b = @util.Poly1::new([4.0, 5.0]) // 4 + 5x
  let d = a.sub(b) // 1 + 2x + 3x^2
  assert_true(@util.dbl_approx_eq(d.eval(0.0), 1.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(d.eval(1.0), 6.0, @util.EPS))
}

///|
test "Poly1 mul" {
  let a = @util.Poly1::new([1.0, 1.0]) // 1 + x
  let b = @util.Poly1::new([1.0, -1.0]) // 1 - x
  let p = a.mul(b) // 1 - x^2
  assert_eq(p.degree(), 2)
  // p(0) = 1
  assert_true(@util.dbl_approx_eq(p.eval(0.0), 1.0, @util.EPS))
  // p(1) = 0
  assert_true(@util.dbl_approx_eq(p.eval(1.0), 0.0, @util.EPS))
  // p(2) = 1 - 4 = -3
  assert_true(@util.dbl_approx_eq(p.eval(2.0), -3.0, @util.EPS))
  // 乘零多项式
  let z = a.mul(@util.Poly1::zero())
  assert_true(z.is_zero())
}

///|
test "Poly1 scale" {
  let p = @util.Poly1::new([1.0, 2.0, 3.0])
  let s = p.scale(2.0) // 2 + 4x + 6x^2
  assert_true(@util.dbl_approx_eq(s.eval(1.0), 12.0, @util.EPS))
}

///|
test "Poly1 derivative" {
  // p = 1 + 2x + 3x^2 → p' = 2 + 6x
  let p = @util.Poly1::new([1.0, 2.0, 3.0])
  let dp = p.derivative()
  assert_eq(dp.degree(), 1)
  // p'(0) = 2
  assert_true(@util.dbl_approx_eq(dp.eval(0.0), 2.0, @util.EPS))
  // p'(1) = 8
  assert_true(@util.dbl_approx_eq(dp.eval(1.0), 8.0, @util.EPS))
  // 常数求导 = 0
  let c = @util.Poly1::constant(5.0)
  assert_true(c.derivative().is_zero())
  // 零多项式求导 = 0
  assert_true(@util.Poly1::zero().derivative().is_zero())
}

///|
test "Poly1 is_zero" {
  assert_true(@util.Poly1::zero().is_zero())
  assert_false(@util.Poly1::constant(1.0).is_zero())
  // 系数全为零
  assert_true(@util.Poly1::new([0.0, 0.0, 0.0]).is_zero())
}

///|
test "Poly1 ApproxEq" {
  let a = @util.Poly1::new([1.0, 2.0, 3.0])
  let b = @util.Poly1::new([1.0 + 1.0e-10, 2.0, 3.0])
  assert_true(a.approx_eq(b, 1.0e-8))
  let c = @util.Poly1::new([1.1, 2.0, 3.0])
  assert_false(a.approx_eq(c, 1.0e-8))
  // 不同长度比较（高位补零）
  let d = @util.Poly1::new([1.0, 2.0, 3.0, 0.0])
  assert_true(a.approx_eq(d, @util.EPS))
}

///|
test "PolyN eval" {
  // f(x,y) = 2*x^2*y + 3*x*y^2
  let f = @util.PolyN::new([
    @util.PolyTerm::new(2.0, [2, 1]),
    @util.PolyTerm::new(3.0, [1, 2]),
  ])
  // f(1,1) = 2 + 3 = 5
  assert_true(@util.dbl_approx_eq(f.eval([1.0, 1.0]), 5.0, @util.EPS))
  // f(2,3) = 2*4*3 + 3*2*9 = 24 + 54 = 78
  assert_true(@util.dbl_approx_eq(f.eval([2.0, 3.0]), 78.0, @util.EPS))
  // f(0,0) = 0
  assert_true(@util.dbl_approx_eq(f.eval([0.0, 0.0]), 0.0, @util.EPS))
}

///|
test "PolyN add" {
  let f = @util.PolyN::new([@util.PolyTerm::new(2.0, [2, 1])])
  let g = @util.PolyN::new([@util.PolyTerm::new(3.0, [1, 2])])
  let s = f.add(g)
  // s(1,1) = 2 + 3 = 5
  assert_true(@util.dbl_approx_eq(s.eval([1.0, 1.0]), 5.0, @util.EPS))
}

///|
test "PolyN scale" {
  let f = @util.PolyN::new([@util.PolyTerm::new(2.0, [2, 1])])
  let s = f.scale(3.0)
  // s(1,1) = 6
  assert_true(@util.dbl_approx_eq(s.eval([1.0, 1.0]), 6.0, @util.EPS))
}

///|
test "PolyN is_zero" {
  assert_true(@util.PolyN::zero().is_zero())
  assert_false(@util.PolyN::new([@util.PolyTerm::new(1.0, [1])]).is_zero())
  assert_true(@util.PolyN::new([@util.PolyTerm::new(0.0, [1])]).is_zero())
}

///|
test "PolyN ApproxEq" {
  let a = @util.PolyN::new([@util.PolyTerm::new(2.0, [2, 1])])
  let b = @util.PolyN::new([@util.PolyTerm::new(2.0 + 1.0e-10, [2, 1])])
  assert_true(a.approx_eq(b, 1.0e-8))
  let c = @util.PolyN::new([@util.PolyTerm::new(3.0, [2, 1])])
  assert_false(a.approx_eq(c, 1.0e-8))
}
