// draw 包白盒测试
// 覆盖 Style / Canvas2 / Canvas3 全部公开 API

///|
fn approx(a : Double, b : Double, tol : Double) -> Bool {
  (a - b).abs() < tol
}

///|
test "Style::default 基本字段" {
  let s = Style::default()
  assert_true(s.stroke is Some(_))
  assert_true(s.fill is None)
  assert_true(approx(s.stroke_width, 1.0, 0.000001))
  assert_true(approx(s.font_size, 12.0, 0.000001))
  assert_true(approx(s.opacity, 1.0, 0.000001))
}

///|
test "Style::with_stroke 设置颜色和线宽" {
  let s = Style::default().with_stroke("red", 3.0)
  assert_true(s.stroke is Some(_))
  assert_true(approx(s.stroke_width, 3.0, 0.000001))
}

///|
test "Style::with_fill 设置填充" {
  let s = Style::default().with_fill("blue")
  assert_true(s.fill is Some(_))
}

///|
test "Style::with_dash 设置虚线" {
  let s = Style::default().with_dash("5,3")
  assert_true(s.stroke_dasharray is Some(_))
}

///|
test "Style::with_opacity 设置透明度" {
  let s = Style::default().with_opacity(0.5)
  assert_true(approx(s.opacity, 0.5, 0.000001))
}

///|
test "Style::no_stroke 清除线条" {
  let s = Style::default().no_stroke()
  assert_true(s.stroke is None)
}

///|
test "Style::no_fill 清除填充" {
  let s = Style::default().with_fill("red").no_fill()
  assert_true(s.fill is None)
}

///|
test "Style::to_svg_attrs 默认样式" {
  let attrs = Style::default().to_svg_attrs()
  assert_true(attrs.contains("stroke=\"black\""))
  assert_true(attrs.contains("fill=\"none\""))
}

///|
test "Style::to_svg_attrs 带填充" {
  let attrs = Style::default().with_fill("red").to_svg_attrs()
  assert_true(attrs.contains("fill=\"red\""))
}

///|
test "Style::to_svg_attrs 无线条" {
  let attrs = Style::default().no_stroke().to_svg_attrs()
  assert_true(attrs.contains("stroke=\"none\""))
}

///|
test "Style::to_svg_attrs 带虚线" {
  let attrs = Style::default().with_dash("5,3").to_svg_attrs()
  assert_true(attrs.contains("stroke-dasharray=\"5,3\""))
}

///|
test "Style::to_svg_attrs 带透明度" {
  let attrs = Style::default().with_opacity(0.5).to_svg_attrs()
  assert_true(attrs.contains("opacity=\"0.5\""))
}

///|
test "Style::to_svg_attrs 满透明度无opacity属性" {
  let attrs = Style::default().to_svg_attrs()
  assert_true(not(attrs.contains("opacity")))
}

///|
test "Canvas2::new 创建画布" {
  let c = Canvas2::new(800.0, 600.0)
  assert_eq(c.element_count(), 0)
}

///|
test "Canvas2::with_background 设置背景" {
  let c = Canvas2::new(800.0, 600.0).with_background("white")
  let svg = c.to_svg()
  assert_true(svg.contains("fill=\"white\""))
}

///|
test "Canvas2::draw_line 画线段" {
  let c = Canvas2::new(100.0, 100.0).draw_line(
    10.0,
    20.0,
    30.0,
    40.0,
    Style::default(),
  )
  assert_eq(c.element_count(), 1)
}

///|
test "Canvas2::draw_rect 画矩形" {
  let c = Canvas2::new(100.0, 100.0).draw_rect(
    10.0,
    20.0,
    30.0,
    40.0,
    Style::default(),
  )
  assert_eq(c.element_count(), 1)
}

///|
test "Canvas2::draw_circle 画圆" {
  let c = Canvas2::new(100.0, 100.0).draw_circle(
    50.0,
    50.0,
    10.0,
    Style::default(),
  )
  assert_eq(c.element_count(), 1)
}

///|
test "Canvas2::draw_polygon 画多边形" {
  let coords = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0), (0.0, 10.0)]
  let c = Canvas2::new(100.0, 100.0).draw_polygon(coords, Style::default())
  assert_eq(c.element_count(), 1)
}

///|
test "Canvas2::draw_polyline 画折线" {
  let coords = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0)]
  let c = Canvas2::new(100.0, 100.0).draw_polyline(coords, Style::default())
  assert_eq(c.element_count(), 1)
}

///|
test "Canvas2::draw_text 画文本" {
  let c = Canvas2::new(100.0, 100.0).draw_text(
    10.0,
    20.0,
    "hello",
    Style::default(),
  )
  assert_eq(c.element_count(), 1)
}

///|
test "Canvas2::to_svg 基本结构" {
  let c = Canvas2::new(800.0, 600.0)
  let svg = c.to_svg()
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("width=\"800\""))
  assert_true(svg.contains("height=\"600\""))
  assert_true(svg.contains("</svg>"))
}

///|
test "Canvas2::to_svg 包含线段" {
  let c = Canvas2::new(100.0, 100.0).draw_line(
    10.0,
    20.0,
    30.0,
    40.0,
    Style::default(),
  )
  let svg = c.to_svg()
  assert_true(svg.contains("<line"))
  assert_true(svg.contains("x1=\"10\""))
  assert_true(svg.contains("x2=\"30\""))
}

///|
test "Canvas2::to_svg 包含矩形" {
  let c = Canvas2::new(100.0, 100.0).draw_rect(
    10.0,
    20.0,
    30.0,
    40.0,
    Style::default(),
  )
  let svg = c.to_svg()
  assert_true(svg.contains("<rect"))
  assert_true(svg.contains("width=\"30\""))
}

///|
test "Canvas2::to_svg 包含圆" {
  let c = Canvas2::new(100.0, 100.0).draw_circle(
    50.0,
    50.0,
    10.0,
    Style::default(),
  )
  let svg = c.to_svg()
  assert_true(svg.contains("<circle"))
  assert_true(svg.contains("r=\"10\""))
}

///|
test "Canvas2::to_svg 包含多边形" {
  let coords = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0)]
  let c = Canvas2::new(100.0, 100.0).draw_polygon(coords, Style::default())
  let svg = c.to_svg()
  assert_true(svg.contains("<polygon"))
  assert_true(svg.contains("points="))
}

///|
test "Canvas2::to_svg 包含折线" {
  let coords = [(0.0, 0.0), (10.0, 0.0), (10.0, 10.0)]
  let c = Canvas2::new(100.0, 100.0).draw_polyline(coords, Style::default())
  let svg = c.to_svg()
  assert_true(svg.contains("<polyline"))
}

///|
test "Canvas2::to_svg 包含文本" {
  let c = Canvas2::new(100.0, 100.0).draw_text(
    10.0,
    20.0,
    "hello",
    Style::default(),
  )
  let svg = c.to_svg()
  assert_true(svg.contains("<text"))
  assert_true(svg.contains("hello"))
  assert_true(svg.contains("</text>"))
}

///|
test "Canvas2::to_svg 包含背景" {
  let c = Canvas2::new(100.0, 100.0).with_background("white")
  let svg = c.to_svg()
  assert_true(svg.contains("fill=\"white\""))
}

///|
test "Canvas2 多元素组合" {
  let c = Canvas2::new(200.0, 200.0)
    .draw_line(0.0, 0.0, 100.0, 100.0, Style::default())
    .draw_circle(50.0, 50.0, 20.0, Style::default())
    .draw_rect(10.0, 10.0, 30.0, 30.0, Style::default())
  assert_eq(c.element_count(), 3)
}

///|
test "Canvas2 不可变性" {
  let c1 = Canvas2::new(100.0, 100.0)
  let c2 = c1.draw_line(0.0, 0.0, 10.0, 10.0, Style::default())
  assert_eq(c1.element_count(), 0)
  assert_eq(c2.element_count(), 1)
}

///|
test "Point3::new 创建3D点" {
  let p = Point3::new(1.0, 2.0, 3.0)
  assert_true(approx(p.x, 1.0, 0.000001))
  assert_true(approx(p.y, 2.0, 0.000001))
  assert_true(approx(p.z, 3.0, 0.000001))
}

///|
test "View3::default 默认视图" {
  let v = View3::default()
  assert_true(approx(v.eye_x, 5.0, 0.000001))
  assert_true(approx(v.fov, 60.0, 0.000001))
  assert_true(approx(v.aspect, 1.0, 0.000001))
}

///|
test "Canvas3::new 创建3D画布" {
  let c = Canvas3::new()
  assert_eq(c.element_count(), 0)
}

///|
test "Canvas3::with_view 设置视图" {
  let v = View3::default()
  let c = Canvas3::new().with_view(v)
  let svg = c.to_svg(100.0, 100.0)
  assert_true(svg.contains("<svg"))
}

///|
test "Canvas3::draw_line 画3D线段" {
  let c = Canvas3::new().draw_line(
    Point3::new(0.0, 0.0, 0.0),
    Point3::new(1.0, 1.0, 1.0),
    Style::default(),
  )
  assert_eq(c.element_count(), 1)
}

///|
test "Canvas3::draw_point 画3D点" {
  let c = Canvas3::new().draw_point(
    Point3::new(0.0, 0.0, 0.0),
    5.0,
    Style::default(),
  )
  assert_eq(c.element_count(), 1)
}

///|
test "Canvas3::project 透视投影基本" {
  let c = Canvas3::new()
  let (px, py) = c.project(Point3::new(0.0, 0.0, 0.0), 100.0, 100.0)
  assert_true(px >= 0.0)
  assert_true(px <= 100.0)
  assert_true(py >= 0.0)
  assert_true(py <= 100.0)
}

///|
test "Canvas3::project 近点返回中心" {
  let c = Canvas3::new()
  let (px, py) = c.project(Point3::new(5.0, 5.0, 5.0), 100.0, 100.0)
  assert_true(approx(px, 50.0, 0.01))
  assert_true(approx(py, 50.0, 0.01))
}

///|
test "Canvas3::to_svg 基本结构" {
  let c = Canvas3::new().draw_line(
    Point3::new(0.0, 0.0, 0.0),
    Point3::new(1.0, 0.0, 0.0),
    Style::default(),
  )
  let svg = c.to_svg(200.0, 200.0)
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("</svg>"))
  assert_true(svg.contains("<line"))
}

///|
test "Canvas3::to_svg 包含背景" {
  let c = Canvas3::new()
  let svg = c.to_svg(100.0, 100.0)
  assert_true(svg.contains("fill=\"white\""))
}

///|
test "Canvas3::draw_axes 绘制坐标轴" {
  let c = Canvas3::new().draw_axes(2.0)
  assert_eq(c.element_count(), 3)
}

///|
test "Canvas3::draw_cube 绘制立方体" {
  let c = Canvas3::new().draw_cube(0.0, 0.0, 0.0, 2.0, Style::default())
  assert_eq(c.element_count(), 12)
}

///|
test "Canvas3::draw_cube 立方体SVG输出" {
  let c = Canvas3::new().draw_cube(0.0, 0.0, 0.0, 2.0, Style::default())
  let svg = c.to_svg(300.0, 300.0)
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("<line"))
}

///|
test "Canvas3 不可变性" {
  let c1 = Canvas3::new()
  let c2 = c1.draw_line(
    Point3::new(0.0, 0.0, 0.0),
    Point3::new(1.0, 0.0, 0.0),
    Style::default(),
  )
  assert_eq(c1.element_count(), 0)
  assert_eq(c2.element_count(), 1)
}

///|
test "Canvas3::project 透视收缩" {
  let c = Canvas3::new()
  let (px_near, _) = c.project(Point3::new(2.0, 2.0, 2.0), 100.0, 100.0)
  let (px_far, _) = c.project(Point3::new(1.0, 1.0, 1.0), 100.0, 100.0)
  let dist_near = (px_near - 50.0).abs()
  let dist_far = (px_far - 50.0).abs()
  assert_true(dist_near <= dist_far + 0.01)
}

///|
test "Canvas2::to_svg 空画布" {
  let c = Canvas2::new(100.0, 100.0)
  let svg = c.to_svg()
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("</svg>"))
}

///|
test "Canvas3::to_svg 空画布" {
  let c = Canvas3::new()
  let svg = c.to_svg(100.0, 100.0)
  assert_true(svg.contains("<svg"))
  assert_true(svg.contains("</svg>"))
}

///|
test "Style 链式调用" {
  let s = Style::default()
    .with_stroke("red", 2.0)
    .with_fill("blue")
    .with_opacity(0.7)
  let attrs = s.to_svg_attrs()
  assert_true(attrs.contains("stroke=\"red\""))
  assert_true(attrs.contains("fill=\"blue\""))
  assert_true(attrs.contains("opacity=\"0.7\""))
}

///|
test "Canvas2 多边形坐标格式" {
  let coords = [(1.0, 2.0), (3.0, 4.0)]
  let c = Canvas2::new(100.0, 100.0).draw_polygon(coords, Style::default())
  let svg = c.to_svg()
  assert_true(svg.contains("points="))
  assert_true(svg.contains("1,2"))
  assert_true(svg.contains("3,4"))
}

///|
test "Canvas3::draw_axes SVG输出含三色" {
  let c = Canvas3::new().draw_axes(2.0)
  let svg = c.to_svg(200.0, 200.0)
  assert_true(svg.contains("red"))
  assert_true(svg.contains("green"))
  assert_true(svg.contains("blue"))
}
