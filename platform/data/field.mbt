// 属性类型系统
// P4 层 platform/data
// 定义字段类型和字段值，支持整数/浮点/字符串/布尔/空值

///|
/// 字段类型
pub enum FieldType {
  Integer
  Double
  String
  Boolean
} derive(Eq, Debug)

///|
/// 字段值
pub enum FieldValue {
  IntVal(Int32)
  DoubleVal(Double)
  StringVal(String)
  BoolVal(Bool)
  NullVal
} derive(Eq, Debug)

///|
/// 获取字段值的类型
pub fn FieldValue::type_of(v : FieldValue) -> FieldType {
  match v {
    IntVal(_) => FieldType::Integer
    DoubleVal(_) => FieldType::Double
    StringVal(_) => FieldType::String
    BoolVal(_) => FieldType::Boolean
    NullVal => FieldType::String
  }
}

///|
/// 尝试获取整数值
pub fn FieldValue::as_int(v : FieldValue) -> Int32? {
  match v {
    IntVal(n) => Some(n)
    _ => None
  }
}

///|
/// 尝试获取浮点值
pub fn FieldValue::as_double(v : FieldValue) -> Double? {
  match v {
    DoubleVal(d) => Some(d)
    IntVal(n) => Some(n.to_double())
    _ => None
  }
}

///|
/// 尝试获取字符串值
pub fn FieldValue::as_string(v : FieldValue) -> String? {
  match v {
    StringVal(s) => Some(s)
    _ => None
  }
}

///|
/// 尝试获取布尔值
pub fn FieldValue::as_bool(v : FieldValue) -> Bool? {
  match v {
    BoolVal(b) => Some(b)
    _ => None
  }
}

///|
/// 判断是否为空值
pub fn FieldValue::is_null(v : FieldValue) -> Bool {
  match v {
    NullVal => true
    _ => false
  }
}

///|
/// 类型检查：字段值是否匹配字段类型
pub fn field_type_match(ft : FieldType, fv : FieldValue) -> Bool {
  match (ft, fv) {
    (FieldType::Integer, IntVal(_)) => true
    (FieldType::Double, DoubleVal(_)) => true
    (FieldType::String, StringVal(_)) => true
    (FieldType::Boolean, BoolVal(_)) => true
    (_, NullVal) => true
    _ => false
  }
}
