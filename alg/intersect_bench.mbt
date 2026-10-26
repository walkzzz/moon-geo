// 性能基准：代数几何求交运算
// 2.8 性能基准

///|
test "bench intersect_line_circle (2 intersections)" (it : @bench.T) {
  let line = Line2::new(1.0, 0.0, 0.0) // x = 0
  let circle = Circle::new(0.0, 0.0, 1.0) // 单位圆
  it.bench(fn() {
    let r = intersect_line_circle(line, circle)
    it.keep(r)
  })
}

///|
test "bench intersect_line_circle (tangent)" (it : @bench.T) {
  let line = Line2::new(1.0, 0.0, -1.0) // x = 1
  let circle = Circle::new(0.0, 0.0, 1.0)
  it.bench(fn() {
    let r = intersect_line_circle(line, circle)
    it.keep(r)
  })
}

///|
test "bench intersect_circle_circle (2 intersections)" (it : @bench.T) {
  let c1 = Circle::new(0.0, 0.0, 1.0)
  let c2 = Circle::new(1.0, 0.0, 1.0)
  it.bench(fn() {
    let r = intersect_circle_circle(c1, c2)
    it.keep(r)
  })
}

///|
test "bench intersect_circle_circle (tangent)" (it : @bench.T) {
  let c1 = Circle::new(0.0, 0.0, 1.0)
  let c2 = Circle::new(2.0, 0.0, 1.0)
  it.bench(fn() {
    let r = intersect_circle_circle(c1, c2)
    it.keep(r)
  })
}
