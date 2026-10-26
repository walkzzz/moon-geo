// GeoJSON 序列化
// platform/io，将 Feature/Layer/Dataset 转为 GeoJSON 字符串
// 遵循 RFC 7946，CRS 通过 crs 字段携带（虽已废弃但广泛使用）
// Geometry 坐标用 @alg.Pt2/Pt3，序列化时提取 x()/y()/z()

///|
/// 将 Feature 序列化为 GeoJSON 字符串
pub fn feature_to_geojson(feature : @data.Feature) -> String {
  let mut s = "{\"type\":\"Feature\""
  s += ",\"crs\":" + crs_to_geojson(feature.crs())
  s += ",\"geometry\":" + geometry_to_geojson_opt(feature.geometry())
  s += ",\"properties\":" + properties_to_geojson(feature)
  s += "}"
  s
}

///|
/// 将 Layer 序列化为 GeoJSON FeatureCollection 字符串
pub fn layer_to_geojson(layer : @data.Layer) -> String {
  let mut s = "{\"type\":\"FeatureCollection\""
  s += ",\"crs\":" + crs_to_geojson(layer.crs())
  s += ",\"features\":["
  let n = layer.feature_count()
  for i in 0..<n {
    if i > 0 {
      s += ","
    }
    match layer.get_feature(i) {
      Some(f) => s += feature_to_geojson(f)
      None => ()
    }
  }
  s += "]}"
  s
}

///|
/// 将 Dataset 序列化为 GeoJSON 字符串（多图层合并为 FeatureCollection，图层名作为属性）
pub fn dataset_to_geojson(dataset : @data.Dataset) -> String {
  let mut s = "{\"type\":\"FeatureCollection\",\"features\":["
  let mut first = true
  let n = dataset.layer_count()
  for i in 0..<n {
    match dataset.get_layer_by_index(i) {
      Some(layer) => {
        let fc = layer.feature_count()
        for j in 0..<fc {
          match layer.get_feature(j) {
            Some(f) => {
              if !first {
                s += ","
              }
              first = false
              s += feature_to_geojson(f)
            }
            None => ()
          }
        }
      }
      None => ()
    }
  }
  s += "]}"
  s
}

///|
/// CRS 转 GeoJSON crs 字段
fn crs_to_geojson(crs : @crs.Crs) -> String {
  match crs.epsg {
    Some(code) =>
      "{\"type\":\"name\",\"properties\":{\"name\":\"urn:ogc:def:crs:EPSG::\{code}\"}}"
    None => "{\"type\":\"name\",\"properties\":{\"name\":\"local\"}}"
  }
}

///|
/// Geometry 转 GeoJSON（Option 包装）
fn geometry_to_geojson_opt(geom : @data.Geometry?) -> String {
  match geom {
    Some(g) => geometry_to_geojson(g)
    None => "null"
  }
}

///|
/// Geometry 转 GeoJSON 字符串
pub fn geometry_to_geojson(geom : @data.Geometry) -> String {
  match geom {
    @data.Point(p) =>
      "{\"type\":\"Point\",\"coordinates\":" + coord_to_json(p.x(), p.y()) + "}"
    @data.PointZ(p) =>
      "{\"type\":\"Point\",\"coordinates\":[\{p.x()},\{p.y()},\{p.z()}]}"
    @data.LineString(coords) =>
      "{\"type\":\"LineString\",\"coordinates\":" +
      coords_array_to_json(coords) +
      "}"
    @data.Polygon(exterior, interiors) => {
      let mut s = "{\"type\":\"Polygon\",\"coordinates\":["
      s += coords_array_to_json(exterior)
      for ring in interiors {
        s += "," + coords_array_to_json(ring)
      }
      s += "]}"
      s
    }
    @data.MultiPoint(coords) =>
      "{\"type\":\"MultiPoint\",\"coordinates\":" +
      coords_array_to_json(coords) +
      "}"
    @data.MultiLineString(lines) => {
      let mut s = "{\"type\":\"MultiLineString\",\"coordinates\":["
      let n = lines.length()
      for i in 0..<n {
        if i > 0 {
          s += ","
        }
        s += coords_array_to_json(lines[i])
      }
      s += "]}"
      s
    }
    @data.MultiPolygon(polygons) => {
      let mut s = "{\"type\":\"MultiPolygon\",\"coordinates\":["
      let n = polygons.length()
      for i in 0..<n {
        if i > 0 {
          s += ","
        }
        let (exterior, interiors) = polygons[i]
        s += "[" + coords_array_to_json(exterior)
        for ring in interiors {
          s += "," + coords_array_to_json(ring)
        }
        s += "]"
      }
      s += "]}"
      s
    }
  }
}

///|
/// 坐标对转 JSON
fn coord_to_json(x : Double, y : Double) -> String {
  "[\{x},\{y}]"
}

///|
/// 坐标数组转 JSON
fn coords_array_to_json(coords : Array[@alg.Pt2]) -> String {
  let mut s = "["
  let n = coords.length()
  for i in 0..<n {
    let p = coords[i]
    if i > 0 {
      s += ","
    }
    s += coord_to_json(p.x(), p.y())
  }
  s += "]"
  s
}

///|
/// 属性转 GeoJSON properties 对象
fn properties_to_geojson(feature : @data.Feature) -> String {
  let mut s = "{"
  let names = feature.field_names()
  let n = names.length()
  for i in 0..<n {
    let name = names[i]
    if i > 0 {
      s += ","
    }
    s += "\"" + escape_string(name) + "\":"
    match feature.get(name) {
      Some(v) => s += field_value_to_json(v)
      None => s += "null"
    }
  }
  s += "}"
  s
}

///|
/// FieldValue 转 JSON
fn field_value_to_json(v : @data.FieldValue) -> String {
  match v {
    @data.IntVal(n) => "\{n}"
    @data.DoubleVal(d) => "\{d}"
    @data.StringVal(s) => "\"" + escape_string(s) + "\""
    @data.BoolVal(true) => "true"
    @data.BoolVal(false) => "false"
    @data.NullVal => "null"
  }
}

///|
/// 转义字符串中的特殊字符
fn escape_string(s : String) -> String {
  let mut result = ""
  let n = s.length()
  for i in 0..<n {
    let ch = s[i]
    match ch {
      '"' => result += "\\\""
      '\\' => result += "\\\\"
      '\n' => result += "\\n"
      '\r' => result += "\\r"
      '\t' => result += "\\t"
      _ => result += s.substring(start=i, end=i + 1)
    }
  }
  result
}
