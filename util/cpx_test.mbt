// util/cpx 黑盒测试
// Cpx trait 方法已 extend 提升并导出，用位置参数调用
// Double 结果比较用 @util.dbl_approx_eq 自由函数

///|
test "Cpx construct" {
  let c = @util.Cpx::new(3.0, 4.0)
  assert_eq(c.re, 3.0)
  assert_eq(c.im, 4.0)
  let r = @util.Cpx::from_real(5.0)
  assert_eq(r.re, 5.0)
  assert_eq(r.im, 0.0)
}

///|
test "Cpx conj" {
  let c = @util.Cpx::new(3.0, 4.0)
  let cj = c.conj()
  assert_eq(cj.re, 3.0)
  assert_eq(cj.im, -4.0)
}

///|
test "Cpx norm" {
  let c = @util.Cpx::new(3.0, 4.0)
  assert_eq(c.norm_sq(), 25.0)
  assert_true(@util.dbl_approx_eq(c.norm(), 5.0, @util.EPS))
}

///|
test "Cpx add sub" {
  let a = @util.Cpx::new(1.0, 2.0)
  let b = @util.Cpx::new(3.0, 4.0)
  let s = a.add(b)
  assert_eq(s.re, 4.0)
  assert_eq(s.im, 6.0)
  let d = a.sub(b)
  assert_eq(d.re, -2.0)
  assert_eq(d.im, -2.0)
}

///|
test "Cpx mul" {
  let a = @util.Cpx::new(1.0, 2.0)
  let b = @util.Cpx::new(3.0, 4.0)
  // (1+2i)(3+4i) = -5+10i
  let p = a.mul(b)
  assert_eq(p.re, -5.0)
  assert_eq(p.im, 10.0)
}

///|
test "Cpx div" {
  let a = @util.Cpx::new(1.0, 2.0)
  let b = @util.Cpx::new(3.0, 4.0)
  // (1+2i)/(3+4i) = (11+2i)/25
  let q = a.div(b)
  assert_true(@util.dbl_approx_eq(q.re, 11.0 / 25.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(q.im, 2.0 / 25.0, @util.EPS))
}

///|
test "Cpx inv" {
  let c = @util.Cpx::new(1.0, 1.0)
  // 1/(1+i) = (1-i)/2
  let inv = c.inv()
  assert_true(@util.dbl_approx_eq(inv.re, 0.5, @util.EPS))
  assert_true(@util.dbl_approx_eq(inv.im, -0.5, @util.EPS))
}

///|
test "Cpx neg" {
  let c = @util.Cpx::new(3.0, 4.0)
  let n = c.neg()
  assert_eq(n.re, -3.0)
  assert_eq(n.im, -4.0)
}

///|
test "Cpx ApproxEq" {
  let a = @util.Cpx::new(1.0, 2.0)
  let b = @util.Cpx::new(1.0 + 1.0e-10, 2.0 + 1.0e-10)
  assert_true(a.approx_eq(b, 1.0e-8))
  let c = @util.Cpx::new(1.1, 2.0)
  assert_false(a.approx_eq(c, 1.0e-8))
  assert_true(@util.Cpx::new(1.0e-10, 1.0e-10).approx_zero(1.0e-8))
}

///|
test "Cpx Field" {
  let z = @util.Cpx::zero()
  assert_eq(z.re, 0.0)
  assert_eq(z.im, 0.0)
  let o = @util.Cpx::one()
  assert_eq(o.re, 1.0)
  assert_eq(o.im, 0.0)
  let c = @util.Cpx::new(3.0, 4.0)
  assert_true(@util.dbl_approx_eq(c.abs(), 5.0, @util.EPS))
}

///|
test "Cpx NumExt sq" {
  // (1+2i)^2 = 1 + 4i + 4i^2 = -3 + 4i
  let c = @util.Cpx::new(1.0, 2.0)
  let s = c.sq()
  assert_true(@util.dbl_approx_eq(s.re, -3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(s.im, 4.0, @util.EPS))
  // sq == mul(self)
  let m = c.mul(c)
  assert_true(@util.dbl_approx_eq(s.re, m.re, @util.EPS))
  assert_true(@util.dbl_approx_eq(s.im, m.im, @util.EPS))
}

///|
test "Cpx NumExt clamp" {
  // 按分量 clamp
  let c = @util.Cpx::new(5.0, 0.0)
  let lo = @util.Cpx::new(1.0, 1.0)
  let hi = @util.Cpx::new(4.0, 4.0)
  let r = c.clamp(lo, hi)
  assert_eq(r.re, 4.0)
  assert_eq(r.im, 1.0)
  // 已在范围内不变
  let c2 = @util.Cpx::new(2.0, 3.0)
  let r2 = c2.clamp(lo, hi)
  assert_eq(r2.re, 2.0)
  assert_eq(r2.im, 3.0)
}

///|
test "Cpx NumExt lerp" {
  // 按分量插值
  let a = @util.Cpx::new(0.0, 0.0)
  let b = @util.Cpx::new(10.0, 20.0)
  let m = a.lerp(b, 0.5)
  assert_true(@util.dbl_approx_eq(m.re, 5.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(m.im, 10.0, @util.EPS))
  // t=0 返回 a
  let r0 = a.lerp(b, 0.0)
  assert_true(@util.dbl_approx_eq(r0.re, 0.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r0.im, 0.0, @util.EPS))
  // t=1 返回 b
  let r1 = a.lerp(b, 1.0)
  assert_true(@util.dbl_approx_eq(r1.re, 10.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(r1.im, 20.0, @util.EPS))
}

///|
test "Cpx inv zero raises ZeroInverse" {
  try @util.Cpx::new(0.0, 0.0).inv() catch {
    _ => ()
  } noraise {
    _ => fail("expected inv to fail on zero")
  }
}

///|
test "Cpx div by zero raises ZeroDivide" {
  let a = @util.Cpx::new(1.0, 1.0)
  try a.div(@util.Cpx::new(0.0, 0.0)) catch {
    _ => ()
  } noraise {
    _ => fail("expected div by zero to fail")
  }
}
