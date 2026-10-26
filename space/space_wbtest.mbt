// space 白盒测试：Euclid2 实现 Space Trait
// 白盒测试：本包类型直接引用（无 @space 前缀），能看到 impl

///|
test "Euclid2 dim" {
  let p = Euclid2::new(1.0, 2.0)
  assert_eq(@atop.Dim::dim(p), 2)
}

///|
test "Euclid2 distance" {
  let a = Euclid2::new(0.0, 0.0)
  let b = Euclid2::new(3.0, 4.0)
  let d = @atop.MetricSpace::distance(a, b)
  assert_true(@util.dbl_approx_eq(d, 5.0, @util.EPS))
  let d2 = @atop.MetricSpace::distance(b, a)
  assert_true(@util.dbl_approx_eq(d, d2, @util.EPS))
  assert_true(
    @util.dbl_approx_eq(@atop.MetricSpace::distance(a, a), 0.0, @util.EPS),
  )
}

///|
test "Euclid2 neighborhood" {
  let center = Euclid2::new(0.0, 0.0)
  let inside = Euclid2::new(0.5, 0.0)
  let outside = Euclid2::new(2.0, 0.0)
  assert_true(@atop.TopologicalSpace::is_in_neighborhood(inside, center, 1.0))
  assert_false(@atop.TopologicalSpace::is_in_neighborhood(outside, center, 1.0))
}

///|
test "Euclid2 space_kind" {
  let p = Euclid2::new(1.0, 1.0)
  assert_true(Space::space_kind(p) is SpaceKind::Euclidean2)
}

///|
test "Euclid2 triangle inequality" {
  let a = Euclid2::new(0.0, 0.0)
  let b = Euclid2::new(1.0, 0.0)
  let c = Euclid2::new(1.0, 1.0)
  let d_ab = @atop.MetricSpace::distance(a, b)
  let d_bc = @atop.MetricSpace::distance(b, c)
  let d_ac = @atop.MetricSpace::distance(a, c)
  assert_true(d_ac <= d_ab + d_bc + @util.EPS)
}

///|
test "Euclid2 coords" {
  let p = Euclid2::new(3.0, 5.0)
  assert_true(@util.dbl_approx_eq(p.x(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(p.y(), 5.0, @util.EPS))
}

///|
test "FREEZE: Space Trait interface stability" {
  let p2 = Euclid2::new(1.0, 2.0)
  let p3 = Euclid3::new(1.0, 2.0, 3.0)
  // Space Trait 自身方法
  let _ = Space::space_kind(p2)
  let _ = Space::space_kind(p3)
  // 继承的 MetricSpace + Dim + TopologicalSpace 方法
  let _ = @atop.MetricSpace::distance(p2, Euclid2::new(0.0, 0.0))
  let _ = @atop.Dim::dim(p2)
  let _ = @atop.MetricSpace::distance(p3, Euclid3::new(0.0, 0.0, 0.0))
  let _ = @atop.Dim::dim(p3)
  // pub extend 点语法
  let _ = p2.space_kind()
  let _ = p3.space_kind()
}

///|
test "Complex2 construction" {
  let z = Complex2::new(3.0, 4.0)
  assert_true(@util.dbl_approx_eq(z.re(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(z.im(), 4.0, @util.EPS))
}

///|
test "Complex2 from_real" {
  let z = Complex2::from_real(5.0)
  assert_true(@util.dbl_approx_eq(z.re(), 5.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(z.im(), 0.0, @util.EPS))
}

///|
test "Complex2 conj" {
  let z = Complex2::new(3.0, 4.0)
  let zc = z.conj()
  assert_true(@util.dbl_approx_eq(zc.re(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(zc.im(), -4.0, @util.EPS))
}

///|
test "Complex2 modulus" {
  let z = Complex2::new(3.0, 4.0)
  assert_true(@util.dbl_approx_eq(z.modulus(), 5.0, @util.EPS))
}

///|
test "Complex2 norm_sq" {
  let z = Complex2::new(3.0, 4.0)
  assert_true(@util.dbl_approx_eq(z.norm_sq(), 25.0, @util.EPS))
}

///|
test "Complex2 argument" {
  let z = Complex2::new(1.0, 1.0)
  // arg(1+i) = pi/4
  assert_true(@util.dbl_approx_eq(z.argument(), 0.7853981633974483, 1.0e-10))
}

///|
test "Complex2 add" {
  let z1 = Complex2::new(1.0, 2.0)
  let z2 = Complex2::new(3.0, 4.0)
  let z = z1.add(z2)
  assert_true(@util.dbl_approx_eq(z.re(), 4.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(z.im(), 6.0, @util.EPS))
}

///|
test "Complex2 sub" {
  let z1 = Complex2::new(3.0, 4.0)
  let z2 = Complex2::new(1.0, 2.0)
  let z = z1.sub(z2)
  assert_true(@util.dbl_approx_eq(z.re(), 2.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(z.im(), 2.0, @util.EPS))
}

///|
test "Complex2 mul" {
  let z1 = Complex2::new(1.0, 2.0)
  let z2 = Complex2::new(3.0, 4.0)
  // (1+2i)(3+4i) = 3+4i+6i+8i^2 = 3-8 + 10i = -5+10i
  let z = z1.mul(z2)
  assert_true(@util.dbl_approx_eq(z.re(), -5.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(z.im(), 10.0, @util.EPS))
}

///|
test "Complex2 scale" {
  let z = Complex2::new(3.0, 4.0)
  let zs = z.scale(2.0)
  assert_true(@util.dbl_approx_eq(zs.re(), 6.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(zs.im(), 8.0, @util.EPS))
}

///|
test "Complex2 rotate" {
  let z = Complex2::new(1.0, 0.0)
  // 旋转 pi/2 → (0, 1)
  let zr = z.rotate(1.5707963267948966)
  assert_true(@util.dbl_approx_eq(zr.re(), 0.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(zr.im(), 1.0, 1.0e-10))
}

///|
test "Complex2 Space dim" {
  let z = Complex2::new(1.0, 2.0)
  assert_eq(@atop.Dim::dim(z), 2)
}

///|
test "Complex2 Space distance" {
  let z1 = Complex2::new(0.0, 0.0)
  let z2 = Complex2::new(3.0, 4.0)
  assert_true(
    @util.dbl_approx_eq(@atop.MetricSpace::distance(z1, z2), 5.0, @util.EPS),
  )
}

///|
test "Complex2 Space space_kind" {
  let z = Complex2::new(1.0, 2.0)
  assert_true(Space::space_kind(z) is SpaceKind::Complex2)
  assert_true(z.space_kind() is SpaceKind::Complex2)
}

///|
test "Complex2 from/to Cpx" {
  let c = @util.Cpx::new(3.0, 4.0)
  let z = Complex2::from_cpx(c)
  assert_true(@util.dbl_approx_eq(z.re(), 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(z.im(), 4.0, @util.EPS))
  let c2 = z.to_cpx()
  assert_true(@util.dbl_approx_eq(c2.re, 3.0, @util.EPS))
  assert_true(@util.dbl_approx_eq(c2.im, 4.0, @util.EPS))
}

///|
test "E2E: Complex2 arithmetic -> modulus consistency" {
  let z1 = Complex2::new(1.0, 2.0)
  let z2 = Complex2::new(3.0, 4.0)
  let z = z1.mul(z2)
  // |z1*z2| = |z1| * |z2|
  let expected = z1.modulus() * z2.modulus()
  assert_true(@util.dbl_approx_eq(z.modulus(), expected, 1.0e-10))
}

///|
test "FAKE: Complex2 field completeness" {
  let z = Complex2::new(1.0, 2.0)
  let _ = z.re()
  let _ = z.im()
  let _ = z.conj()
  let _ = z.modulus()
  let _ = z.norm_sq()
  let _ = z.argument()
  let _ = z.add(z)
  let _ = z.sub(z)
  let _ = z.mul(z)
  let _ = z.scale(2.0)
  let _ = z.rotate(1.0)
  let _ = z.to_cpx()
  let _ = @atop.Dim::dim(z)
  let _ = @atop.MetricSpace::distance(z, z)
  let _ = Space::space_kind(z)
}
