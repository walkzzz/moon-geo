// 3D 线框画布
// draw 层，依赖 math（3D 投影三角函数）
// 3D 线框 + 透视投影 → SVG 输出

///|
/// 3D 点
pub struct Point3 {
  x : Double
  y : Double
  z : Double
}

///|
pub fn Point3::new(x : Double, y : Double, z : Double) -> Point3 {
  { x, y, z, }
}

///|
/// 3D 视图参数
pub struct View3 {
  eye_x : Double
  eye_y : Double
  eye_z : Double
  target_x : Double
  target_y : Double
  target_z : Double
  up_x : Double
  up_y : Double
  up_z : Double
  fov : Double
  aspect : Double
  near : Double
  far : Double
}

///|
/// 默认 3D 视图
pub fn View3::default() -> View3 {
  {
    eye_x: 5.0,
    eye_y: 5.0,
    eye_z: 5.0,
    target_x: 0.0,
    target_y: 0.0,
    target_z: 0.0,
    up_x: 0.0,
    up_y: 0.0,
    up_z: 1.0,
    fov: 60.0,
    aspect: 1.0,
    near: 0.1,
    far: 100.0,
  }
}

///|
/// 线框元素
pub enum WireElement {
  Line3(Point3, Point3, Style)
  Point3D(Point3, Double, Style)
}

///|
/// 3D 线框画布
pub struct Canvas3 {
  elements : Array[WireElement]
  view : View3
}

///|
/// 创建 3D 画布
pub fn Canvas3::new() -> Canvas3 {
  { elements: [], view: View3::default(), }
}

///|
/// 设置视图
pub fn Canvas3::with_view(self : Canvas3, view : View3) -> Canvas3 {
  { ..self, view, }
}

///|
/// 画 3D 线段
pub fn Canvas3::draw_line(
  self : Canvas3,
  p1 : Point3,
  p2 : Point3,
  style : Style,
) -> Canvas3 {
  let new_elements = copy_wire_elements(self.elements)
  new_elements.push(WireElement::Line3(p1, p2, style))
  { ..self, elements: new_elements, }
}

///|
/// 画 3D 点
pub fn Canvas3::draw_point(
  self : Canvas3,
  p : Point3,
  size : Double,
  style : Style,
) -> Canvas3 {
  let new_elements = copy_wire_elements(self.elements)
  new_elements.push(WireElement::Point3D(p, size, style))
  { ..self, elements: new_elements, }
}

///|
/// 元素数量
pub fn Canvas3::element_count(self : Canvas3) -> Int32 {
  self.elements.length()
}

///|
/// 简单透视投影：3D 点 → 2D 屏幕坐标
/// 使用简化的针孔相机模型
pub fn Canvas3::project(
  self : Canvas3,
  p : Point3,
  width : Double,
  height : Double,
) -> (Double, Double) {
  let v = self.view
  let dx = p.x - v.eye_x
  let dy = p.y - v.eye_y
  let dz = p.z - v.eye_z
  let fx = v.target_x - v.eye_x
  let fy = v.target_y - v.eye_y
  let fz = v.target_z - v.eye_z
  let flen = (fx * fx + fy * fy + fz * fz).sqrt()
  let fxn = fx / flen
  let fyn = fy / flen
  let fzn = fz / flen
  let depth = dx * fxn + dy * fyn + dz * fzn
  if depth < 0.001 {
    return (width / 2.0, height / 2.0)
  }
  let rad = v.fov * @math.PI / 180.0
  let f = 1.0 / @math.tan(rad / 2.0)
  let rx = dx - depth * fxn
  let ry = dy - depth * fyn
  let rz = dz - depth * fzn
  let ux = v.up_x
  let uy = v.up_y
  let uz = v.up_z
  let ulen = (ux * ux + uy * uy + uz * uz).sqrt()
  let uxn = ux / ulen
  let uyn = uy / ulen
  let uzn = uz / ulen
  let right_x = fyn * uzn - fzn * uyn
  let right_y = fzn * uxn - fxn * uzn
  let right_z = fxn * uyn - fyn * uxn
  let screen_x = (rx * right_x + ry * right_y + rz * right_z) * f / depth
  let screen_y = (rx * uxn + ry * uyn + rz * uzn) * f / depth
  let px = (screen_x * v.aspect + 1.0) * width / 2.0
  let py = (1.0 - screen_y) * height / 2.0
  (px, py)
}

///|
/// 生成 SVG 字符串（将 3D 线框投影到 2D）
pub fn Canvas3::to_svg(
  self : Canvas3,
  width : Double,
  height : Double,
) -> String {
  let canvas2 = Canvas2::new(width, height).with_background("white")
  let mut c2 = canvas2
  for elem in self.elements {
    match elem {
      Line3(p1, p2, style) => {
        let (x1, y1) = self.project(p1, width, height)
        let (x2, y2) = self.project(p2, width, height)
        c2 = c2.draw_line(x1, y1, x2, y2, style)
      }
      Point3D(p, size, style) => {
        let (x, y) = self.project(p, width, height)
        c2 = c2.draw_circle(x, y, size, style)
      }
    }
  }
  c2.to_svg()
}

///|
/// 绘制坐标轴
pub fn Canvas3::draw_axes(self : Canvas3, length : Double) -> Canvas3 {
  let red = Style::default().with_stroke("red", 2.0)
  let green = Style::default().with_stroke("green", 2.0)
  let blue = Style::default().with_stroke("blue", 2.0)
  self
  .draw_line(Point3::new(0.0, 0.0, 0.0), Point3::new(length, 0.0, 0.0), red)
  .draw_line(Point3::new(0.0, 0.0, 0.0), Point3::new(0.0, length, 0.0), green)
  .draw_line(Point3::new(0.0, 0.0, 0.0), Point3::new(0.0, 0.0, length), blue)
}

///|
/// 绘制立方体线框
pub fn Canvas3::draw_cube(
  self : Canvas3,
  cx : Double,
  cy : Double,
  cz : Double,
  size : Double,
  style : Style,
) -> Canvas3 {
  let s = size / 2.0
  let v000 = Point3::new(cx - s, cy - s, cz - s)
  let v100 = Point3::new(cx + s, cy - s, cz - s)
  let v010 = Point3::new(cx - s, cy + s, cz - s)
  let v110 = Point3::new(cx + s, cy + s, cz - s)
  let v001 = Point3::new(cx - s, cy - s, cz + s)
  let v101 = Point3::new(cx + s, cy - s, cz + s)
  let v011 = Point3::new(cx - s, cy + s, cz + s)
  let v111 = Point3::new(cx + s, cy + s, cz + s)
  self
  .draw_line(v000, v100, style)
  .draw_line(v100, v110, style)
  .draw_line(v110, v010, style)
  .draw_line(v010, v000, style)
  .draw_line(v001, v101, style)
  .draw_line(v101, v111, style)
  .draw_line(v111, v011, style)
  .draw_line(v011, v001, style)
  .draw_line(v000, v001, style)
  .draw_line(v100, v101, style)
  .draw_line(v110, v111, style)
  .draw_line(v010, v011, style)
}

///|
fn copy_wire_elements(elements : Array[WireElement]) -> Array[WireElement] {
  let result : Array[WireElement] = []
  for e in elements {
    result.push(e)
  }
  result
}
