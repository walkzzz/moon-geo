// 结构化日志抽象
// 第-1层 util，零几何语义
// 不强制依赖具体日志库，用 trait 抽象
// 对应前瞻性审查 §2.10 日志与可观测性

///|
/// 日志级别
pub enum LogLevel {
  Debug
  Info
  Warn
  Error
}

///|
/// 日志器 Trait：结构化日志抽象
/// 具体实现可对接 MoonBit 标准输出、文件、OpenTelemetry 等
/// 无 subscriber 时零开销
pub trait Logger {
  /// 判定日志级别是否启用（零开销短路）
  fn enabled(self : Self, level : LogLevel) -> Bool

  /// 记录日志
  fn log(self : Self, level : LogLevel, msg : String) -> Unit
}

///|
/// 空日志器：丢弃所有日志（默认，零开销）
pub struct NullLogger {
  dummy : Unit
}

///|
pub fn NullLogger::new() -> NullLogger {
  { dummy: (), }
}

///|
impl Logger for NullLogger with fn enabled(_, _) {
  false
}

///|
impl Logger for NullLogger with fn log(_, _, _) {
  ignore(())
}

///|
/// 日志级别转字符串
pub fn log_level_str(level : LogLevel) -> String {
  match level {
    LogLevel::Debug => "DEBUG"
    LogLevel::Info => "INFO"
    LogLevel::Warn => "WARN"
    LogLevel::Error => "ERROR"
  }
}
