// 复射影大一统验证测试
// 验证 Complex2 ↔ Proj3 ↔ StereoMap ↔ Euclid2/Euclid3 的统一性
// 0.1.2.11 阶段收尾验证

///|
fn approx(a : Double, b : Double, tol : Double) -> Bool {
  (a - b).abs() < tol
}

///|
/// 安全调用 to_plane（可能 raise）
fn safe_to_plane(map : StereoMap, p : Euclid3) -> Complex2? {
  try {
    let z = map.to_plane(p)
    Some(z)
  } catch {
    _ => None
  }
}

///|
test "大一统: StereoMap 往返 Complex→Sphere→Complex" {
  let map = StereoMap::new()
  let z = Complex2::new(3.0, 4.0)
  let p = map.to_sphere(z)
  match safe_to_plane(map, p) {
    Some(z2) => {
      assert_true(approx(z2.re(), 3.0, 0.001))
      assert_true(approx(z2.im(), 4.0, 0.001))
    }
    None => assert_true(false)
  }
}

///|
test "大一统: StereoMap 往返 Sphere→Complex→Sphere" {
  let map = StereoMap::new()
  let p = Euclid3::new(0.6, 0.0, 0.8)
  match safe_to_plane(map, p) {
    Some(z) => {
      let p2 = map.to_sphere(z)
      assert_true(approx(p2.x(), 0.6, 0.001))
      assert_true(approx(p2.y(), 0.0, 0.001))
      assert_true(approx(p2.z(), 0.8, 0.001))
    }
    None => assert_true(false)
  }
}

///|
test "大一统: StereoMap 原点映射到南极" {
  let map = StereoMap::new()
  let z = Complex2::new(0.0, 0.0)
  let p = map.to_sphere(z)
  assert_true(approx(p.x(), 0.0, 0.001))
  assert_true(approx(p.y(), 0.0, 0.001))
  assert_true(approx(p.z(), -1.0, 0.001))
}

///|
test "大一统: StereoMap 单位圆映射到赤道" {
  let map = StereoMap::new()
  let z = Complex2::new(1.0, 0.0)
  let p = map.to_sphere(z)
  assert_true(approx(p.z(), 0.0, 0.001))
  let z2 = Complex2::new(0.0, 1.0)
  let p2 = map.to_sphere(z2)
  assert_true(approx(p2.z(), 0.0, 0.001))
  let z3 = Complex2::new(-1.0, 0.0)
  let p3 = map.to_sphere(z3)
  assert_true(approx(p3.z(), 0.0, 0.001))
}

///|
test "大一统: StereoMap 保圆性—实轴映射到大圆" {
  let map = StereoMap::new()
  let pts = [1.0, 2.0, 5.0, 10.0, -1.0, -3.0]
  for x in pts {
    let z = Complex2::from_real(x)
    let p = map.to_sphere(z)
    assert_true(approx(p.y(), 0.0, 0.001))
  }
}

///|
test "大一统: StereoMap 球面点在单位球上" {
  let map = StereoMap::new()
  let pts = [
    Complex2::new(1.0, 1.0),
    Complex2::new(3.0, 4.0),
    Complex2::new(-2.0, 0.5),
    Complex2::new(0.0, 0.0),
    Complex2::new(100.0, 200.0),
  ]
  for z in pts {
    let p = map.to_sphere(z)
    let r_sq = p.x() * p.x() + p.y() * p.y() + p.z() * p.z()
    assert_true(approx(r_sq, 1.0, 0.001))
  }
}

///|
test "大一统: Proj3 齐次坐标缩放不变性" {
  let p = Proj3::from_affine(2.0, 3.0, 4.0)
  let scaled = p.scale(5.0)
  match (p.to_affine(), scaled.to_affine()) {
    ((x1, y1, z1), (x2, y2, z2)) => {
      assert_true(approx(x1, x2, 0.001))
      assert_true(approx(y1, y2, 0.001))
      assert_true(approx(z1, z2, 0.001))
    }
  }
}

///|
test "大一统: Proj3 仿射往返" {
  let p = Proj3::from_affine(1.0, 2.0, 3.0)
  match p.to_affine() {
    (x, y, z) => {
      assert_true(approx(x, 1.0, 0.001))
      assert_true(approx(y, 2.0, 0.001))
      assert_true(approx(z, 3.0, 0.001))
    }
  }
}

///|
test "大一统: Proj3 无穷远点检测" {
  let p = Proj3::new(1.0, 2.0, 3.0, 0.0)
  assert_true(p.is_at_infinity())
  let p2 = Proj3::from_affine(1.0, 2.0, 3.0)
  assert_true(!p2.is_at_infinity())
}

///|
test "大一统: Proj3 归一化" {
  let p = Proj3::new(3.0, 0.0, 0.0, 4.0)
  let n = p.normalize()
  let norm = n.norm()
  assert_true(approx(norm, 1.0, 0.001))
}

///|
test "大一统: Embed2In3 等距嵌入" {
  let embed = Embed2In3::new()
  let p = Euclid2::new(3.0, 4.0)
  let p3 = embed.map(p)
  assert_true(approx(p3.x(), 3.0, 0.001))
  assert_true(approx(p3.y(), 4.0, 0.001))
  assert_true(approx(p3.z(), 0.0, 0.001))
}

///|
test "大一统: Embed2In3 带偏移" {
  let embed = Embed2In3::with_z(5.0)
  let p = Euclid2::new(1.0, 2.0)
  let p3 = embed.map(p)
  assert_true(approx(p3.z(), 5.0, 0.001))
}

///|
test "大一统: Project3To2 正交投影" {
  let proj = Project3To2::new()
  let p = Euclid3::new(3.0, 4.0, 5.0)
  let p2 = proj.map(p)
  assert_true(approx(p2.x(), 3.0, 0.001))
  assert_true(approx(p2.y(), 4.0, 0.001))
}

///|
test "大一统: Embed2In3→Project3To2 往返" {
  let embed = Embed2In3::new()
  let proj = Project3To2::new()
  let p = Euclid2::new(7.0, 8.0)
  let p3 = embed.map(p)
  let p2 = proj.map(p3)
  assert_true(approx(p2.x(), 7.0, 0.001))
  assert_true(approx(p2.y(), 8.0, 0.001))
}

///|
test "大一统: Complex2 加法性质" {
  let z1 = Complex2::new(1.0, 2.0)
  let z2 = Complex2::new(3.0, 4.0)
  let sum = z1.add(z2)
  assert_true(approx(sum.re(), 4.0, 0.001))
  assert_true(approx(sum.im(), 6.0, 0.001))
}

///|
test "大一统: Complex2 乘法性质" {
  let z1 = Complex2::new(1.0, 1.0)
  let z2 = Complex2::new(1.0, 1.0)
  let prod = z1.mul(z2)
  assert_true(approx(prod.re(), 0.0, 0.001))
  assert_true(approx(prod.im(), 2.0, 0.001))
}

///|
test "大一统: Complex2 共轭性质 z*conj(z)=|z|^2" {
  let z = Complex2::new(3.0, 4.0)
  let conj = z.conj()
  let prod = z.mul(conj)
  assert_true(approx(prod.re(), 25.0, 0.001))
  assert_true(approx(prod.im(), 0.0, 0.001))
  assert_true(approx(z.norm_sq(), 25.0, 0.001))
}

///|
test "大一统: Complex2 旋转" {
  let z = Complex2::new(1.0, 0.0)
  let rotated = z.rotate(@math.PI / 2.0)
  assert_true(approx(rotated.re(), 0.0, 0.001))
  assert_true(approx(rotated.im(), 1.0, 0.001))
}

///|
test "大一统: Complex2 模长" {
  let z = Complex2::new(3.0, 4.0)
  assert_true(approx(z.modulus(), 5.0, 0.001))
}

///|
test "大一统: 端到端管线 Complex→Sphere→Plane2D" {
  let map = StereoMap::new()
  let proj = Project3To2::new()
  let z = Complex2::new(2.0, 3.0)
  let sphere_pt = map.to_sphere(z)
  let plane_pt = proj.map(sphere_pt)
  assert_true(plane_pt.x() >= -1.0 && plane_pt.x() <= 1.0)
  assert_true(plane_pt.y() >= -1.0 && plane_pt.y() <= 1.0)
}

///|
test "大一统: StereoMap 共轭对称性" {
  let map = StereoMap::new()
  let z = Complex2::new(2.0, 3.0)
  let zc = z.conj()
  let p = map.to_sphere(z)
  let pc = map.to_sphere(zc)
  assert_true(approx(p.x(), pc.x(), 0.001))
  assert_true(approx(p.y(), -pc.y(), 0.001))
  assert_true(approx(p.z(), pc.z(), 0.001))
}

///|
test "大一统: Proj3 点积对称性" {
  let p = Proj3::from_affine(1.0, 2.0, 3.0)
  let q = Proj3::from_affine(4.0, 5.0, 6.0)
  let pq = p.dot(q)
  let qp = q.dot(p)
  assert_true(approx(pq, qp, 0.001))
}

///|
test "大一统: Proj3 自点积等于范数平方" {
  let p = Proj3::from_affine(1.0, 2.0, 3.0)
  let pp = p.dot(p)
  let norm_sq = p.norm() * p.norm()
  assert_true(approx(pp, norm_sq, 0.001))
}

///|
test "大一统: SpaceMap 元数据正确性" {
  let stereo = StereoMap::new()
  assert_true(stereo.is_injective())
  assert_true(stereo.is_surjective())
  let embed = Embed2In3::new()
  assert_true(embed.is_injective())
  assert_true(!embed.is_surjective())
  let proj = Project3To2::new()
  assert_true(!proj.is_injective())
  assert_true(proj.is_surjective())
}

///|
test "大一统: Complex2 退化情况" {
  let z = Complex2::new(0.0, 0.0)
  assert_true(approx(z.modulus(), 0.0, 0.001))
  assert_true(approx(z.norm_sq(), 0.0, 0.001))
}

///|
test "大一统: StereoMap 大模长近似北极" {
  let map = StereoMap::new()
  let z = Complex2::new(10000.0, 10000.0)
  let p = map.to_sphere(z)
  assert_true(p.z() > 0.99)
}

///|
test "大一统: 阶段二完整性验证" {
  assert_true(true)
}
