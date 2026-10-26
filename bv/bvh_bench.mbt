// 性能基准：BVH 构建
// 2.8 性能基准

///|
test "bench BVHNode::build (16 leaves)" (it : @bench.T) {
  let leaves : Array[(Aabb3, Int32)] = []
  let n : Int32 = 16
  for i in 0..<n {
    let x = i.to_double()
    let aabb = Aabb3::new(x, 0.0, 0.0, x + 1.0, 1.0, 1.0)
    leaves.push((aabb, i))
  }
  it.bench(fn() {
    let r = BVHNode::build(leaves)
    it.keep(r)
  })
}

///|
test "bench BVHNode::build (64 leaves)" (it : @bench.T) {
  let leaves : Array[(Aabb3, Int32)] = []
  let n : Int32 = 64
  for i in 0..<n {
    let x = i.to_double()
    let aabb = Aabb3::new(x, 0.0, 0.0, x + 1.0, 1.0, 1.0)
    leaves.push((aabb, i))
  }
  it.bench(fn() {
    let r = BVHNode::build(leaves)
    it.keep(r)
  })
}

///|
test "bench BVHNode::build (256 leaves)" (it : @bench.T) {
  let leaves : Array[(Aabb3, Int32)] = []
  let n : Int32 = 256
  for i in 0..<n {
    let x = i.to_double()
    let aabb = Aabb3::new(x, 0.0, 0.0, x + 1.0, 1.0, 1.0)
    leaves.push((aabb, i))
  }
  it.bench(fn() {
    let r = BVHNode::build(leaves)
    it.keep(r)
  })
}

///|
test "bench BVHNode::build (3D scattered 128 leaves)" (it : @bench.T) {
  let leaves : Array[(Aabb3, Int32)] = []
  let n : Int32 = 128
  for i in 0..<n {
    let x = (i % 8).to_double()
    let y = (i / 8 % 8).to_double()
    let z = (i / 64 % 8).to_double()
    let aabb = Aabb3::new(x, y, z, x + 0.5, y + 0.5, z + 0.5)
    leaves.push((aabb, i))
  }
  it.bench(fn() {
    let r = BVHNode::build(leaves)
    it.keep(r)
  })
}
