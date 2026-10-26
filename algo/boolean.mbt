// 布尔运算：多边形裁剪 + 交/并/差
// 第5层 algo，依赖 util（EPS）、alg（几何类型）
// Sutherland-Hodgman 凸裁剪 + 矩形布尔 + 多边形面积/质心

///|
/// 多边形面积（Shoelace 公式），结果为绝对值
pub fn polygon_area(coords : Array[(Double, Double)]) -> Double {
  let n = coords.length()
  if n < 3 {
    return 0.0
  }
  let mut sum = 0.0
  for i in 0..<n {
    let j = (i + 1) % n
    sum += coords[i].0 * coords[j].1
    sum -= coords[j].0 * coords[i].1
  }
  sum.abs() / 2.0
}

///|
/// 多边形带符号面积（正=逆时针，负=顺时针）
pub fn polygon_signed_area(coords : Array[(Double, Double)]) -> Double {
  let n = coords.length()
  if n < 3 {
    return 0.0
  }
  let mut sum = 0.0
  for i in 0..<n {
    let j = (i + 1) % n
    sum += coords[i].0 * coords[j].1
    sum -= coords[j].0 * coords[i].1
  }
  sum / 2.0
}

///|
/// 多边形质心
pub fn polygon_centroid(coords : Array[(Double, Double)]) -> (Double, Double) {
  let n = coords.length()
  if n < 3 {
    return (0.0, 0.0)
  }
  let mut cx = 0.0
  let mut cy = 0.0
  let mut area = 0.0
  for i in 0..<n {
    let j = (i + 1) % n
    let cross = coords[i].0 * coords[j].1 - coords[j].0 * coords[i].1
    cx += (coords[i].0 + coords[j].0) * cross
    cy += (coords[i].1 + coords[j].1) * cross
    area += cross
  }
  area = area / 2.0
  if @util.dbl_approx_zero(area, @util.EPS) {
    let mut mx = 0.0
    let mut my = 0.0
    for i in 0..<n {
      mx += coords[i].0
      my += coords[i].1
    }
    (mx / n.to_double(), my / n.to_double())
  } else {
    (cx / (6.0 * area), cy / (6.0 * area))
  }
}

///|
/// 判断点是否在边的内侧（假设逆时针多边形，内侧在左边）
fn is_inside(
  point : (Double, Double),
  edge_start : (Double, Double),
  edge_end : (Double, Double),
) -> Bool {
  let cross = (edge_end.0 - edge_start.0) * (point.1 - edge_start.1) -
    (edge_end.1 - edge_start.1) * (point.0 - edge_start.0)
  cross >= 0.0
}

///|
/// 计算两条线段的交点
fn line_intersect(
  p1 : (Double, Double),
  p2 : (Double, Double),
  p3 : (Double, Double),
  p4 : (Double, Double),
) -> (Double, Double) {
  let denom = (p1.0 - p2.0) * (p3.1 - p4.1) - (p1.1 - p2.1) * (p3.0 - p4.0)
  if @util.dbl_approx_zero(denom, @util.EPS) {
    return p1
  }
  let t = ((p1.0 - p3.0) * (p3.1 - p4.1) - (p1.1 - p3.1) * (p3.0 - p4.0)) /
    denom
  let x = p1.0 + t * (p2.0 - p1.0)
  let y = p1.1 + t * (p2.1 - p1.1)
  (x, y)
}

///|
/// Sutherland-Hodgman 多边形裁剪：用凸多边形 clip 裁剪 subject
/// subject 可以是任意多边形，clip 必须是凸多边形（逆时针）
pub fn clip_polygon(
  subject : Array[(Double, Double)],
  clip : Array[(Double, Double)],
) -> Array[(Double, Double)] {
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
  polygon : Array[(Double, Double)],
  edge_start : (Double, Double),
  edge_end : (Double, Double),
) -> Array[(Double, Double)] {
  let n = polygon.length()
  if n == 0 {
    return []
  }
  let result : Array[(Double, Double)] = []
  for i in 0..<n {
    let current = polygon[i]
    let prev = polygon[(i - 1 + n) % n]
    let current_inside = is_inside(current, edge_start, edge_end)
    let prev_inside = is_inside(prev, edge_start, edge_end)
    if current_inside {
      if not(prev_inside) {
        result.push(line_intersect(prev, current, edge_start, edge_end))
      }
      result.push(current)
    } else if prev_inside {
      result.push(line_intersect(prev, current, edge_start, edge_end))
    }
  }
  result
}

///|
/// 凸多边形交集（两个凸多边形都是逆时针）
pub fn intersect_convex(
  poly1 : Array[(Double, Double)],
  poly2 : Array[(Double, Double)],
) -> Array[(Double, Double)] {
  clip_polygon(poly1, poly2)
}

///|
/// 矩形（min_x, min_y, max_x, max_y）
pub struct Rect {
  min_x : Double
  min_y : Double
  max_x : Double
  max_y : Double
}

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
pub fn Rect::center(self : Rect) -> (Double, Double) {
  ((self.min_x + self.max_x) / 2.0, (self.min_y + self.max_y) / 2.0)
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
pub fn Rect::contains(self : Rect, x : Double, y : Double) -> Bool {
  x >= self.min_x && x <= self.max_x && y >= self.min_y && y <= self.max_y
}

///|
/// 矩形转为多边形顶点（逆时针）
pub fn Rect::to_polygon(self : Rect) -> Array[(Double, Double)] {
  [
    (self.min_x, self.min_y),
    (self.max_x, self.min_y),
    (self.max_x, self.max_y),
    (self.min_x, self.max_y),
  ]
}

///|
/// 判断多边形是否为逆时针方向
pub fn is_counterclockwise(coords : Array[(Double, Double)]) -> Bool {
  polygon_signed_area(coords) > 0.0
}

///|
/// 确保多边形为逆时针方向（如果不是则反转）
pub fn ensure_counterclockwise(
  coords : Array[(Double, Double)],
) -> Array[(Double, Double)] {
  if is_counterclockwise(coords) {
    coords
  } else {
    let result : Array[(Double, Double)] = []
    for i in 0..<coords.length() {
      result.push(coords[coords.length() - 1 - i])
    }
    result
  }
}
