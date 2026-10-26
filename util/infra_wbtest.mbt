// util 白盒测试：相对公差、混合公差、GeoContext、GeoError、Logger
// 对应前瞻性审查 §1.1/§2.4/§2.5/§2.10

///|
test "rel_approx_eq basic" {
  assert_true(rel_approx_eq(1000000.0, 1000001.0, 1.0e-5))
  assert_false(rel_approx_eq(1000000.0, 1001000.0, 1.0e-5))
  assert_true(rel_approx_eq(0.0, 0.0, 1.0e-8))
}

///|
test "mixed_approx_eq basic" {
  assert_true(mixed_approx_eq(0.0, 1.0e-9, 1.0e-8, 1.0e-10))
  assert_false(mixed_approx_eq(0.0, 1.0e-7, 1.0e-8, 1.0e-10))
  assert_true(mixed_approx_eq(1000000.0, 1000001.0, 1.0e-8, 1.0e-6))
}

///|
test "GeoContext default" {
  let ctx = GeoContext::default()
  assert_true(dbl_approx_eq(ctx.abs_tol, 1.0e-8, 1.0e-15))
  assert_true(dbl_approx_eq(ctx.rel_tol, 1.0e-10, 1.0e-15))
}

///|
test "GeoContext surveying" {
  let ctx = GeoContext::surveying()
  assert_true(dbl_approx_eq(ctx.abs_tol, 1.0e-10, 1.0e-15))
}

///|
test "GeoContext game" {
  let ctx = GeoContext::game()
  assert_true(dbl_approx_eq(ctx.abs_tol, 1.0e-4, 1.0e-15))
}

///|
test "GeoContext custom" {
  let ctx = GeoContext::custom(1.0e-6, 1.0e-8)
  assert_true(dbl_approx_eq(ctx.abs_tol, 1.0e-6, 1.0e-15))
  assert_true(dbl_approx_eq(ctx.rel_tol, 1.0e-8, 1.0e-15))
}

///|
test "ctx_approx_eq" {
  let ctx = GeoContext::default()
  assert_true(ctx_approx_eq(1.0, 1.0 + 1.0e-9, ctx))
  assert_false(ctx_approx_eq(1.0, 1.1, ctx))
}

///|
test "GeoError construction" {
  let e1 = GeoError::new(GeoErrorCode::DegenerateInput, "zero length line")
  assert_true(e1.code is GeoErrorCode::DegenerateInput)
  let e2 = GeoError::with_context(
    GeoErrorCode::IntersectFailed,
    "parallel lines",
    ["line1", "line2"],
  )
  assert_true(e2.context.length() == 2)
  let e3 = GeoError::with_suggestion(
    GeoErrorCode::TransformFailed,
    "singular matrix",
    "use pseudo-inverse",
  )
  assert_true(e3.suggestion is Some(_))
}

///|
test "geo_error_code_str" {
  assert_eq(
    geo_error_code_str(GeoErrorCode::DegenerateInput),
    "DegenerateInput",
  )
  assert_eq(geo_error_code_str(GeoErrorCode::IoError), "IoError")
  assert_eq(geo_error_code_str(GeoErrorCode::Unknown), "Unknown")
}

///|
test "NullLogger" {
  let logger = NullLogger::new()
  assert_false(Logger::enabled(logger, LogLevel::Info))
  Logger::log(logger, LogLevel::Error, "test")
}

///|
test "log_level_str" {
  assert_eq(log_level_str(LogLevel::Debug), "DEBUG")
  assert_eq(log_level_str(LogLevel::Info), "INFO")
  assert_eq(log_level_str(LogLevel::Warn), "WARN")
  assert_eq(log_level_str(LogLevel::Error), "ERROR")
}
