// Delaunay 三角剖分（Bowyer-Watson 算法）
// 第5层 algo，依赖 util（EPS）、alg（Pt2）
// 输入：点集 Array[@alg.Pt2]，输出：三角形顶点索引列表

///|
/// 判断点 d 是否在三角形 (a,b,c) 的外接圆内
fn in_circumcircle(
  ax : Double,
  ay : Double,
  bx : Double,
  by : Double,
  cx : Double,
  cy : Double,
  dx : Double,
  dy : Double,
) -> Bool {
  let ax_ = ax - dx
  let ay_ = ay - dy
  let bx_ = bx - dx
  let by_ = by - dy
  let cx_ = cx - dx
  let cy_ = cy - dy
  let det = ax_ *
    (by_ * (cx_ * cx_ + cy_ * cy_) - cy_ * (bx_ * bx_ + by_ * by_)) -
    ay_ * (bx_ * (cx_ * cx_ + cy_ * cy_) - cx_ * (bx_ * bx_ + by_ * by_)) +
    (ax_ * ax_ + ay_ * ay_) * (bx_ * cy_ - cx_ * by_)
  let orient = (bx - ax) * (cy - ay) - (cx - ax) * (by - ay)
  if orient > 0.0 {
    det > 0.0
  } else {
    det < 0.0
  }
}

///|
/// 三角形相等比较
fn tri_equal(a : (Int32, Int32, Int32), b : (Int32, Int32, Int32)) -> Bool {
  a.0 == b.0 && a.1 == b.1 && a.2 == b.2
}

///|
/// 检查边是否被另一个坏三角形共享
fn is_shared_edge(
  ea : Int32,
  eb : Int32,
  bad : Array[(Int32, Int32, Int32)],
  exclude : (Int32, Int32, Int32),
) -> Bool {
  for tri in bad {
    if !tri_equal(tri, exclude) {
      let (a, b, c) = tri
      if (a == ea && b == eb) ||
        (b == ea && c == eb) ||
        (c == ea && a == eb) ||
        (a == eb && b == ea) ||
        (b == eb && c == ea) ||
        (c == eb && a == ea) {
        return true
      }
    }
  }
  false
}

///|
/// Delaunay 三角剖分（Bowyer-Watson 算法）
/// 输入：点集 Array[@alg.Pt2]
/// 输出：三角形列表 Array[(i, j, k)]，i/j/k 为点索引
pub fn delaunay(points : Array[@alg.Pt2]) -> Array[(Int32, Int32, Int32)] {
  let n = points.length()
  if n < 3 {
    return []
  }
  let mut min_x = points[0].x()
  let mut max_x = points[0].x()
  let mut min_y = points[0].y()
  let mut max_y = points[0].y()
  for i in 1..<n {
    let x = points[i].x()
    let y = points[i].y()
    if x < min_x {
      min_x = x
    }
    if x > max_x {
      max_x = x
    }
    if y < min_y {
      min_y = y
    }
    if y > max_y {
      max_y = y
    }
  }
  let dx = max_x - min_x
  let dy = max_y - min_y
  let delta_max = if dx > dy { dx } else { dy }
  let mid_x = (min_x + max_x) / 2.0
  let mid_y = (min_y + max_y) / 2.0
  let all_points : Array[@alg.Pt2] = []
  for p in points {
    all_points.push(p)
  }
  all_points.push(@alg.Pt2::new(mid_x - 20.0 * delta_max, mid_y - delta_max))
  all_points.push(@alg.Pt2::new(mid_x + 20.0 * delta_max, mid_y - delta_max))
  all_points.push(@alg.Pt2::new(mid_x, mid_y + 20.0 * delta_max))
  let super_a = n
  let super_b = n + 1
  let super_c = n + 2
  let mut triangles : Array[(Int32, Int32, Int32)] = [
    (super_a, super_b, super_c),
  ]
  for i in 0..<n {
    let px = all_points[i].x()
    let py = all_points[i].y()
    let bad_triangles : Array[(Int32, Int32, Int32)] = []
    let good_triangles : Array[(Int32, Int32, Int32)] = []
    for tri in triangles {
      let (a, b, c) = tri
      let ax = all_points[a].x()
      let ay = all_points[a].y()
      let bx = all_points[b].x()
      let by = all_points[b].y()
      let cx = all_points[c].x()
      let cy = all_points[c].y()
      if in_circumcircle(ax, ay, bx, by, cx, cy, px, py) {
        bad_triangles.push(tri)
      } else {
        good_triangles.push(tri)
      }
    }
    let boundary_edges : Array[(Int32, Int32)] = []
    for tri in bad_triangles {
      let (a, b, c) = tri
      let edges = [(a, b), (b, c), (c, a)]
      for edge in edges {
        if !is_shared_edge(edge.0, edge.1, bad_triangles, tri) {
          boundary_edges.push(edge)
        }
      }
    }
    triangles = good_triangles
    for (a, b) in boundary_edges {
      triangles.push((a, b, i))
    }
  }
  let result : Array[(Int32, Int32, Int32)] = []
  for tri in triangles {
    let (a, b, c) = tri
    if a < n && b < n && c < n {
      result.push(tri)
    }
  }
  result
}

///|
/// 三角剖分结果验证：三角形面积之和应等于凸包面积
pub fn triangulation_total_area(
  points : Array[@alg.Pt2],
  triangles : Array[(Int32, Int32, Int32)],
) -> Double {
  let mut total = 0.0
  for tri in triangles {
    let (a, b, c) = tri
    let ax = points[a].x()
    let ay = points[a].y()
    let bx = points[b].x()
    let by = points[b].y()
    let cx = points[c].x()
    let cy = points[c].y()
    let area = ((bx - ax) * (cy - ay) - (cx - ax) * (by - ay)).abs() / 2.0
    total += area
  }
  total
}

///|
/// 计算三角形数量（对于 n 个点的 Delaunay 三角剖分，预期 2n-2-h 个三角形，h 为凸包顶点数）
pub fn triangle_count(triangles : Array[(Int32, Int32, Int32)]) -> Int32 {
  triangles.length()
}

///|
/// Delaunay 三角剖分并产出 HEMesh 半边网格
/// 将 2D 点提升到 3D（z=0），三角剖分后构造完整半边拓扑
/// 这是 N1 类型贯通的关键：delaunay 不再只返回裸索引，而是产出 brep.HEMesh
pub fn delaunay_to_hemesh(points : Array[@alg.Pt2]) -> @brep.HEMesh {
  let triangles = delaunay(points)
  let pts3 : Array[@alg.Pt3] = []
  for p in points {
    pts3.push(@alg.Pt3::new(p.x(), p.y(), 0.0))
  }
  @brep.HEMesh::from_triangles(pts3, triangles)
}
