// 2D SVG 画布
// draw 层，生成 SVG XML 字符串

///|
/// SVG 元素
pub enum SvgElement {
  Line(Double, Double, Double, Double, Style)
  Rect(Double, Double, Double, Double, Style)
  Circle(Double, Double, Double, Style)
  Ellipse(Double, Double, Double, Double, Style)
  Polygon(Array[(Double, Double)], Style)
  Polyline(Array[(Double, Double)], Style)
  Text(Double, Double, String, Style)
  Group(Array[SvgElement], Style)
}

///|
/// 2D SVG 画布
pub struct Canvas2 {
  width : Double
  height : Double
  elements : Array[SvgElement]
  background : String?
}

///|
/// 创建画布
pub fn Canvas2::new(width : Double, height : Double) -> Canvas2 {
  { width, height, elements: [], background: None, }
}

///|
/// 设置背景色
pub fn Canvas2::with_background(self : Canvas2, color : String) -> Canvas2 {
  { ..self, background: Some(color), }
}

///|
/// 画线段
pub fn Canvas2::draw_line(
  self : Canvas2,
  x1 : Double,
  y1 : Double,
  x2 : Double,
  y2 : Double,
  style : Style,
) -> Canvas2 {
  let new_elements = copy_elements(self.elements)
  new_elements.push(SvgElement::Line(x1, y1, x2, y2, style))
  { ..self, elements: new_elements, }
}

///|
/// 画矩形
pub fn Canvas2::draw_rect(
  self : Canvas2,
  x : Double,
  y : Double,
  w : Double,
  h : Double,
  style : Style,
) -> Canvas2 {
  let new_elements = copy_elements(self.elements)
  new_elements.push(SvgElement::Rect(x, y, w, h, style))
  { ..self, elements: new_elements, }
}

///|
/// 画圆
pub fn Canvas2::draw_circle(
  self : Canvas2,
  cx : Double,
  cy : Double,
  r : Double,
  style : Style,
) -> Canvas2 {
  let new_elements = copy_elements(self.elements)
  new_elements.push(SvgElement::Circle(cx, cy, r, style))
  { ..self, elements: new_elements, }
}

///|
/// 画多边形
pub fn Canvas2::draw_polygon(
  self : Canvas2,
  coords : Array[(Double, Double)],
  style : Style,
) -> Canvas2 {
  let new_elements = copy_elements(self.elements)
  new_elements.push(SvgElement::Polygon(coords, style))
  { ..self, elements: new_elements, }
}

///|
/// 画折线
pub fn Canvas2::draw_polyline(
  self : Canvas2,
  coords : Array[(Double, Double)],
  style : Style,
) -> Canvas2 {
  let new_elements = copy_elements(self.elements)
  new_elements.push(SvgElement::Polyline(coords, style))
  { ..self, elements: new_elements, }
}

///|
/// 画文本
pub fn Canvas2::draw_text(
  self : Canvas2,
  x : Double,
  y : Double,
  text : String,
  style : Style,
) -> Canvas2 {
  let new_elements = copy_elements(self.elements)
  new_elements.push(SvgElement::Text(x, y, text, style))
  { ..self, elements: new_elements, }
}

///|
/// 元素数量
pub fn Canvas2::element_count(self : Canvas2) -> Int32 {
  self.elements.length()
}

///|
/// 生成 SVG XML 字符串
pub fn Canvas2::to_svg(self : Canvas2) -> String {
  let mut svg = "<svg width=\"\{self.width}\" height=\"\{self.height}\" xmlns=\"http://www.w3.org/2000/svg\">"
  match self.background {
    Some(c) =>
      svg += "<rect width=\"\{self.width}\" height=\"\{self.height}\" fill=\"\{c}\"/>"
    None => ()
  }
  for elem in self.elements {
    svg += element_to_svg(elem)
  }
  svg += "</svg>"
  svg
}

///|
/// 将 SVG 元素转为字符串
fn element_to_svg(elem : SvgElement) -> String {
  match elem {
    Line(x1, y1, x2, y2, style) => {
      let attrs = style.to_svg_attrs()
      "<line x1=\"\{x1}\" y1=\"\{y1}\" x2=\"\{x2}\" y2=\"\{y2}\"\{attrs}/>"
    }
    Rect(x, y, w, h, style) => {
      let attrs = style.to_svg_attrs()
      "<rect x=\"\{x}\" y=\"\{y}\" width=\"\{w}\" height=\"\{h}\"\{attrs}/>"
    }
    Circle(cx, cy, r, style) => {
      let attrs = style.to_svg_attrs()
      "<circle cx=\"\{cx}\" cy=\"\{cy}\" r=\"\{r}\"\{attrs}/>"
    }
    Ellipse(cx, cy, rx, ry, style) => {
      let attrs = style.to_svg_attrs()
      "<ellipse cx=\"\{cx}\" cy=\"\{cy}\" rx=\"\{rx}\" ry=\"\{ry}\"\{attrs}/>"
    }
    Polygon(coords, style) => {
      let attrs = style.to_svg_attrs()
      let pts = points_to_string(coords)
      "<polygon points=\"\{pts}\"\{attrs}/>"
    }
    Polyline(coords, style) => {
      let attrs = style.to_svg_attrs()
      let pts = points_to_string(coords)
      "<polyline points=\"\{pts}\"\{attrs}/>"
    }
    Text(x, y, text, style) => {
      let attrs = style.to_svg_attrs()
      "<text x=\"\{x}\" y=\"\{y}\" font-size=\"\{style.font_size}\" font-family=\"\{style.font_family}\"\{attrs}>\{text}</text>"
    }
    Group(elements, style) => {
      let attrs = style.to_svg_attrs()
      let mut inner = "<g\{attrs}>"
      for e in elements {
        inner += element_to_svg(e)
      }
      inner += "</g>"
      inner
    }
  }
}

///|
/// 坐标列表转 SVG points 字符串
fn points_to_string(coords : Array[(Double, Double)]) -> String {
  let mut result = ""
  let n = coords.length()
  for i in 0..<n {
    let (x, y) = coords[i]
    if i > 0 {
      result += " "
    }
    result += "\{x},\{y}"
  }
  result
}

///|
/// 复制元素数组
fn copy_elements(elements : Array[SvgElement]) -> Array[SvgElement] {
  let result : Array[SvgElement] = []
  for e in elements {
    result.push(e)
  }
  result
}
