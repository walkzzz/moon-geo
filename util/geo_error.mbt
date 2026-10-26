// 统一几何错误类型
// 第-1层 util，零几何语义
// 使用 MoonBit 原生 suberror + raise 机制
// 对应前瞻性审查 §2.4 错误处理工程化

///|
/// 几何错误：使用 suberror 定义，支持 raise/catch 和模式匹配
/// 每个构造器对应一种错误类型，携带消息和可选上下文
pub(all) suberror GeoError {
  /// 退化输入（零长线段、零面积圆等）：(message, context)
  DegenerateInput(String, Array[String])
  /// 数值溢出：(message)
  NumericalOverflow(String)
  /// 数值下溢：(message)
  NumericalUnderflow(String)
  /// 不收敛：(message)
  NotConverged(String)
  /// 拓扑不一致：(message)
  TopoInconsistent(String)
  /// 求交失败（无交点/无穷交点）：(message)
  IntersectFailed(String)
  /// 变换失败（奇异矩阵等）：(message)
  TransformFailed(String)
  /// 越界访问：(message)
  OutOfBounds(String)
  /// I/O 错误：(message)
  IoError(String)
  /// 格式错误：(message)
  FormatError(String)
  /// 不支持的操作：(message)
  Unsupported(String)
  /// 未知错误：(message)
  Unknown(String)
} derive(Debug)

///|
pub extend GeoError with @debug.Debug::{to_repr}
