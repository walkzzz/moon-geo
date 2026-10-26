// 性能基准：凸包

///|
test "bench convex_hull (100 points on circle)" (it : @bench.T) {
  let pts : Array[@alg.Pt2] = []
  let n : Int32 = 100
  for i in 0..<n {
    let angle = i.to_double() * 6.283185307179586 / n.to_double()
    pts.push(@alg.Pt2::new(@math.cos(angle) * 10.0, @math.sin(angle) * 10.0))
  }
  it.bench(fn() {
    let r = convex_hull(pts)
    it.keep(r)
  })
}

///|
test "bench convex_hull (1000 points on circle)" (it : @bench.T) {
  let pts : Array[@alg.Pt2] = []
  let n : Int32 = 1000
  for i in 0..<n {
    let angle = i.to_double() * 6.283185307179586 / n.to_double()
    pts.push(@alg.Pt2::new(@math.cos(angle) * 10.0, @math.sin(angle) * 10.0))
  }
  it.bench(fn() {
    let r = convex_hull(pts)
    it.keep(r)
  })
}

///|
test "bench convex_hull (1000 random-ish points)" (it : @bench.T) {
  let pts : Array[@alg.Pt2] = []
  let n : Int32 = 1000
  for i in 0..<n {
    let x = (i * 37 % 100).to_double()
    let y = (i * 53 % 100).to_double()
    pts.push(@alg.Pt2::new(x, y))
  }
  it.bench(fn() {
    let r = convex_hull(pts)
    it.keep(r)
  })
}
