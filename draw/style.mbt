// 样式配置
// draw 层，定义 SVG 风格的绘图样式

///|
/// 绘图样式
pub struct Style {
  stroke : String?
  fill : String?
  stroke_width : Double
  stroke_dasharray : String?
  font_size : Double
  font_family : String
  opacity : Double
}

///|
/// 默认样式（黑色线条，无填充，线宽 1）
pub fn Style::default() -> Style {
  {
    stroke: Some("black"),
    fill: None,
    stroke_width: 1.0,
    stroke_dasharray: None,
    font_size: 12.0,
    font_family: "sans-serif",
    opacity: 1.0,
  }
}

///|
/// 设置线条颜色和线宽
pub fn Style::with_stroke(
  self : Style,
  color : String,
  width : Double,
) -> Style {
  { ..self, stroke: Some(color), stroke_width: width, }
}

///|
/// 设置填充颜色
pub fn Style::with_fill(self : Style, color : String) -> Style {
  { ..self, fill: Some(color), }
}

///|
/// 设置虚线模式
pub fn Style::with_dash(self : Style, dash : String) -> Style {
  { ..self, stroke_dasharray: Some(dash), }
}

///|
/// 设置透明度（0-1）
pub fn Style::with_opacity(self : Style, opacity : Double) -> Style {
  { ..self, opacity, }
}

///|
/// 无线条
pub fn Style::no_stroke(self : Style) -> Style {
  { ..self, stroke: None, }
}

///|
/// 无填充
pub fn Style::no_fill(self : Style) -> Style {
  { ..self, fill: None, }
}

///|
/// 生成 SVG 属性字符串
pub fn Style::to_svg_attrs(self : Style) -> String {
  let mut attrs = ""
  match self.stroke {
    Some(c) => attrs += " stroke=\"\{c}\" stroke-width=\"\{self.stroke_width}\""
    None => attrs += " stroke=\"none\""
  }
  match self.fill {
    Some(c) => attrs += " fill=\"\{c}\""
    None => attrs += " fill=\"none\""
  }
  match self.stroke_dasharray {
    Some(d) => attrs += " stroke-dasharray=\"\{d}\""
    None => ()
  }
  if self.opacity < 1.0 {
    attrs += " opacity=\"\{self.opacity}\""
  }
  attrs
}
