// 简易 JSON 解析器
// platform/io，用于解析 GeoJSON 字符串
// 支持 Object/Array/String/Number/Bool/Null

///|
/// JSON 值
pub enum JsonValue {
  JsonObject(Array[(String, JsonValue)])
  JsonArray(Array[JsonValue])
  JsonString(String)
  JsonNumber(Double)
  JsonBool(Bool)
  JsonNull
}

///|
/// JSON 解析器
struct JsonParser {
  input : String
  pos : Int32
}

///|
/// 解析 JSON 字符串
pub fn parse_json(input : String) -> JsonValue raise @util.GeoError {
  let p : JsonParser = { input, pos: 0, }
  let (value, new_pos) = parse_value(p, 0)
  let p2 : JsonParser = { input: p.input, pos: new_pos, }
  let p3 = skip_whitespace(p2)
  if p3.pos < p3.input.length() {
    raise @util.GeoError::FormatError("JSON 尾部有额外字符")
  }
  value
}

///|
/// 跳过空白字符
fn skip_whitespace(p : JsonParser) -> JsonParser {
  let mut pos = p.pos
  let n = p.input.length()
  while pos < n {
    let ch = p.input[pos]
    if ch == ' ' || ch == '\t' || ch == '\n' || ch == '\r' {
      pos += 1
    } else {
      break
    }
  }
  { input: p.input, pos, }
}

///|
/// 解析一个值
fn parse_value(
  p : JsonParser,
  depth : Int32,
) -> (JsonValue, Int32) raise @util.GeoError {
  if depth > 1000 {
    raise @util.GeoError::FormatError("JSON 递归深度超过 1000")
  }
  let p = skip_whitespace(p)
  if p.pos >= p.input.length() {
    raise @util.GeoError::FormatError("JSON 意外结束")
  }
  let ch = p.input[p.pos]
  match ch {
    '{' => parse_object(p, depth)
    '[' => parse_array(p, depth)
    '"' => {
      let (s, pos) = parse_string(p)
      (JsonString(s), pos)
    }
    't' => parse_true(p)
    'f' => parse_false(p)
    'n' => parse_null(p)
    _ =>
      if ch == '-' || (ch >= '0' && ch <= '9') {
        parse_number(p)
      } else {
        raise @util.GeoError::FormatError("JSON 非法字符: \{ch}")
      }
  }
}

///|
/// 解析对象
fn parse_object(
  p : JsonParser,
  depth : Int32,
) -> (JsonValue, Int32) raise @util.GeoError {
  let mut pos = p.pos + 1
  let entries : Array[(String, JsonValue)] = []
  let p1 : JsonParser = { input: p.input, pos, }
  let p2 = skip_whitespace(p1)
  pos = p2.pos
  if pos < p.input.length() && p.input[pos] == '}' {
    return (JsonObject(entries), pos + 1)
  }
  while true {
    let p3 : JsonParser = { input: p.input, pos, }
    let p4 = skip_whitespace(p3)
    pos = p4.pos
    if pos >= p.input.length() {
      raise @util.GeoError::FormatError("JSON 对象意外结束")
    }
    if p.input[pos] != '"' {
      raise @util.GeoError::FormatError("JSON 对象键应为字符串")
    }
    let p5 : JsonParser = { input: p.input, pos, }
    let (key, pos2) = parse_string(p5)
    pos = pos2
    let p6 : JsonParser = { input: p.input, pos, }
    let p7 = skip_whitespace(p6)
    pos = p7.pos
    if pos >= p.input.length() || p.input[pos] != ':' {
      raise @util.GeoError::FormatError("JSON 对象缺少冒号")
    }
    pos += 1
    let p8 : JsonParser = { input: p.input, pos, }
    let (value, pos3) = parse_value(p8, depth + 1)
    pos = pos3
    entries.push((key, value))
    let p9 : JsonParser = { input: p.input, pos, }
    let p10 = skip_whitespace(p9)
    pos = p10.pos
    if pos >= p.input.length() {
      raise @util.GeoError::FormatError("JSON 对象意外结束")
    }
    if p.input[pos] == ',' {
      pos += 1
    } else if p.input[pos] == '}' {
      pos += 1
      break
    } else {
      raise @util.GeoError::FormatError(
        "JSON 对象缺少逗号或右花括号",
      )
    }
  }
  (JsonObject(entries), pos)
}

///|
/// 解析数组
fn parse_array(
  p : JsonParser,
  depth : Int32,
) -> (JsonValue, Int32) raise @util.GeoError {
  let mut pos = p.pos + 1
  let values : Array[JsonValue] = []
  let p1 : JsonParser = { input: p.input, pos, }
  let p2 = skip_whitespace(p1)
  pos = p2.pos
  if pos < p.input.length() && p.input[pos] == ']' {
    return (JsonArray(values), pos + 1)
  }
  while true {
    let p3 : JsonParser = { input: p.input, pos, }
    let (value, pos2) = parse_value(p3, depth + 1)
    pos = pos2
    values.push(value)
    let p4 : JsonParser = { input: p.input, pos, }
    let p5 = skip_whitespace(p4)
    pos = p5.pos
    if pos >= p.input.length() {
      raise @util.GeoError::FormatError("JSON 数组意外结束")
    }
    if p.input[pos] == ',' {
      pos += 1
    } else if p.input[pos] == ']' {
      pos += 1
      break
    } else {
      raise @util.GeoError::FormatError(
        "JSON 数组缺少逗号或右方括号",
      )
    }
  }
  (JsonArray(values), pos)
}

///|
/// 解析字符串
fn parse_string(p : JsonParser) -> (String, Int32) raise @util.GeoError {
  let start = p.pos + 1
  let mut pos = start
  let n = p.input.length()
  let mut has_escape = false
  while pos < n {
    let ch = p.input[pos]
    if ch == '"' {
      if !has_escape {
        return (p.input.substring(start~, end=pos), pos + 1)
      }
      break
    }
    if ch == '\\' {
      has_escape = true
      pos += 2
    } else {
      pos += 1
    }
  }
  if !has_escape {
    raise @util.GeoError::FormatError("JSON 字符串未闭合")
  }
  pos = start
  let mut result = ""
  while pos < n {
    let ch = p.input[pos]
    if ch == '"' {
      return (result, pos + 1)
    }
    if ch == '\\' {
      pos += 1
      if pos >= n {
        raise @util.GeoError::FormatError("JSON 字符串转义意外结束")
      }
      let esc = p.input[pos]
      match esc {
        '"' => result += "\""
        '\\' => result += "\\"
        'n' => result += "\n"
        'r' => result += "\r"
        't' => result += "\t"
        'b' => result += "\u{0008}"
        'f' => result += "\u{000c}"
        '/' => result += "/"
        'u' => {
          pos += 1
          let code = parse_hex4(p, pos)
          pos += 3
          result += Char::from_int(code).to_string()
        }
        _ => result += p.input.substring(start=pos, end=pos + 1)
      }
      pos += 1
    } else {
      result += p.input.substring(start=pos, end=pos + 1)
      pos += 1
    }
  }
  raise @util.GeoError::FormatError("JSON 字符串未闭合")
}

///|
/// 解析 4 位十六进制转义（\uXXXX），返回 Unicode 码点
fn parse_hex4(p : JsonParser, pos : Int32) -> Int32 raise @util.GeoError {
  let n = p.input.length()
  if pos + 4 > n {
    raise @util.GeoError::FormatError("JSON \\uXXXX 转义不完整")
  }
  let mut result = 0
  for i in 0..<4 {
    let ch = p.input[pos + i]
    let digit = match ch {
      '0' => 0
      '1' => 1
      '2' => 2
      '3' => 3
      '4' => 4
      '5' => 5
      '6' => 6
      '7' => 7
      '8' => 8
      '9' => 9
      'a' => 10
      'b' => 11
      'c' => 12
      'd' => 13
      'e' => 14
      'f' => 15
      'A' => 10
      'B' => 11
      'C' => 12
      'D' => 13
      'E' => 14
      'F' => 15
      _ => -1
    }
    if digit < 0 {
      raise @util.GeoError::FormatError(
        "JSON \\uXXXX 含非法十六进制字符",
      )
    }
    result = result * 16 + digit
  }
  result
}

///|
/// 解析数字
fn parse_number(p : JsonParser) -> (JsonValue, Int32) raise @util.GeoError {
  let start = p.pos
  let mut pos = p.pos
  let n = p.input.length()
  if pos < n && p.input[pos] == '-' {
    pos += 1
  }
  let int_start = pos
  while pos < n {
    let ch = p.input[pos]
    if ch >= '0' && ch <= '9' {
      pos += 1
    } else {
      break
    }
  }
  if pos == int_start {
    raise @util.GeoError::FormatError("JSON 数字缺少整数部分")
  }
  if pos < n && p.input[pos] == '.' {
    pos += 1
    let frac_start = pos
    while pos < n {
      let ch = p.input[pos]
      if ch >= '0' && ch <= '9' {
        pos += 1
      } else {
        break
      }
    }
    if pos == frac_start {
      raise @util.GeoError::FormatError("JSON 数字缺少小数部分")
    }
  }
  if pos < n && (p.input[pos] == 'e' || p.input[pos] == 'E') {
    pos += 1
    if pos < n && (p.input[pos] == '+' || p.input[pos] == '-') {
      pos += 1
    }
    let exp_start = pos
    while pos < n {
      let ch = p.input[pos]
      if ch >= '0' && ch <= '9' {
        pos += 1
      } else {
        break
      }
    }
    if pos == exp_start {
      raise @util.GeoError::FormatError("JSON 数字缺少指数部分")
    }
  }
  let s = p.input.substring(start~, end=pos)
  let d = local_parse_double(s)
  (JsonNumber(d), pos)
}

///|
/// 简易字符串转 Double（支持负号、小数点、科学记数法）
fn local_parse_double(s : String) -> Double raise @util.GeoError {
  let mut result = 0.0
  let mut pos = 0
  let n = s.length()
  let mut negative = false
  if pos < n && s[pos] == '-' {
    negative = true
    pos += 1
  }
  while pos < n {
    let ch = s[pos]
    if ch >= '0' && ch <= '9' {
      result = result * 10.0 + (ch.to_int() - '0'.to_int()).to_double()
      pos += 1
    } else {
      break
    }
  }
  if pos < n && s[pos] == '.' {
    pos += 1
    let mut frac = 0.1
    while pos < n {
      let ch = s[pos]
      if ch >= '0' && ch <= '9' {
        result += (ch.to_int() - '0'.to_int()).to_double() * frac
        frac *= 0.1
        pos += 1
      } else {
        break
      }
    }
  }
  if pos < n && (s[pos] == 'e' || s[pos] == 'E') {
    pos += 1
    let mut exp_negative = false
    if pos < n && s[pos] == '-' {
      exp_negative = true
      pos += 1
    } else if pos < n && s[pos] == '+' {
      pos += 1
    }
    let mut exp = 0
    while pos < n {
      let ch = s[pos]
      if ch >= '0' && ch <= '9' {
        exp = exp * 10 + (ch.to_int() - '0'.to_int())
        pos += 1
      } else {
        break
      }
    }
    let mut multiplier = 1.0
    let mut e = exp
    while e > 0 {
      multiplier *= 10.0
      e -= 1
    }
    if exp_negative {
      result /= multiplier
    } else {
      result *= multiplier
    }
  }
  if pos < n {
    raise @util.GeoError::FormatError("数字解析失败：未消费字符")
  }
  if negative {
    -result
  } else {
    result
  }
}

///|
/// 解析 true
fn parse_true(p : JsonParser) -> (JsonValue, Int32) raise @util.GeoError {
  if p.pos + 4 > p.input.length() {
    raise @util.GeoError::FormatError("JSON true 不完整")
  }
  if p.input[p.pos + 1] != 'r' ||
    p.input[p.pos + 2] != 'u' ||
    p.input[p.pos + 3] != 'e' {
    raise @util.GeoError::FormatError("JSON 非法字面量")
  }
  (JsonBool(true), p.pos + 4)
}

///|
/// 解析 false
fn parse_false(p : JsonParser) -> (JsonValue, Int32) raise @util.GeoError {
  if p.pos + 5 > p.input.length() {
    raise @util.GeoError::FormatError("JSON false 不完整")
  }
  if p.input[p.pos + 1] != 'a' ||
    p.input[p.pos + 2] != 'l' ||
    p.input[p.pos + 3] != 's' ||
    p.input[p.pos + 4] != 'e' {
    raise @util.GeoError::FormatError("JSON 非法字面量")
  }
  (JsonBool(false), p.pos + 5)
}

///|
/// 解析 null
fn parse_null(p : JsonParser) -> (JsonValue, Int32) raise @util.GeoError {
  if p.pos + 4 > p.input.length() {
    raise @util.GeoError::FormatError("JSON null 不完整")
  }
  if p.input[p.pos + 1] != 'u' ||
    p.input[p.pos + 2] != 'l' ||
    p.input[p.pos + 3] != 'l' {
    raise @util.GeoError::FormatError("JSON 非法字面量")
  }
  (JsonNull, p.pos + 4)
}

///|
/// 从 JsonObject 中获取字段
pub fn json_get(obj : JsonValue, key : String) -> JsonValue? {
  match obj {
    JsonObject(entries) => {
      for (k, v) in entries {
        if k == key {
          return Some(v)
        }
      }
      None
    }
    _ => None
  }
}

///|
/// 从 JsonValue 获取字符串值
pub fn json_as_string(v : JsonValue) -> String? {
  match v {
    JsonString(s) => Some(s)
    _ => None
  }
}

///|
/// 从 JsonValue 获取数字值
pub fn json_as_number(v : JsonValue) -> Double? {
  match v {
    JsonNumber(d) => Some(d)
    _ => None
  }
}

///|
/// 从 JsonValue 获取数组
pub fn json_as_array(v : JsonValue) -> Array[JsonValue]? {
  match v {
    JsonArray(arr) => Some(arr)
    _ => None
  }
}

///|
/// 从 JsonValue 获取对象
pub fn json_as_object(v : JsonValue) -> Array[(String, JsonValue)]? {
  match v {
    JsonObject(entries) => Some(entries)
    _ => None
  }
}
