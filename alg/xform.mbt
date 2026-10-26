// 仿射变换
// 第2层 alg，依赖 util, atop, space
// Transform2: 2D 仿射变换（Mat3 齐次坐标）
// Transform3: 3D 仿射变换（Mat4 齐次坐标）

///|
/// 二维仿射变换
pub struct Transform2 {
  m : @util.Mat3
}

///|
pub fn Transform2::identity() -> Transform2 {
  { m: @util.Mat3::identity(), }
}

///|
/// 平移变换
pub fn Transform2::translation(tx : Double, ty : Double) -> Transform2 {
  { m: @util.Mat3::new(1.0, 0.0, tx, 0.0, 1.0, ty, 0.0, 0.0, 1.0), }
}

///|
/// 缩放变换
pub fn Transform2::scaling(sx : Double, sy : Double) -> Transform2 {
  { m: @util.Mat3::new(sx, 0.0, 0.0, 0.0, sy, 0.0, 0.0, 0.0, 1.0), }
}

///|
/// 旋转变换（弧度）
pub fn Transform2::rotation(angle : Double) -> Transform2 {
  let c = @math.cos(angle)
  let s = @math.sin(angle)
  { m: @util.Mat3::new(c, -s, 0.0, s, c, 0.0, 0.0, 0.0, 1.0), }
}

///|
/// 从矩阵构造
pub fn Transform2::from_matrix(m : @util.Mat3) -> Transform2 {
  { m, }
}

///|
/// 应用变换到点
pub fn Transform2::apply(self : Transform2, p : Pt2) -> Pt2 {
  let v = @util.Vec3::new(p.x(), p.y(), 1.0)
  let r = self.m.mul_vec(v)
  Pt2::new(r.x, r.y)
}

///|
/// 复合变换（self 后 other = other ∘ self）
pub fn Transform2::compose(self : Transform2, other : Transform2) -> Transform2 {
  { m: other.m.mul_mat(self.m), }
}

///|
/// 三维仿射变换
pub struct Transform3 {
  m : @util.Mat4
}

///|
pub fn Transform3::identity() -> Transform3 {
  { m: @util.Mat4::identity(), }
}

///|
/// 平移变换
pub fn Transform3::translation(
  tx : Double,
  ty : Double,
  tz : Double,
) -> Transform3 {
  { m: @util.Mat4::translation(tx, ty, tz), }
}

///|
/// 缩放变换
pub fn Transform3::scaling(sx : Double, sy : Double, sz : Double) -> Transform3 {
  { m: @util.Mat4::scaling(sx, sy, sz), }
}

///|
/// 绕 X 轴旋转
pub fn Transform3::rotation_x(angle : Double) -> Transform3 {
  let c = @math.cos(angle)
  let s = @math.sin(angle)
  {
    m: @util.Mat4::new(
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      c,
      -s,
      0.0,
      0.0,
      s,
      c,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
    ),
  }
}

///|
/// 绕 Y 轴旋转
pub fn Transform3::rotation_y(angle : Double) -> Transform3 {
  let c = @math.cos(angle)
  let s = @math.sin(angle)
  {
    m: @util.Mat4::new(
      c,
      0.0,
      s,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      -s,
      0.0,
      c,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
    ),
  }
}

///|
/// 绕 Z 轴旋转
pub fn Transform3::rotation_z(angle : Double) -> Transform3 {
  let c = @math.cos(angle)
  let s = @math.sin(angle)
  {
    m: @util.Mat4::new(
      c,
      -s,
      0.0,
      0.0,
      s,
      c,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
      0.0,
      0.0,
      0.0,
      0.0,
      1.0,
    ),
  }
}

///|
/// 从矩阵构造
pub fn Transform3::from_matrix(m : @util.Mat4) -> Transform3 {
  { m, }
}

///|
/// 应用变换到点
pub fn Transform3::apply(self : Transform3, p : Pt3) -> Pt3 {
  let v = @util.Vec3::new(p.x(), p.y(), p.z())
  let r = self.m.mul_vec(v)
  Pt3::new(r.x, r.y, r.z)
}

///|
/// 复合变换
pub fn Transform3::compose(self : Transform3, other : Transform3) -> Transform3 {
  { m: other.m.mul_mat(self.m), }
}
