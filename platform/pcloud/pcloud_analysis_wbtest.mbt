///|
test "bounding_box 基本" {
  let pts = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 2.0, 3.0),
    @alg.Pt3::new(-1.0, 0.5, 4.0),
  ]
  let (bmin, bmax) = bounding_box(pts)
  assert_true(approx(bmin.x(), -1.0, 0.001))
  assert_true(approx(bmin.y(), 0.0, 0.001))
  assert_true(approx(bmin.z(), 0.0, 0.001))
  assert_true(approx(bmax.x(), 1.0, 0.001))
  assert_true(approx(bmax.y(), 2.0, 0.001))
  assert_true(approx(bmax.z(), 4.0, 0.001))
}

///|
test "bounding_box 空输入 raise" {
  try {
    let _ = bounding_box([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "centroid 基本" {
  let pts = [@alg.Pt3::new(0.0, 0.0, 0.0), @alg.Pt3::new(2.0, 4.0, 6.0)]
  let c = centroid(pts)
  assert_true(approx(c.x(), 1.0, 0.001))
  assert_true(approx(c.y(), 2.0, 0.001))
  assert_true(approx(c.z(), 3.0, 0.001))
}

///|
test "centroid 空输入 raise" {
  try {
    let _ = centroid([])
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "density 立方体" {
  let pts = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(0.0, 1.0, 0.0),
    @alg.Pt3::new(1.0, 1.0, 0.0),
    @alg.Pt3::new(0.0, 0.0, 1.0),
    @alg.Pt3::new(1.0, 0.0, 1.0),
    @alg.Pt3::new(0.0, 1.0, 1.0),
    @alg.Pt3::new(1.0, 1.0, 1.0),
  ]
  let d = density(pts)
  assert_true(approx(d, 8.0, 0.001))
}

///|
test "density 共面 raise" {
  let pts = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(0.0, 1.0, 0.0),
  ]
  try {
    let _ = density(pts)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "estimate_normals 平面 z=0" {
  let pts = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 0.0, 0.0),
    @alg.Pt3::new(0.0, 1.0, 0.0),
    @alg.Pt3::new(1.0, 1.0, 0.0),
    @alg.Pt3::new(2.0, 0.0, 0.0),
    @alg.Pt3::new(0.0, 2.0, 0.0),
  ]
  let normals = estimate_normals(pts, 4)
  assert_eq(normals.length(), 6)
  let n0 = normals[0]
  let norm_len = (n0.x() * n0.x() + n0.y() * n0.y() + n0.z() * n0.z()).sqrt()
  assert_true(approx(norm_len, 1.0, 0.01))
  assert_true(n0.z().abs() > 0.9)
}

///|
test "estimate_normals k<3 raise" {
  let pts = [@alg.Pt3::new(0.0, 0.0, 0.0)]
  try {
    let _ = estimate_normals(pts, 2)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}
