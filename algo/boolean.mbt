// 布尔运算：多边形裁剪 + 交/并/差
// 第5层 algo，依赖 util（EPS）、alg（Pt2）
// Sutherland-Hodgman 凸裁剪 + 矩形布尔 + 多边形面积/质心

///|
/// 多边形面积（Shoelace 公式），结果为绝对值
pub fn polygon_area(coords : Array[@alg.Pt2]) -> Double {
  let n = coords.length()
  if n < 3 {
    return 0.0
  }
  let mut sum = 0.0
  for i in 0..<n {
    let j = (i + 1) % n
    sum += coords[i].x() * coords[j].y()
    sum -= coords[j].x() * coords[i].y()
  }
  sum.abs() / 2.0
}

///|
/// 多边形带符号面积（正=逆时针，负=顺时针）
pub fn polygon_signed_area(coords : Array[@alg.Pt2]) -> Double {
  let n = coords.length()
  if n < 3 {
    return 0.0
  }
  let mut sum = 0.0
  for i in 0..<n {
    let j = (i + 1) % n
    sum += coords[i].x() * coords[j].y()
    sum -= coords[j].x() * coords[i].y()
  }
  sum / 2.0
}

///|
/// 多边形质心
pub fn polygon_centroid(coords : Array[@alg.Pt2]) -> @alg.Pt2 {
  let n = coords.length()
  if n < 3 {
    return @alg.Pt2::new(0.0, 0.0)
  }
  let mut cx = 0.0
  let mut cy = 0.0
  let mut area = 0.0
  let mut area_scale = 0.0
  for i in 0..<n {
    let j = (i + 1) % n
    let t1 = coords[i].x() * coords[j].y()
    let t2 = coords[j].x() * coords[i].y()
    let cross = t1 - t2
    cx += (coords[i].x() + coords[j].x()) * cross
    cy += (coords[i].y() + coords[j].y()) * cross
    area += cross
    area_scale += t1.abs() + t2.abs()
  }
  area = area / 2.0
  area_scale = area_scale / 2.0
  if @util.scaled_approx_zero(area, area_scale, @util.EPS) {
    let mut mx = 0.0
    let mut my = 0.0
    for i in 0..<n {
      mx += coords[i].x()
      my += coords[i].y()
    }
    @alg.Pt2::new(mx / n.to_double(), my / n.to_double())
  } else {
    @alg.Pt2::new(cx / (6.0 * area), cy / (6.0 * area))
  }
}

///|
/// 判断点是否在边的内侧（假设逆时针多边形，内侧在左边）
/// 引入容差避免边界点重复（N4 修复）
fn is_inside(
  point : @alg.Pt2,
  edge_start : @alg.Pt2,
  edge_end : @alg.Pt2,
) -> Bool {
  let dx = edge_end.x() - edge_start.x()
  let dy = edge_end.y() - edge_start.y()
  let px = point.x() - edge_start.x()
  let py = point.y() - edge_start.y()
  let cross = dx * py - dy * px
  let scale = (dx * py).abs() + (dy * px).abs()
  cross >= 0.0 || @util.scaled_approx_zero(cross, scale, @util.EPS)
}

///|
/// 计算两条线段的交点，平行时返回 None（N4 修复：不再静默返回端点）
fn line_intersect(
  p1 : @alg.Pt2,
  p2 : @alg.Pt2,
  p3 : @alg.Pt2,
  p4 : @alg.Pt2,
) -> @alg.Pt2? {
  let t1 = (p1.x() - p2.x()) * (p3.y() - p4.y())
  let t2 = (p1.y() - p2.y()) * (p3.x() - p4.x())
  let denom = t1 - t2
  let denom_scale = t1.abs() + t2.abs()
  if @util.scaled_approx_zero(denom, denom_scale, @util.EPS) {
    return None
  }
  let t = (
      (p1.x() - p3.x()) * (p3.y() - p4.y()) -
      (p1.y() - p3.y()) * (p3.x() - p4.x())
    ) /
    denom
  let x = p1.x() + t * (p2.x() - p1.x())
  let y = p1.y() + t * (p2.y() - p1.y())
  Some(@alg.Pt2::new(x, y))
}

///|
/// Sutherland-Hodgman 多边形裁剪：用凸多边形 clip 裁剪 subject
/// subject 可以是任意多边形，clip 必须是凸多边形（逆时针）
pub fn clip_polygon(
  subject : Array[@alg.Pt2],
  clip : Array[@alg.Pt2],
) -> Array[@alg.Pt2] {
  let clip_n = clip.length()
  if clip_n < 3 {
    return []
  }
  let mut result = subject
  for i in 0..<clip_n {
    let edge_start = clip[i]
    let edge_end = clip[(i + 1) % clip_n]
    result = clip_against_edge(result, edge_start, edge_end)
    if result.length() == 0 {
      return []
    }
  }
  result
}

///|
/// 用单条边裁剪多边形
fn clip_against_edge(
  polygon : Array[@alg.Pt2],
  edge_start : @alg.Pt2,
  edge_end : @alg.Pt2,
) -> Array[@alg.Pt2] {
  let n = polygon.length()
  if n == 0 {
    return []
  }
  let result : Array[@alg.Pt2] = []
  for i in 0..<n {
    let current = polygon[i]
    let prev = polygon[(i - 1 + n) % n]
    let current_inside = is_inside(current, edge_start, edge_end)
    let prev_inside = is_inside(prev, edge_start, edge_end)
    if current_inside {
      if !prev_inside {
        match line_intersect(prev, current, edge_start, edge_end) {
          Some(pt) => result.push(pt)
          None => ()
        }
      }
      result.push(current)
    } else if prev_inside {
      match line_intersect(prev, current, edge_start, edge_end) {
        Some(pt) => result.push(pt)
        None => ()
      }
    }
  }
  result
}

///|
/// 凸多边形交集（两个凸多边形都是逆时针）
pub fn intersect_convex(
  poly1 : Array[@alg.Pt2],
  poly2 : Array[@alg.Pt2],
) -> Array[@alg.Pt2] {
  clip_polygon(poly1, poly2)
}

///|
/// 矩形（min_x, min_y, max_x, max_y）
pub struct Rect {
  min_x : Double
  min_y : Double
  max_x : Double
  max_y : Double
} derive(Debug)

///|
pub fn Rect::new(
  min_x : Double,
  min_y : Double,
  max_x : Double,
  max_y : Double,
) -> Rect {
  { min_x, min_y, max_x, max_y, }
}

///|
/// 矩形面积
pub fn Rect::area(self : Rect) -> Double {
  (self.max_x - self.min_x) * (self.max_y - self.min_y)
}

///|
/// 矩形宽
pub fn Rect::width(self : Rect) -> Double {
  self.max_x - self.min_x
}

///|
/// 矩形高
pub fn Rect::height(self : Rect) -> Double {
  self.max_y - self.min_y
}

///|
/// 矩形中心
pub fn Rect::center(self : Rect) -> @alg.Pt2 {
  @alg.Pt2::new(
    (self.min_x + self.max_x) / 2.0,
    (self.min_y + self.max_y) / 2.0,
  )
}

///|
/// 矩形交集（无交集返回 None）
pub fn Rect::intersect(self : Rect, other : Rect) -> Rect? {
  let min_x = if self.min_x > other.min_x { self.min_x } else { other.min_x }
  let min_y = if self.min_y > other.min_y { self.min_y } else { other.min_y }
  let max_x = if self.max_x < other.max_x { self.max_x } else { other.max_x }
  let max_y = if self.max_y < other.max_y { self.max_y } else { other.max_y }
  if min_x < max_x && min_y < max_y {
    Some({ min_x, min_y, max_x, max_y, })
  } else {
    None
  }
}

///|
/// 矩形并集（最小包围矩形）
pub fn Rect::union(self : Rect, other : Rect) -> Rect {
  let min_x = if self.min_x < other.min_x { self.min_x } else { other.min_x }
  let min_y = if self.min_y < other.min_y { self.min_y } else { other.min_y }
  let max_x = if self.max_x > other.max_x { self.max_x } else { other.max_x }
  let max_y = if self.max_y > other.max_y { self.max_y } else { other.max_y }
  { min_x, min_y, max_x, max_y, }
}

///|
/// 判断两矩形是否相交
pub fn Rect::intersects(self : Rect, other : Rect) -> Bool {
  self.min_x < other.max_x &&
  self.max_x > other.min_x &&
  self.min_y < other.max_y &&
  self.max_y > other.min_y
}

///|
/// 判断点是否在矩形内
pub fn Rect::contains(self : Rect, p : @alg.Pt2) -> Bool {
  p.x() >= self.min_x &&
  p.x() <= self.max_x &&
  p.y() >= self.min_y &&
  p.y() <= self.max_y
}

///|
/// 矩形转为多边形顶点（逆时针）
pub fn Rect::to_polygon(self : Rect) -> Array[@alg.Pt2] {
  [
    @alg.Pt2::new(self.min_x, self.min_y),
    @alg.Pt2::new(self.max_x, self.min_y),
    @alg.Pt2::new(self.max_x, self.max_y),
    @alg.Pt2::new(self.min_x, self.max_y),
  ]
}

///|
/// 判断多边形是否为逆时针方向
pub fn is_counterclockwise(coords : Array[@alg.Pt2]) -> Bool {
  polygon_signed_area(coords) > 0.0
}

///|
/// 确保多边形为逆时针方向（如果不是则反转）
pub fn ensure_counterclockwise(coords : Array[@alg.Pt2]) -> Array[@alg.Pt2] {
  if is_counterclockwise(coords) {
    coords
  } else {
    let result : Array[@alg.Pt2] = []
    for i in 0..<coords.length() {
      result.push(coords[coords.length() - 1 - i])
    }
    result
  }
}
