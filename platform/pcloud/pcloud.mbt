// 点云降采样
// platform/pcloud，依赖 util（GeoError）、alg（Pt3）

///|
/// 点云：3D 点集
pub struct PointCloud {
  points : Array[@alg.Pt3]
}

///|
/// 构造点云
pub fn PointCloud::new(points : Array[@alg.Pt3]) -> PointCloud {
  { points, }
}

///|
/// 点数量
pub fn PointCloud::size(self : PointCloud) -> Int32 {
  self.points.length()
}

///|
/// 获取所有点
pub fn PointCloud::get_points(self : PointCloud) -> Array[@alg.Pt3] {
  self.points
}

///|
/// 网格降采样：将空间划分为 voxel_size 网格，每个网格取质心
/// 时间复杂度 O(n log n)（排序主导），空间 O(n)
pub fn voxel_downsample(
  points : Array[@alg.Pt3],
  voxel_size : Double,
) -> Array[@alg.Pt3] raise @util.GeoError {
  if voxel_size <= 0.0 {
    raise @util.GeoError::DegenerateInput("voxel_size 必须为正数", [])
  }
  let n = points.length()
  if n == 0 {
    return []
  }
  let keyed : Array[(String, @alg.Pt3)] = []
  for i in 0..<n {
    let p = points[i]
    let gx = (p.x() / voxel_size).floor().to_int()
    let gy = (p.y() / voxel_size).floor().to_int()
    let gz = (p.z() / voxel_size).floor().to_int()
    let key = "\{gx},\{gy},\{gz}"
    keyed.push((key, p))
  }
  keyed.sort_by(fn(a, b) { a.0.compare(b.0) })
  let result : Array[@alg.Pt3] = []
  let mut i = 0
  while i < n {
    let key = keyed[i].0
    let mut sum_x = 0.0
    let mut sum_y = 0.0
    let mut sum_z = 0.0
    let mut count = 0
    while i < n && keyed[i].0 == key {
      let p = keyed[i].1
      sum_x += p.x()
      sum_y += p.y()
      sum_z += p.z()
      count += 1
      i += 1
    }
    let inv = 1.0 / count.to_double()
    result.push(@alg.Pt3::new(sum_x * inv, sum_y * inv, sum_z * inv))
  }
  result
}

///|
/// 随机降采样：基于坐标哈希确定性选取 ratio 比例的点
/// ratio ∈ (0, 1]，确定性（相同输入相同输出）
pub fn random_downsample(
  points : Array[@alg.Pt3],
  ratio : Double,
) -> Array[@alg.Pt3] raise @util.GeoError {
  if ratio <= 0.0 || ratio > 1.0 {
    raise @util.GeoError::DegenerateInput("ratio 必须在 (0, 1] 范围内", [])
  }
  let result : Array[@alg.Pt3] = []
  for p in points {
    let hash = (p.x() * 12345.6789 + p.y() * 98765.4321 + p.z() * 54321.0).abs()
    let frac = hash - hash.floor()
    if frac < ratio {
      result.push(p)
    }
  }
  result
}
