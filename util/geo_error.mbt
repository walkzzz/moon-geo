// 统一几何错误类型
// 第-1层 util，零几何语义
// 错误码 + 结构化上下文 + 可选恢复建议
// 对应前瞻性审查 §2.4 错误处理工程化

///|
/// 几何错误码
pub enum GeoErrorCode {
  /// 退化输入（零长线段、零面积圆等）
  DegenerateInput
  /// 数值溢出
  NumericalOverflow
  /// 数值下溢
  NumericalUnderflow
  /// 不收敛
  NotConverged
  /// 拓扑不一致
  TopoInconsistent
  /// 求交失败（无交点/无穷交点）
  IntersectFailed
  /// 变换失败（奇异矩阵等）
  TransformFailed
  /// 越界访问
  OutOfBounds
  /// I/O 错误
  IoError
  /// 格式错误
  FormatError
  /// 不支持的操作
  Unsupported
  /// 未知错误
  Unknown
}

///|
/// 几何错误：错误码 + 消息 + 上下文 + 恢复建议
pub(all) struct GeoError {
  /// 错误码（可程序化匹配）
  code : GeoErrorCode
  /// 人类可读消息
  message : String
  /// 结构化上下文（操作名、参数等）
  context : Array[String]
  /// 可选恢复建议
  suggestion : String?
}

///|
pub fn GeoError::new(code : GeoErrorCode, message : String) -> GeoError {
  { code, message, context: [], suggestion: None, }
}

///|
pub fn GeoError::with_context(
  code : GeoErrorCode,
  message : String,
  context : Array[String],
) -> GeoError {
  { code, message, context, suggestion: None, }
}

///|
pub fn GeoError::with_suggestion(
  code : GeoErrorCode,
  message : String,
  suggestion : String,
) -> GeoError {
  { code, message, context: [], suggestion: Some(suggestion), }
}

///|
/// 错误码转字符串（用于日志/调试）
pub fn geo_error_code_str(code : GeoErrorCode) -> String {
  match code {
    GeoErrorCode::DegenerateInput => "DegenerateInput"
    GeoErrorCode::NumericalOverflow => "NumericalOverflow"
    GeoErrorCode::NumericalUnderflow => "NumericalUnderflow"
    GeoErrorCode::NotConverged => "NotConverged"
    GeoErrorCode::TopoInconsistent => "TopoInconsistent"
    GeoErrorCode::IntersectFailed => "IntersectFailed"
    GeoErrorCode::TransformFailed => "TransformFailed"
    GeoErrorCode::OutOfBounds => "OutOfBounds"
    GeoErrorCode::IoError => "IoError"
    GeoErrorCode::FormatError => "FormatError"
    GeoErrorCode::Unsupported => "Unsupported"
    GeoErrorCode::Unknown => "Unknown"
  }
}
