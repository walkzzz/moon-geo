// 栅格空间 Raster2
// 第1层 space，依赖 util, atop, math
// 定义二维栅格空间：原点 + 像素大小 + 宽高
// 提供栅格坐标 ↔ 世界坐标变换 + 矢栅转换（点/线栅格化 + 像元矢量化）

///|
/// 二维栅格空间定义
pub struct Raster2 {
  origin_x : Double
  origin_y : Double
  pixel_w : Double
  pixel_h : Double
  width : Int32
  height : Int32
}

///|
/// 构造栅格空间
pub fn Raster2::new(
  origin_x : Double,
  origin_y : Double,
  pixel_w : Double,
  pixel_h : Double,
  width : Int32,
  height : Int32,
) -> Raster2 {
  { origin_x, origin_y, pixel_w, pixel_h, width, height, }
}

///|
/// 像元左上角 → 世界坐标
pub fn Raster2::cell_to_world(
  self : Raster2,
  col : Int32,
  row : Int32,
) -> (Double, Double) {
  let x = self.origin_x + col.to_double() * self.pixel_w
  let y = self.origin_y - row.to_double() * self.pixel_h
  (x, y)
}

///|
/// 像元中心 → 世界坐标
pub fn Raster2::cell_center_to_world(
  self : Raster2,
  col : Int32,
  row : Int32,
) -> (Double, Double) {
  let x = self.origin_x + (col.to_double() + 0.5) * self.pixel_w
  let y = self.origin_y - (row.to_double() + 0.5) * self.pixel_h
  (x, y)
}

///|
/// 世界坐标 → 像元索引（包含该点的像元 col, row）
pub fn Raster2::world_to_cell(
  self : Raster2,
  x : Double,
  y : Double,
) -> (Int32, Int32) {
  let col = ((x - self.origin_x) / self.pixel_w).floor().to_int()
  let row = ((self.origin_y - y) / self.pixel_h).floor().to_int()
  (col, row)
}

///|
/// 判断像元是否在栅格范围内
pub fn Raster2::cell_in_bounds(
  self : Raster2,
  col : Int32,
  row : Int32,
) -> Bool {
  col >= 0 && col < self.width && row >= 0 && row < self.height
}

///|
/// 判断世界坐标是否在栅格范围内
pub fn Raster2::contains(self : Raster2, x : Double, y : Double) -> Bool {
  let (col, row) = self.world_to_cell(x, y)
  self.cell_in_bounds(col, row)
}

///|
/// 像元多边形：四个角点的世界坐标（顺时针：左上→右上→右下→左下）
pub fn Raster2::cell_polygon(
  self : Raster2,
  col : Int32,
  row : Int32,
) -> Array[(Double, Double)] {
  let (x0, y0) = self.cell_to_world(col, row)
  let x1 = x0 + self.pixel_w
  let y1 = y0 - self.pixel_h
  [(x0, y0), (x1, y0), (x1, y1), (x0, y1)]
}

///|
/// 像元总数
pub fn Raster2::cell_count(self : Raster2) -> Int32 {
  self.width * self.height
}

///|
/// 栅格边界世界坐标（左上、右下）
pub fn Raster2::bounds(self : Raster2) -> ((Double, Double), (Double, Double)) {
  let (x0, y0) = self.cell_to_world(0, 0)
  let (x1, y1) = self.cell_to_world(self.width, self.height)
  ((x0, y0), (x1, y1))
}

///|
/// 点栅格化：世界坐标点 → 像元索引（若在范围内）
pub fn Raster2::rasterize_point(
  self : Raster2,
  x : Double,
  y : Double,
) -> (Int32, Int32)? {
  let (col, row) = self.world_to_cell(x, y)
  if self.cell_in_bounds(col, row) {
    Some((col, row))
  } else {
    None
  }
}

///|
/// 线栅格化：Bresenham 算法，返回线段经过的所有像元索引
pub fn Raster2::rasterize_line(
  self : Raster2,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
) -> Array[(Int32, Int32)] {
  let (col1, row1) = self.world_to_cell(x1, y1)
  let (col2, row2) = self.world_to_cell(x2, y2)
  bresenham(col1, row1, col2, row2)
}

///|
/// Bresenham 直线算法：返回从 (col1,row1) 到 (col2,row2) 经过的所有栅格像元
fn bresenham(
  col1 : Int32,
  row1 : Int32,
  col2 : Int32,
  row2 : Int32,
) -> Array[(Int32, Int32)] {
  let result : Array[(Int32, Int32)] = []
  let dx = (col2 - col1).abs()
  let dy = (row2 - row1).abs()
  let sx = if col1 < col2 { 1 } else { -1 }
  let sy = if row1 < row2 { 1 } else { -1 }
  let mut err = dx - dy
  let mut col = col1
  let mut row = row1
  while true {
    result.push((col, row))
    if col == col2 && row == row2 {
      break
    }
    let e2 = 2 * err
    if e2 > -dy {
      err -= dy
      col += sx
    }
    if e2 < dx {
      err += dx
      row += sy
    }
  }
  result
}

///|
/// 像元矢量化：将布尔掩膜栅格转为多边形列表（每个 true 像元一个多边形）
pub fn Raster2::cells_to_polygons(
  self : Raster2,
  mask : Array[Array[Bool]],
) -> Array[Array[(Double, Double)]] {
  let result : Array[Array[(Double, Double)]] = []
  for row in 0..<self.height {
    if row < mask.length() {
      let mask_row = mask[row]
      for col in 0..<self.width {
        if col < mask_row.length() && mask_row[col] {
          result.push(self.cell_polygon(col, row))
        }
      }
    }
  }
  result
}

///|
/// 栅格化多边形：scanline fill 算法，返回多边形覆盖的像元索引列表
/// 对每行 scanline（像元中心 y），计算多边形边交点，排序后成对填充
/// 迭代前 clamp 范围到 [0,width)×[0,height)，避免越界性能炸弹
pub fn Raster2::rasterize_polygon(
  self : Raster2,
  coords : Array[(Double, Double)],
) -> Array[(Int32, Int32)] {
  if coords.length() < 3 {
    return []
  }
  let ((min_x, max_y), (max_x, min_y)) = polygon_bounds(coords)
  let (col_min_raw, row_min_raw) = self.world_to_cell(min_x, max_y)
  let (col_max_raw, row_max_raw) = self.world_to_cell(max_x, min_y)
  let col_min = if col_min_raw < 0 { 0 } else { col_min_raw }
  let col_max = if col_max_raw >= self.width {
    self.width - 1
  } else {
    col_max_raw
  }
  let row_min = if row_min_raw < 0 { 0 } else { row_min_raw }
  let row_max = if row_max_raw >= self.height {
    self.height - 1
  } else {
    row_max_raw
  }
  if col_min > col_max || row_min > row_max {
    return []
  }
  let result : Array[(Int32, Int32)] = []
  let n = coords.length()
  for row in row_min..<=row_max {
    let sy = self.origin_y - (row.to_double() + 0.5) * self.pixel_h
    let xs : Array[Double] = []
    let mut j = n - 1
    for i in 0..<n {
      let (xi, yi) = coords[i]
      let (xj, yj) = coords[j]
      if (yi <= sy && yj > sy) || (yj <= sy && yi > sy) {
        let x_intersect = xi + (sy - yi) / (yj - yi) * (xj - xi)
        xs.push(x_intersect)
      }
      j = i
    }
    sort_doubles(xs)
    let k = xs.length()
    let mut idx = 0
    while idx + 1 < k {
      let x_start = xs[idx]
      let x_end = xs[idx + 1]
      let col_start = ((x_start - self.origin_x) / self.pixel_w)
        .floor()
        .to_int()
      let col_end = ((x_end - self.origin_x) / self.pixel_w).floor().to_int()
      let cs = if col_start < col_min { col_min } else { col_start }
      let ce = if col_end > col_max { col_max } else { col_end }
      for col in cs..<=ce {
        result.push((col, row))
      }
      idx += 2
    }
  }
  result
}

///|
/// 对 Double 数组进行插入排序
fn sort_doubles(arr : Array[Double]) -> Unit {
  let n = arr.length()
  for i in 1..<n {
    let key = arr[i]
    let mut j = i - 1
    while j >= 0 && arr[j] > key {
      arr[j + 1] = arr[j]
      j -= 1
    }
    arr[j + 1] = key
  }
}

///|
/// 计算多边形边界框 ((min_x, max_y), (max_x, min_y))
fn polygon_bounds(
  coords : Array[(Double, Double)],
) -> ((Double, Double), (Double, Double)) {
  let mut min_x = coords[0].0
  let mut max_x = coords[0].0
  let mut min_y = coords[0].1
  let mut max_y = coords[0].1
  for i in 1..<coords.length() {
    let (x, y) = coords[i]
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
  ((min_x, max_y), (max_x, min_y))
}

///|
/// 射线法判断点是否在多边形内部
fn point_in_polygon(
  px : Double,
  py : Double,
  coords : Array[(Double, Double)],
) -> Bool {
  let n = coords.length()
  let mut inside = false
  let mut j = n - 1
  for i in 0..<n {
    let (xi, yi) = coords[i]
    let (xj, yj) = coords[j]
    if (yi > py) != (yj > py) {
      let x_intersect = xi + (py - yi) / (yj - yi) * (xj - xi)
      if px < x_intersect {
        inside = !inside
      }
    }
    j = i
  }
  inside
}
