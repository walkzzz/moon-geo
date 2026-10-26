// 点云统计信息 + 法向估计
// platform/pcloud

///|
/// 包围盒 (min, max)
pub fn bounding_box(
  points : Array[@alg.Pt3],
) -> (@alg.Pt3, @alg.Pt3) raise @util.GeoError {
  let n = points.length()
  if n == 0 {
    raise @util.GeoError::DegenerateInput("点云为空", [])
  }
  let mut min_x = points[0].x()
  let mut min_y = points[0].y()
  let mut min_z = points[0].z()
  let mut max_x = min_x
  let mut max_y = min_y
  let mut max_z = min_z
  for i in 1..<n {
    let p = points[i]
    if p.x() < min_x {
      min_x = p.x()
    }
    if p.y() < min_y {
      min_y = p.y()
    }
    if p.z() < min_z {
      min_z = p.z()
    }
    if p.x() > max_x {
      max_x = p.x()
    }
    if p.y() > max_y {
      max_y = p.y()
    }
    if p.z() > max_z {
      max_z = p.z()
    }
  }
  (@alg.Pt3::new(min_x, min_y, min_z), @alg.Pt3::new(max_x, max_y, max_z))
}

///|
/// 质心
pub fn centroid(points : Array[@alg.Pt3]) -> @alg.Pt3 raise @util.GeoError {
  let n = points.length()
  if n == 0 {
    raise @util.GeoError::DegenerateInput("点云为空", [])
  }
  let mut sx = 0.0
  let mut sy = 0.0
  let mut sz = 0.0
  for p in points {
    sx += p.x()
    sy += p.y()
    sz += p.z()
  }
  let inv = 1.0 / n.to_double()
  @alg.Pt3::new(sx * inv, sy * inv, sz * inv)
}

///|
/// 点密度 = 点数 / 包围盒体积
pub fn density(points : Array[@alg.Pt3]) -> Double raise @util.GeoError {
  let n = points.length()
  if n == 0 {
    raise @util.GeoError::DegenerateInput("点云为空", [])
  }
  let (bmin, bmax) = bounding_box(points)
  let vol = (bmax.x() - bmin.x()) *
    (bmax.y() - bmin.y()) *
    (bmax.z() - bmin.z())
  if vol <= 0.0 {
    raise @util.GeoError::DegenerateInput(
      "包围盒体积为零（点共面或共线）",
      [],
    )
  }
  n.to_double() / vol
}

///|
/// 法向估计（KNN + PCA，暴力搜索 O(n²)，reference implementation）
/// 对每个点找 k 个最近邻，用 PCA 最小特征向量作为法向
pub fn estimate_normals(
  points : Array[@alg.Pt3],
  k : Int32,
) -> Array[@alg.Pt3] raise @util.GeoError {
  let n = points.length()
  if k < 3 {
    raise @util.GeoError::DegenerateInput("k 至少为 3", [])
  }
  let normals : Array[@alg.Pt3] = []
  for i in 0..<n {
    let p = points[i]
    let dists : Array[(Double, Int32)] = []
    for j in 0..<n {
      if j != i {
        let dx = points[j].x() - p.x()
        let dy = points[j].y() - p.y()
        let dz = points[j].z() - p.z()
        dists.push((dx * dx + dy * dy + dz * dz, j))
      }
    }
    dists.sort_by(fn(a, b) { a.0.compare(b.0) })
    let kk = if k < dists.length() { k } else { dists.length() }
    if kk < 3 {
      normals.push(@alg.Pt3::new(0.0, 0.0, 1.0))
    } else {
      let mut cx = 0.0
      let mut cy = 0.0
      let mut cz = 0.0
      for j in 0..<kk {
        let idx = dists[j].1
        cx += points[idx].x()
        cy += points[idx].y()
        cz += points[idx].z()
      }
      let inv = 1.0 / kk.to_double()
      cx *= inv
      cy *= inv
      cz *= inv
      let mut c00 = 0.0
      let mut c01 = 0.0
      let mut c02 = 0.0
      let mut c11 = 0.0
      let mut c12 = 0.0
      let mut c22 = 0.0
      for j in 0..<kk {
        let idx = dists[j].1
        let dx = points[idx].x() - cx
        let dy = points[idx].y() - cy
        let dz = points[idx].z() - cz
        c00 += dx * dx
        c01 += dx * dy
        c02 += dx * dz
        c11 += dy * dy
        c12 += dy * dz
        c22 += dz * dz
      }
      let trace = c00 + c11 + c22
      let m00 = trace - c00
      let m01 = -c01
      let m02 = -c02
      let m11 = trace - c11
      let m12 = -c12
      let m22 = trace - c22
      let mut vx = 1.0
      let mut vy = 1.0
      let mut vz = 1.0
      for _ in 0..<20 {
        let nx = m00 * vx + m01 * vy + m02 * vz
        let ny = m01 * vx + m11 * vy + m12 * vz
        let nz = m02 * vx + m12 * vy + m22 * vz
        let norm = (nx * nx + ny * ny + nz * nz).sqrt()
        if norm > 0.0 {
          vx = nx / norm
          vy = ny / norm
          vz = nz / norm
        }
      }
      normals.push(@alg.Pt3::new(vx, vy, vz))
    }
  }
  normals
}
