// 凸包算法（Andrew's monotone chain）
// algo 层，依赖 alg（Pt2）
// O(n log n)，输出逆时针排列的凸包顶点

///|
/// 2D 凸包（Andrew's monotone chain 算法）
/// 输入：点集 Array[@alg.Pt2]
/// 输出：凸包顶点（逆时针排列，无重复）
/// 时间复杂度 O(n log n)，空间 O(n)
pub fn convex_hull(points : Array[@alg.Pt2]) -> Array[@alg.Pt2] {
  let n = points.length()
  if n <= 1 {
    return points.copy()
  }
  let sorted = points.copy()
  sorted.sort_by(fn(a, b) {
    if a.x() != b.x() {
      a.x().compare(b.x())
    } else {
      a.y().compare(b.y())
    }
  })
  let unique : Array[@alg.Pt2] = []
  unique.push(sorted[0])
  for i in 1..<n {
    let p = sorted[i]
    let prev = unique[unique.length() - 1]
    if p.x() != prev.x() || p.y() != prev.y() {
      unique.push(p)
    }
  }
  let m = unique.length()
  if m <= 2 {
    return unique
  }
  let lower : Array[@alg.Pt2] = Array::make(m, @alg.Pt2::new(0.0, 0.0))
  let mut lower_size = 0
  for i in 0..<m {
    let p = unique[i]
    while lower_size >= 2 &&
          hull_cross(lower[lower_size - 2], lower[lower_size - 1], p) <= 0.0 {
      lower_size -= 1
    }
    lower[lower_size] = p
    lower_size += 1
  }
  let upper : Array[@alg.Pt2] = Array::make(m, @alg.Pt2::new(0.0, 0.0))
  let mut upper_size = 0
  let mut i = m - 1
  while i >= 0 {
    let p = unique[i]
    while upper_size >= 2 &&
          hull_cross(upper[upper_size - 2], upper[upper_size - 1], p) <= 0.0 {
      upper_size -= 1
    }
    upper[upper_size] = p
    upper_size += 1
    i -= 1
  }
  let result : Array[@alg.Pt2] = []
  for j in 0..<(lower_size - 1) {
    result.push(lower[j])
  }
  for j in 0..<(upper_size - 1) {
    result.push(upper[j])
  }
  result
}

///|
/// 叉积 (a-o) × (b-o)，正=逆时针，负=顺时针，0=共线
fn hull_cross(o : @alg.Pt2, a : @alg.Pt2, b : @alg.Pt2) -> Double {
  (a.x() - o.x()) * (b.y() - o.y()) - (a.y() - o.y()) * (b.x() - o.x())
}
