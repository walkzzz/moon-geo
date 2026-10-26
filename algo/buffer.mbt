// 缓冲区：点/线缓冲 + 拓扑修复
// 第5层 algo，依赖 util（EPS）、alg（Pt2）、math（三角函数）

///|
/// 点缓冲区：生成以 p 为圆心、radius 为半径的圆的多边形近似
/// segments 为圆弧分段数
pub fn buffer_point(
  p : @alg.Pt2,
  radius : Double,
  segments : Int32,
) -> Array[@alg.Pt2] {
  let result : Array[@alg.Pt2] = []
  let seg = if segments < 3 { 16 } else { segments }
  for i in 0..<seg {
    let angle = 2.0 * @math.PI * i.to_double() / seg.to_double()
    let px = p.x() + radius * @math.cos(angle)
    let py = p.y() + radius * @math.sin(angle)
    result.push(@alg.Pt2::new(px, py))
  }
  result
}

///|
/// 线缓冲区：生成线段的缓冲多边形（矩形 + 端点圆弧近似）
/// 输入线段 p1→p2，缓冲距离 radius
pub fn buffer_line_segment(
  p1 : @alg.Pt2,
  p2 : @alg.Pt2,
  radius : Double,
) -> Array[@alg.Pt2] {
  let dx = p2.x() - p1.x()
  let dy = p2.y() - p1.y()
  let len = (dx * dx + dy * dy).sqrt()
  if @util.dbl_approx_zero(len, @util.EPS) {
    return buffer_point(p1, radius, 32)
  }
  let nx = -dy / len * radius
  let ny = dx / len * radius
  let result : Array[@alg.Pt2] = []
  result.push(@alg.Pt2::new(p1.x() + nx, p1.y() + ny))
  result.push(@alg.Pt2::new(p2.x() + nx, p2.y() + ny))
  let seg = 8
  for i in 0..<seg {
    let angle = @math.PI * i.to_double() / seg.to_double()
    let cos_a = @math.cos(angle)
    let sin_a = @math.sin(angle)
    let px = p2.x() + nx * cos_a + ny * sin_a
    let py = p2.y() + ny * cos_a - nx * sin_a
    result.push(@alg.Pt2::new(px, py))
  }
  result.push(@alg.Pt2::new(p2.x() - nx, p2.y() - ny))
  result.push(@alg.Pt2::new(p1.x() - nx, p1.y() - ny))
  for i in 0..<seg {
    let angle = @math.PI * i.to_double() / seg.to_double()
    let cos_a = @math.cos(angle)
    let sin_a = @math.sin(angle)
    let px = p1.x() - nx * cos_a - ny * sin_a
    let py = p1.y() - ny * cos_a + nx * sin_a
    result.push(@alg.Pt2::new(px, py))
  }
  result
}

///|
/// 折线缓冲区：对折线的每条线段生成缓冲，取外轮廓
/// 简化版：对每条线段单独缓冲，返回所有缓冲多边形
pub fn buffer_polyline(
  coords : Array[@alg.Pt2],
  radius : Double,
) -> Array[Array[@alg.Pt2]] {
  let result : Array[Array[@alg.Pt2]] = []
  if coords.length() < 2 {
    return result
  }
  let n = coords.length() - 1
  for i in 0..<n {
    result.push(buffer_line_segment(coords[i], coords[i + 1], radius))
  }
  result
}

///|
/// 合并重复顶点（距离小于 tolerance 的顶点合并）
/// 返回 (新顶点列表, 旧索引→新索引映射)
pub fn merge_duplicate_vertices(
  coords : Array[@alg.Pt2],
  tolerance : Double,
) -> (Array[@alg.Pt2], Array[Int32]) {
  let unique : Array[@alg.Pt2] = []
  let mapping : Array[Int32] = []
  for i in 0..<coords.length() {
    let p = coords[i]
    let mut found = -1
    for j in 0..<unique.length() {
      let dx = p.x() - unique[j].x()
      let dy = p.y() - unique[j].y()
      if (dx * dx + dy * dy).sqrt() < tolerance {
        found = j
        break
      }
    }
    if found >= 0 {
      mapping.push(found)
    } else {
      unique.push(p)
      mapping.push(unique.length() - 1)
    }
  }
  (unique, mapping)
}

///|
/// 修正多边形方向为逆时针
pub fn fix_orientation(coords : Array[@alg.Pt2]) -> Array[@alg.Pt2] {
  ensure_counterclockwise(coords)
}

///|
/// 检测多边形是否有重复顶点
pub fn has_duplicate_vertices(
  coords : Array[@alg.Pt2],
  tolerance : Double,
) -> Bool {
  let n = coords.length()
  for i in 0..<n {
    let xi = coords[i].x()
    let yi = coords[i].y()
    let start = i + 1
    for j in start..<n {
      let dx = xi - coords[j].x()
      let dy = yi - coords[j].y()
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
  coords : Array[@alg.Pt2],
  tolerance : Double,
) -> Array[@alg.Pt2] {
  let result : Array[@alg.Pt2] = []
  for i in 0..<coords.length() {
    let p = coords[i]
    let mut is_dup = false
    for j in 0..<result.length() {
      let dx = p.x() - result[j].x()
      let dy = p.y() - result[j].y()
      if (dx * dx + dy * dy).sqrt() < tolerance {
        is_dup = true
        break
      }
    }
    if !is_dup {
      result.push(p)
    }
  }
  result
}

///|
/// 计算折线长度
pub fn polyline_length(coords : Array[@alg.Pt2]) -> Double {
  let mut total = 0.0
  let n = coords.length() - 1
  for i in 0..<n {
    let dx = coords[i + 1].x() - coords[i].x()
    let dy = coords[i + 1].y() - coords[i].y()
    total += (dx * dx + dy * dy).sqrt()
  }
  total
}

///|
/// 计算折线周长（闭合）
pub fn polygon_perimeter(coords : Array[@alg.Pt2]) -> Double {
  if coords.length() < 2 {
    return 0.0
  }
  let mut total = polyline_length(coords)
  let dx = coords[0].x() - coords[coords.length() - 1].x()
  let dy = coords[0].y() - coords[coords.length() - 1].y()
  total += (dx * dx + dy * dy).sqrt()
  total
}
