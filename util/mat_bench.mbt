// 性能基准：Mat4 矩阵运算
// 2.8 性能基准

///|
test "bench Mat4::mul_mat (identity x identity)" (it : @bench.T) {
  let a = Mat4::identity()
  let b = Mat4::identity()
  it.bench(fn() {
    let r = a.mul_mat(b)
    it.keep(r)
  })
}

///|
test "bench Mat4::mul_mat (general x general)" (it : @bench.T) {
  let a = Mat4::new(
    1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0,
    16.0,
  )
  let b = Mat4::new(
    16.0, 15.0, 14.0, 13.0, 12.0, 11.0, 10.0, 9.0, 8.0, 7.0, 6.0, 5.0, 4.0, 3.0,
    2.0, 1.0,
  )
  it.bench(fn() {
    let r = a.mul_mat(b)
    it.keep(r)
  })
}

///|
test "bench Mat4::inv (identity)" (it : @bench.T) {
  let m = Mat4::identity()
  it.bench(fn() {
    try {
      let r = m.inv()
      it.keep(r)
    } catch {
      _ => it.keep(0)
    }
  })
}

///|
test "bench Mat4::inv (general)" (it : @bench.T) {
  let m = Mat4::new(
    4.0, 0.0, 0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 8.0,
  )
  it.bench(fn() {
    try {
      let r = m.inv()
      it.keep(r)
    } catch {
      _ => it.keep(0)
    }
  })
}

///|
test "bench Mat4::inv (near-singular diagonal)" (it : @bench.T) {
  let m = Mat4::new(
    1.0e8, 0.0, 0.0, 0.0, 0.0, 1.0e6, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0,
    1.0,
  )
  it.bench(fn() {
    try {
      let r = m.inv()
      it.keep(r)
    } catch {
      _ => it.keep(0)
    }
  })
}
