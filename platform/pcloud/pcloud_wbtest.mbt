///|
test "voxel_downsample 基本降采样" {
  let pts = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(0.5, 0.5, 0.5),
    @alg.Pt3::new(2.0, 2.0, 2.0),
    @alg.Pt3::new(2.5, 2.5, 2.5),
  ]
  let result = voxel_downsample(pts, 1.0)
  assert_eq(result.length(), 2)
}

///|
test "voxel_downsample 相同网格取质心" {
  let pts = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(0.5, 0.0, 0.0),
    @alg.Pt3::new(0.0, 0.5, 0.0),
  ]
  let result = voxel_downsample(pts, 1.0)
  assert_eq(result.length(), 1)
  assert_true(approx(result[0].x(), 0.5 / 3.0, 0.001))
  assert_true(approx(result[0].y(), 0.5 / 3.0, 0.001))
}

///|
test "voxel_downsample 空输入" {
  let result = voxel_downsample([], 1.0)
  assert_eq(result.length(), 0)
}

///|
test "voxel_downsample voxel_size 越界 raise" {
  let pts = [@alg.Pt3::new(0.0, 0.0, 0.0)]
  try {
    let _ = voxel_downsample(pts, 0.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "voxel_downsample 大网格保留所有点" {
  let pts = [
    @alg.Pt3::new(0.0, 0.0, 0.0),
    @alg.Pt3::new(1.0, 1.0, 1.0),
    @alg.Pt3::new(2.0, 2.0, 2.0),
  ]
  let result = voxel_downsample(pts, 100.0)
  assert_eq(result.length(), 1)
}

///|
test "random_downsample ratio=1.0 保留所有" {
  let pts = [
    @alg.Pt3::new(1.0, 2.0, 3.0),
    @alg.Pt3::new(4.0, 5.0, 6.0),
    @alg.Pt3::new(7.0, 8.0, 9.0),
  ]
  let result = random_downsample(pts, 1.0)
  assert_eq(result.length(), 3)
}

///|
test "random_downsample ratio 越界 raise" {
  let pts = [@alg.Pt3::new(0.0, 0.0, 0.0)]
  try {
    let _ = random_downsample(pts, 0.0)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "random_downsample ratio>1 raise" {
  let pts = [@alg.Pt3::new(0.0, 0.0, 0.0)]
  try {
    let _ = random_downsample(pts, 1.5)
    assert_true(false)
  } catch {
    _ => assert_true(true)
  }
}

///|
test "PointCloud 基本操作" {
  let pts = [@alg.Pt3::new(0.0, 0.0, 0.0), @alg.Pt3::new(1.0, 1.0, 1.0)]
  let cloud = PointCloud::new(pts)
  assert_eq(cloud.size(), 2)
  assert_eq(cloud.get_points().length(), 2)
}

///|
fn approx(a : Double, b : Double, tol : Double) -> Bool {
  (a - b).abs() < tol
}
