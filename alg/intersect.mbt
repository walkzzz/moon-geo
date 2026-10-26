// 几何求交
// 第2层 alg，依赖 util, atop, space
// line-circle, circle-circle 求交

///|
/// 直线与圆求交
/// 返回交点数组（0/1/2 个点）
pub fn intersect_line_circle(line : Line2, circle : Circle) -> Array[Pt2] {
  let result = []
  let a = line.a()
  let b = line.b()
  let c = line.c()
  let cx = circle.cx()
  let cy = circle.cy()
  let r = circle.r()
  let aabb = a * a + b * b
  if a.abs() > b.abs() {
    let d = c + a * cx
    let qa = aabb
    let qb = 2.0 * b * d - 2.0 * a * a * cy
    let qc = d * d + a * a * (cy * cy - r * r)
    let disc = qb * qb - 4.0 * qa * qc
    if disc < -@util.EPS {
      return result
    }
    if disc < @util.EPS {
      let y = -qb / (2.0 * qa)
      let x = -(b * y + c) / a
      result.push(Pt2::new(x, y))
    } else {
      let sq = disc.sqrt()
      let y1 = (-qb + sq) / (2.0 * qa)
      let y2 = (-qb - sq) / (2.0 * qa)
      let x1 = -(b * y1 + c) / a
      let x2 = -(b * y2 + c) / a
      result.push(Pt2::new(x1, y1))
      result.push(Pt2::new(x2, y2))
    }
  } else {
    let e = c + b * cy
    let qa = aabb
    let qb = 2.0 * a * e - 2.0 * b * b * cx
    let qc = e * e + b * b * (cx * cx - r * r)
    let disc = qb * qb - 4.0 * qa * qc
    if disc < -@util.EPS {
      return result
    }
    if disc < @util.EPS {
      let x = -qb / (2.0 * qa)
      let y = -(a * x + c) / b
      result.push(Pt2::new(x, y))
    } else {
      let sq = disc.sqrt()
      let x1 = (-qb + sq) / (2.0 * qa)
      let x2 = (-qb - sq) / (2.0 * qa)
      let y1 = -(a * x1 + c) / b
      let y2 = -(a * x2 + c) / b
      result.push(Pt2::new(x1, y1))
      result.push(Pt2::new(x2, y2))
    }
  }
  result
}

///|
/// 两圆求交
/// 利用幂定理：两圆方程相减得根轴（直线），再求直线与圆的交点
/// 返回交点数组（0/1/2 个点）
pub fn intersect_circle_circle(c1 : Circle, c2 : Circle) -> Array[Pt2] {
  let cx1 = c1.cx()
  let cy1 = c1.cy()
  let r1 = c1.r()
  let cx2 = c2.cx()
  let cy2 = c2.cy()
  let r2 = c2.r()
  let a = 2.0 * (cx2 - cx1)
  let b = 2.0 * (cy2 - cy1)
  let c = cx1 * cx1 + cy1 * cy1 - r1 * r1 - cx2 * cx2 - cy2 * cy2 + r2 * r2
  if @util.dbl_approx_eq(a, 0.0, @util.EPS) &&
    @util.dbl_approx_eq(b, 0.0, @util.EPS) {
    return []
  }
  let radical_line = Line2::new(a, b, c)
  intersect_line_circle(radical_line, c1)
}
