// 缓冲区：点/线缓冲 + 拓扑修复
// 第5层 algo，依赖 util（EPS）、math（三角函数）

///|
/// 点缓冲区：生成以 (x, y) 为圆心、radius 为半径的圆的多边形近似
/// segments 为圆弧分段数
pub fn buffer_point(
  x : Double,
  y : Double,
  radius : Double,
  segments : Int32,
) -> Array[(Double, Double)] {
  let result : Array[(Double, Double)] = []
  let seg = if segments < 3 { 16 } else { segments }
  for i in 0..<seg {
    let angle = 2.0 * @math.PI * i.to_double() / seg.to_double()
    let px = x + radius * @math.cos(angle)
    let py = y + radius * @math.sin(angle)
    result.push((px, py))
  }
  result
}

///|
/// 线缓冲区：生成线段的缓冲多边形（矩形 + 端点圆弧近似）
/// 输入线段 (x1,y1)→(x2,y2)，缓冲距离 radius
pub fn buffer_line_segment(
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  radius : Double,
) -> Array[(Double, Double)] {
  let dx = x2 - x1
  let dy = y2 - y1
  let len = (dx * dx + dy * dy).sqrt()
  if @util.dbl_approx_zero(len, @util.EPS) {
    return buffer_point(x1, y1, radius, 32)
  }
  let nx = -dy / len * radius
  let ny = dx / len * radius
  let result : Array[(Double, Double)] = []
  result.push((x1 + nx, y1 + ny))
  result.push((x2 + nx, y2 + ny))
  let seg = 8
  for i in 0..<seg {
    let angle = @math.PI * i.to_double() / seg.to_double()
    let cos_a = @math.cos(angle)
    let sin_a = @math.sin(angle)
    let px = x2 + nx * cos_a + ny * sin_a
    let py = y2 + ny * cos_a - nx * sin_a
    result.push((px, py))
  }
  result.push((x2 - nx, y2 - ny))
  result.push((x1 - nx, y1 - ny))
  for i in 0..<seg {
    let angle = @math.PI * i.to_double() / seg.to_double()
    let cos_a = @math.cos(angle)
    let sin_a = @math.sin(angle)
    let px = x1 - nx * cos_a - ny * sin_a
    let py = y1 - ny * cos_a + nx * sin_a
    result.push((px, py))
  }
  result
}

///|
/// 折线缓冲区：对折线的每条线段生成缓冲，取外轮廓
/// 简化版：对每条线段单独缓冲，返回所有缓冲多边形
pub fn buffer_polyline(
  coords : Array[(Double, Double)],
  radius : Double,
) -> Array[Array[(Double, Double)]] {
  let result : Array[Array[(Double, Double)]] = []
  if coords.length() < 2 {
    return result
  }
  let n = coords.length() - 1
  for i in 0..<n {
    let (x1, y1) = coords[i]
    let (x2, y2) = coords[i + 1]
    result.push(buffer_line_segment(x1, y1, x2, y2, radius))
  }
  result
}

///|
/// 合并重复顶点（距离小于 tolerance 的顶点合并）
/// 返回 (新顶点列表, 旧索引→新索引映射)
pub fn merge_duplicate_vertices(
  coords : Array[(Double, Double)],
  tolerance : Double,
) -> (Array[(Double, Double)], Array[Int32]) {
  let unique : Array[(Double, Double)] = []
  let mapping : Array[Int32] = []
  for i in 0..<coords.length() {
    let (x, y) = coords[i]
    let mut found = -1
    for j in 0..<unique.length() {
      let (ux, uy) = unique[j]
      let dx = x - ux
      let dy = y - uy
      if (dx * dx + dy * dy).sqrt() < tolerance {
        found = j
        break
      }
    }
    if found >= 0 {
      mapping.push(found)
    } else {
      unique.push((x, y))
      mapping.push(unique.length() - 1)
    }
  }
  (unique, mapping)
}

///|
/// 修正多边形方向为逆时针
pub fn fix_orientation(
  coords : Array[(Double, Double)],
) -> Array[(Double, Double)] {
  ensure_counterclockwise(coords)
}

///|
/// 检测多边形是否有重复顶点
pub fn has_duplicate_vertices(
  coords : Array[(Double, Double)],
  tolerance : Double,
) -> Bool {
  let n = coords.length()
  for i in 0..<n {
    let (xi, yi) = coords[i]
    let start = i + 1
    for j in start..<n {
      let (xj, yj) = coords[j]
      let dx = xi - xj
      let dy = yi - yj
      if (dx * dx + dy * dy).sqrt() < tolerance {
        return true
      }
    }
  }
  false
}

///|
/// 移除多边形中的重复顶点
pub fn remove_duplicate_vertices(
  coords : Array[(Double, Double)],
  tolerance : Double,
) -> Array[(Double, Double)] {
  let result : Array[(Double, Double)] = []
  for i in 0..<coords.length() {
    let (x, y) = coords[i]
    let mut is_dup = false
    for j in 0..<result.length() {
      let dx = x - result[j].0
      let dy = y - result[j].1
      if (dx * dx + dy * dy).sqrt() < tolerance {
        is_dup = true
        break
      }
    }
    if not(is_dup) {
      result.push((x, y))
    }
  }
  result
}

///|
/// 计算折线长度
pub fn polyline_length(coords : Array[(Double, Double)]) -> Double {
  let mut total = 0.0
  let n = coords.length() - 1
  for i in 0..<n {
    let (x1, y1) = coords[i]
    let (x2, y2) = coords[i + 1]
    let dx = x2 - x1
    let dy = y2 - y1
    total += (dx * dx + dy * dy).sqrt()
  }
  total
}

///|
/// 计算折线周长（闭合）
pub fn polygon_perimeter(coords : Array[(Double, Double)]) -> Double {
  if coords.length() < 2 {
    return 0.0
  }
  let mut total = polyline_length(coords)
  let dx = coords[0].0 - coords[coords.length() - 1].0
  let dy = coords[0].1 - coords[coords.length() - 1].1
  total += (dx * dx + dy * dy).sqrt()
  total
}
