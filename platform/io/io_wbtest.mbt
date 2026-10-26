// platform/io 白盒测试
// 覆盖 JSON 解析器 + GeoJSON 读写 + 往返测试
// Geometry 坐标用 @alg.Pt2/Pt3

///|
/// 浮点近似比较
fn approx(a : Double, b : Double, tol : Double) -> Bool {
  (a - b).abs() < tol
}

///|
/// 安全调用 parse_json，失败返回 None
fn safe_parse(json : String) -> JsonValue? {
  try {
    let v = parse_json(json)
    Some(v)
  } catch {
    _ => None
  }
}

///|
/// 安全调用 feature_from_geojson
fn safe_feature(json : String) -> @data.Feature? {
  try {
    let v = feature_from_geojson(json)
    Some(v)
  } catch {
    _ => None
  }
}

///|
/// 安全调用 layer_from_geojson
fn safe_layer(json : String, name : String) -> @data.Layer? {
  try {
    let v = layer_from_geojson(json, name)
    Some(v)
  } catch {
    _ => None
  }
}

///|
test "JSON 解析空对象" {
  match safe_parse("{}") {
    Some(v) => assert_true(v is JsonObject(_))
    None => assert_true(false)
  }
}

///|
test "JSON 解析简单对象" {
  match safe_parse("{\"a\":1}") {
    Some(JsonObject(entries)) => {
      assert_eq(entries.length(), 1)
      assert_eq(entries[0].0, "a")
      assert_true(entries[0].1 is JsonNumber(_))
    }
    _ => assert_true(false)
  }
}

///|
test "JSON 解析嵌套对象" {
  match safe_parse("{\"outer\":{\"inner\":42}}") {
    Some(v) =>
      match json_get(v, "outer") {
        Some(v2) =>
          match json_get(v2, "inner") {
            Some(JsonNumber(d)) => assert_true(approx(d, 42.0, 0.001))
            _ => assert_true(false)
          }
        _ => assert_true(false)
      }
    _ => assert_true(false)
  }
}

///|
test "JSON 解析数组" {
  match safe_parse("[1,2,3]") {
    Some(JsonArray(arr)) => assert_eq(arr.length(), 3)
    _ => assert_true(false)
  }
}

///|
test "JSON 解析空数组" {
  match safe_parse("[]") {
    Some(v) => assert_true(v is JsonArray(_))
    _ => assert_true(false)
  }
}

///|
test "JSON 解析字符串" {
  match safe_parse("\"hello\"") {
    Some(JsonString(s)) => assert_eq(s, "hello")
    _ => assert_true(false)
  }
}

///|
test "JSON 解析转义字符串" {
  match safe_parse("\"hello\\nworld\"") {
    Some(JsonString(s)) => assert_true(s.contains("\n"))
    _ => assert_true(false)
  }
}

///|
test "JSON 解析数字" {
  match safe_parse("42.5") {
    Some(JsonNumber(d)) => assert_true(approx(d, 42.5, 0.001))
    _ => assert_true(false)
  }
}

///|
test "JSON 解析负数" {
  match safe_parse("-3.14") {
    Some(JsonNumber(d)) => assert_true(approx(d, -3.14, 0.001))
    _ => assert_true(false)
  }
}

///|
test "JSON 解析布尔" {
  match safe_parse("true") {
    Some(v) => assert_true(v is JsonBool(true))
    _ => assert_true(false)
  }
  match safe_parse("false") {
    Some(v) => assert_true(v is JsonBool(false))
    _ => assert_true(false)
  }
}

///|
test "JSON 解析 null" {
  match safe_parse("null") {
    Some(v) => assert_true(v is JsonNull)
    _ => assert_true(false)
  }
}

///|
test "JSON 解析复杂对象" {
  let json = "{\"type\":\"Point\",\"coordinates\":[1.0,2.0]}"
  match safe_parse(json) {
    Some(v) => {
      match json_get(v, "type") {
        Some(JsonString(s)) => assert_eq(s, "Point")
        _ => assert_true(false)
      }
      match json_get(v, "coordinates") {
        Some(JsonArray(arr)) => assert_eq(arr.length(), 2)
        _ => assert_true(false)
      }
    }
    _ => assert_true(false)
  }
}

///|
test "JSON 解析带空白" {
  match safe_parse("  {  \"a\"  :  1  }  ") {
    Some(v) => assert_true(v is JsonObject(_))
    _ => assert_true(false)
  }
}

///|
test "JSON 解析科学记数法" {
  match safe_parse("1.5e3") {
    Some(JsonNumber(d)) => assert_true(approx(d, 1500.0, 0.1))
    _ => assert_true(false)
  }
}

///|
test "json_get 查找键" {
  match safe_parse("{\"a\":1,\"b\":2}") {
    Some(v) => {
      assert_true(json_get(v, "a") is Some(_))
      assert_true(json_get(v, "b") is Some(_))
      assert_true(json_get(v, "c") is None)
    }
    _ => assert_true(false)
  }
}

///|
test "GeoJSON 写 Point Feature" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs)
    .with_geometry(@data.Point(@alg.Pt2::new(116.0, 39.0)))
    .set("name", @data.StringVal("北京"))
  let json = feature_to_geojson(f)
  assert_true(json.contains("\"type\":\"Feature\""))
  assert_true(json.contains("\"type\":\"Point\""))
  assert_true(json.contains("116"))
  assert_true(json.contains("39"))
  assert_true(json.contains("北京"))
}

///|
test "GeoJSON 写 LineString Feature" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs).with_geometry(
    @data.LineString([
      @alg.Pt2::new(0.0, 0.0),
      @alg.Pt2::new(1.0, 1.0),
      @alg.Pt2::new(2.0, 0.0),
    ]),
  )
  let json = feature_to_geojson(f)
  assert_true(json.contains("\"type\":\"LineString\""))
  assert_true(json.contains("coordinates"))
}

///|
test "GeoJSON 写 Polygon Feature" {
  let crs = @crs.wgs84_geographic()
  let exterior = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
    @alg.Pt2::new(0.0, 10.0),
    @alg.Pt2::new(0.0, 0.0),
  ]
  let f = @data.Feature::new(crs).with_geometry(@data.Polygon(exterior, []))
  let json = feature_to_geojson(f)
  assert_true(json.contains("\"type\":\"Polygon\""))
}

///|
test "GeoJSON 写 MultiPoint" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs).with_geometry(
    @data.MultiPoint([@alg.Pt2::new(0.0, 0.0), @alg.Pt2::new(1.0, 1.0)]),
  )
  let json = feature_to_geojson(f)
  assert_true(json.contains("\"type\":\"MultiPoint\""))
}

///|
test "GeoJSON 写带属性" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs)
    .with_geometry(@data.Point(@alg.Pt2::new(0.0, 0.0)))
    .set("id", @data.IntVal(42))
    .set("score", @data.DoubleVal(3.14))
    .set("active", @data.BoolVal(true))
    .set("empty", @data.NullVal)
  let json = feature_to_geojson(f)
  assert_true(json.contains("42"))
  assert_true(json.contains("3.14"))
  assert_true(json.contains("true"))
  assert_true(json.contains("null"))
}

///|
test "GeoJSON 写 CRS" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs).with_geometry(
    @data.Point(@alg.Pt2::new(0.0, 0.0)),
  )
  let json = feature_to_geojson(f)
  assert_true(json.contains("EPSG"))
  assert_true(json.contains("4326"))
}

///|
test "GeoJSON 写 Layer" {
  let crs = @crs.wgs84_geographic()
  let f1 = @data.Feature::new(crs)
    .with_geometry(@data.Point(@alg.Pt2::new(0.0, 0.0)))
    .set("name", @data.StringVal("p1"))
  let f2 = @data.Feature::new(crs)
    .with_geometry(@data.Point(@alg.Pt2::new(1.0, 1.0)))
    .set("name", @data.StringVal("p2"))
  let layer = @data.Layer::new("test", crs).add_feature(f1).add_feature(f2)
  let json = layer_to_geojson(layer)
  assert_true(json.contains("\"type\":\"FeatureCollection\""))
  assert_true(json.contains("\"features\""))
  assert_true(json.contains("p1"))
  assert_true(json.contains("p2"))
}

///|
test "GeoJSON 写 Dataset" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs).with_geometry(
    @data.Point(@alg.Pt2::new(0.0, 0.0)),
  )
  let layer = @data.Layer::new("l1", crs).add_feature(f)
  let ds = @data.Dataset::new("ds1").add_layer(layer)
  let json = dataset_to_geojson(ds)
  assert_true(json.contains("\"type\":\"FeatureCollection\""))
  assert_true(json.contains("\"features\""))
}

///|
test "GeoJSON 读 Point" {
  let json = "{\"type\":\"Feature\",\"crs\":{\"type\":\"name\",\"properties\":{\"name\":\"urn:ogc:def:crs:EPSG::4326\"}},\"geometry\":{\"type\":\"Point\",\"coordinates\":[116.0,39.0]},\"properties\":{\"name\":\"北京\"}}"
  match safe_feature(json) {
    Some(f) => {
      assert_true(f.has_geometry())
      match f.geometry() {
        Some(@data.Point(p)) => {
          assert_true(approx(p.x(), 116.0, 0.001))
          assert_true(approx(p.y(), 39.0, 0.001))
        }
        _ => assert_true(false)
      }
      match f.get("name") {
        Some(@data.StringVal(s)) => assert_eq(s, "北京")
        _ => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 LineString" {
  let json = "{\"type\":\"Feature\",\"geometry\":{\"type\":\"LineString\",\"coordinates\":[[0.0,0.0],[1.0,1.0],[2.0,0.0]]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) => {
      assert_true(f.has_geometry())
      match f.geometry() {
        Some(@data.LineString(coords)) => assert_eq(coords.length(), 3)
        _ => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 Polygon" {
  let json = "{\"type\":\"Feature\",\"geometry\":{\"type\":\"Polygon\",\"coordinates\":[[[0.0,0.0],[10.0,0.0],[10.0,10.0],[0.0,0.0]]]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) => {
      assert_true(f.has_geometry())
      match f.geometry() {
        Some(@data.Polygon(exterior, _)) => assert_eq(exterior.length(), 4)
        _ => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 MultiPoint" {
  let json = "{\"type\":\"Feature\",\"geometry\":{\"type\":\"MultiPoint\",\"coordinates\":[[0.0,0.0],[1.0,1.0]]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) => {
      assert_true(f.has_geometry())
      match f.geometry() {
        Some(@data.MultiPoint(coords)) => assert_eq(coords.length(), 2)
        _ => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 null geometry" {
  let json = "{\"type\":\"Feature\",\"geometry\":null,\"properties\":{}}"
  match safe_feature(json) {
    Some(f) => assert_true(!f.has_geometry())
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读属性" {
  let json = "{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[0,0]},\"properties\":{\"id\":42,\"score\":3.14,\"active\":true,\"name\":\"test\"}}"
  match safe_feature(json) {
    Some(f) => {
      match f.get("id") {
        Some(@data.DoubleVal(d)) => assert_true(approx(d, 42.0, 0.001))
        _ => assert_true(false)
      }
      match f.get("name") {
        Some(@data.StringVal(s)) => assert_eq(s, "test")
        _ => assert_true(false)
      }
      match f.get("active") {
        Some(@data.BoolVal(true)) => ()
        _ => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 FeatureCollection" {
  let json = "{\"type\":\"FeatureCollection\",\"features\":[{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[0,0]},\"properties\":{}},{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[1,1]},\"properties\":{}}]}"
  match safe_layer(json, "test") {
    Some(layer) => assert_eq(layer.feature_count(), 2)
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 CRS EPSG:4326" {
  let json = "{\"type\":\"Feature\",\"crs\":{\"type\":\"name\",\"properties\":{\"name\":\"urn:ogc:def:crs:EPSG::4326\"}},\"geometry\":{\"type\":\"Point\",\"coordinates\":[0,0]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) => {
      let crs = f.crs()
      assert_true(crs.epsg is Some(_))
    }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 CRS EPSG:3857" {
  let json = "{\"type\":\"Feature\",\"crs\":{\"type\":\"name\",\"properties\":{\"name\":\"urn:ogc:def:crs:EPSG::3857\"}},\"geometry\":{\"type\":\"Point\",\"coordinates\":[0,0]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) => {
      let crs = f.crs()
      match crs.epsg {
        Some(code) => assert_eq(code, 3857)
        None => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 往返 Point" {
  let crs = @crs.wgs84_geographic()
  let f1 = @data.Feature::new(crs)
    .with_geometry(@data.Point(@alg.Pt2::new(116.0, 39.0)))
    .set("name", @data.StringVal("test"))
  let json = feature_to_geojson(f1)
  match safe_feature(json) {
    Some(f2) => {
      match f2.geometry() {
        Some(@data.Point(p)) => {
          assert_true(approx(p.x(), 116.0, 0.001))
          assert_true(approx(p.y(), 39.0, 0.001))
        }
        _ => assert_true(false)
      }
      match f2.get("name") {
        Some(@data.StringVal(s)) => assert_eq(s, "test")
        _ => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 往返 LineString" {
  let crs = @crs.wgs84_geographic()
  let f1 = @data.Feature::new(crs).with_geometry(
    @data.LineString([
      @alg.Pt2::new(0.0, 0.0),
      @alg.Pt2::new(1.0, 1.0),
      @alg.Pt2::new(2.0, 0.0),
    ]),
  )
  let json = feature_to_geojson(f1)
  match safe_feature(json) {
    Some(f2) =>
      match f2.geometry() {
        Some(@data.LineString(coords)) => {
          assert_eq(coords.length(), 3)
          let p0 = coords[0]
          assert_true(approx(p0.x(), 0.0, 0.001))
          let p2 = coords[2]
          assert_true(approx(p2.x(), 2.0, 0.001))
        }
        _ => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 往返 Polygon" {
  let crs = @crs.wgs84_geographic()
  let exterior = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
    @alg.Pt2::new(0.0, 0.0),
  ]
  let f1 = @data.Feature::new(crs).with_geometry(@data.Polygon(exterior, []))
  let json = feature_to_geojson(f1)
  match safe_feature(json) {
    Some(f2) =>
      match f2.geometry() {
        Some(@data.Polygon(ext, _)) => assert_eq(ext.length(), 4)
        _ => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 往返 Layer" {
  let crs = @crs.wgs84_geographic()
  let f1 = @data.Feature::new(crs).with_geometry(
    @data.Point(@alg.Pt2::new(0.0, 0.0)),
  )
  let f2 = @data.Feature::new(crs).with_geometry(
    @data.Point(@alg.Pt2::new(1.0, 1.0)),
  )
  let layer1 = @data.Layer::new("test", crs).add_feature(f1).add_feature(f2)
  let json = layer_to_geojson(layer1)
  match safe_layer(json, "test") {
    Some(layer2) => assert_eq(layer2.feature_count(), 2)
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 MultiLineString" {
  let json = "{\"type\":\"Feature\",\"geometry\":{\"type\":\"MultiLineString\",\"coordinates\":[[[0,0],[1,1]],[[2,2],[3,3]]]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) =>
      match f.geometry() {
        Some(@data.MultiLineString(lines)) => assert_eq(lines.length(), 2)
        _ => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 MultiPolygon" {
  let json = "{\"type\":\"Feature\",\"geometry\":{\"type\":\"MultiPolygon\",\"coordinates\":[[[[0,0],[1,0],[1,1],[0,0]]]]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) =>
      match f.geometry() {
        Some(@data.MultiPolygon(polys)) => assert_eq(polys.length(), 1)
        _ => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 PointZ" {
  let json = "{\"type\":\"Feature\",\"geometry\":{\"type\":\"Point\",\"coordinates\":[1.0,2.0,3.0]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) =>
      match f.geometry() {
        Some(@data.PointZ(p)) => {
          assert_true(approx(p.x(), 1.0, 0.001))
          assert_true(approx(p.y(), 2.0, 0.001))
          assert_true(approx(p.z(), 3.0, 0.001))
        }
        _ => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 写 PointZ" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs).with_geometry(
    @data.PointZ(@alg.Pt3::new(1.0, 2.0, 3.0)),
  )
  let json = feature_to_geojson(f)
  assert_true(json.contains("\"type\":\"Point\""))
  assert_true(json.contains("3"))
}

///|
test "GeoJSON 写 MultiLineString" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs).with_geometry(
    @data.MultiLineString([
      [@alg.Pt2::new(0.0, 0.0), @alg.Pt2::new(1.0, 1.0)],
      [@alg.Pt2::new(2.0, 2.0), @alg.Pt2::new(3.0, 3.0)],
    ]),
  )
  let json = feature_to_geojson(f)
  assert_true(json.contains("\"type\":\"MultiLineString\""))
}

///|
test "GeoJSON 写 MultiPolygon" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs).with_geometry(
    @data.MultiPolygon([
      (
        [
          @alg.Pt2::new(0.0, 0.0),
          @alg.Pt2::new(1.0, 0.0),
          @alg.Pt2::new(1.0, 1.0),
          @alg.Pt2::new(0.0, 0.0),
        ],
        [],
      ),
    ]),
  )
  let json = feature_to_geojson(f)
  assert_true(json.contains("\"type\":\"MultiPolygon\""))
}

///|
test "GeoJSON 写空属性" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs).with_geometry(
    @data.Point(@alg.Pt2::new(0.0, 0.0)),
  )
  let json = feature_to_geojson(f)
  assert_true(json.contains("\"properties\":{}"))
}

///|
test "GeoJSON 写无几何" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs).set("name", @data.StringVal("no_geom"))
  let json = feature_to_geojson(f)
  assert_true(json.contains("\"geometry\":null"))
}

///|
test "JSON 解析错误-非法字符" {
  match safe_parse("{bad}") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "JSON 解析错误-未闭合字符串" {
  match safe_parse("\"unclosed") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "JSON 解析错误-未闭合对象" {
  match safe_parse("{\"a\":1") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "JSON 解析错误-未闭合数组" {
  match safe_parse("[1,2,3") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "GeoJSON 读错误-缺少 type" {
  match safe_feature("{\"coordinates\":[0,0],\"properties\":{}}") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "local_parse_double 整数" {
  assert_true(approx(local_parse_double("42"), 42.0, 0.001))
}

///|
test "local_parse_double 小数" {
  assert_true(approx(local_parse_double("3.14"), 3.14, 0.001))
}

///|
test "local_parse_double 负数" {
  assert_true(approx(local_parse_double("-2.5"), -2.5, 0.001))
}

///|
test "local_parse_double 科学记数法" {
  assert_true(approx(local_parse_double("1e3"), 1000.0, 0.1))
  assert_true(approx(local_parse_double("1.5e2"), 150.0, 0.1))
  assert_true(approx(local_parse_double("1e-2"), 0.01, 0.001))
}

///|
test "GeoJSON 往返带属性" {
  let crs = @crs.wgs84_geographic()
  let f1 = @data.Feature::new(crs)
    .with_geometry(@data.Point(@alg.Pt2::new(1.0, 2.0)))
    .set("id", @data.IntVal(100))
    .set("name", @data.StringVal("hello"))
    .set("flag", @data.BoolVal(true))
  let json = feature_to_geojson(f1)
  match safe_feature(json) {
    Some(f2) => {
      match f2.get("name") {
        Some(@data.StringVal(s)) => assert_eq(s, "hello")
        _ => assert_true(false)
      }
      match f2.get("flag") {
        Some(@data.BoolVal(true)) => ()
        _ => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "GeoJSON CRS CGCS2000" {
  let crs = @crs.cgcs2000_geographic()
  let f = @data.Feature::new(crs).with_geometry(
    @data.Point(@alg.Pt2::new(0.0, 0.0)),
  )
  let json = feature_to_geojson(f)
  assert_true(json.contains("4490"))
}

///|
test "GeoJSON 读 CRS CGCS2000" {
  let json = "{\"type\":\"Feature\",\"crs\":{\"type\":\"name\",\"properties\":{\"name\":\"urn:ogc:def:crs:EPSG::4490\"}},\"geometry\":{\"type\":\"Point\",\"coordinates\":[0,0]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) => {
      let crs = f.crs()
      match crs.epsg {
        Some(code) => assert_eq(code, 4490)
        None => assert_true(false)
      }
    }
    None => assert_true(false)
  }
}

///|
test "JSON 解析 \\uXXXX 转义" {
  match safe_parse("\"\\u0041\\u0042\\u0043\"") {
    Some(JsonString(s)) => assert_eq(s, "ABC")
    _ => assert_true(false)
  }
}

///|
test "JSON 解析 \\uXXXX 中文" {
  match safe_parse("\"\\u4e2d\\u6587\"") {
    Some(JsonString(s)) => assert_eq(s, "中文")
    _ => assert_true(false)
  }
}

///|
test "JSON 解析 \\b 和 \\f 转义" {
  match safe_parse("\"a\\bb\\fc\"") {
    Some(JsonString(s)) => assert_eq(s.length(), 5)
    _ => assert_true(false)
  }
}

///|
test "JSON 解析错误-残缺数字只有负号" {
  match safe_parse("-") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "JSON 解析错误-残缺小数" {
  match safe_parse("1.") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "JSON 解析错误-残缺指数" {
  match safe_parse("1e") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "JSON 解析错误-残缺 \\uXXXX" {
  match safe_parse("\"\\u00\"") {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "GeoJSON 读 GeometryCollection" {
  let json = "{\"type\":\"Feature\",\"geometry\":{\"type\":\"GeometryCollection\",\"geometries\":[{\"type\":\"Point\",\"coordinates\":[1,2]},{\"type\":\"LineString\",\"coordinates\":[[0,0],[1,1]]}]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) =>
      match f.geometry() {
        Some(@data.GeometryCollection(geoms)) => {
          assert_eq(geoms.length(), 2)
          assert_eq(geoms[0].type_name(), "Point")
          assert_eq(geoms[1].type_name(), "LineString")
        }
        _ => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 写 GeometryCollection" {
  let crs = @crs.wgs84_geographic()
  let f = @data.Feature::new(crs).with_geometry(
    @data.GeometryCollection([
      @data.Point(@alg.Pt2::new(1.0, 2.0)),
      @data.LineString([@alg.Pt2::new(0.0, 0.0), @alg.Pt2::new(1.0, 1.0)]),
    ]),
  )
  let json = feature_to_geojson(f)
  assert_true(json.contains("\"type\":\"GeometryCollection\""))
  assert_true(json.contains("\"geometries\":["))
}

///|
test "GeoJSON GeometryCollection 往返" {
  let original = @data.GeometryCollection([
    @data.Point(@alg.Pt2::new(1.0, 2.0)),
    @data.LineString([@alg.Pt2::new(0.0, 0.0), @alg.Pt2::new(3.0, 4.0)]),
  ])
  let json = geometry_to_geojson(original)
  let feature_json = "{\"type\":\"Feature\",\"geometry\":" +
    json +
    ",\"properties\":{}}"
  match safe_feature(feature_json) {
    Some(f) =>
      match f.geometry() {
        Some(@data.GeometryCollection(geoms)) => {
          assert_eq(geoms.length(), 2)
          assert_eq(geoms[0].type_name(), "Point")
          assert_eq(geoms[1].type_name(), "LineString")
        }
        _ => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "JSON 递归深度超限 raise FormatError" {
  let mut json = ""
  let mut i = 0
  while i < 1002 {
    json += "["
    i += 1
  }
  i = 0
  while i < 1002 {
    json += "]"
    i += 1
  }
  match safe_parse(json) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}

///|
test "GeoJSON 读 GeometryCollection 空" {
  let json = "{\"type\":\"Feature\",\"geometry\":{\"type\":\"GeometryCollection\",\"geometries\":[]},\"properties\":{}}"
  match safe_feature(json) {
    Some(f) =>
      match f.geometry() {
        Some(@data.GeometryCollection(geoms)) => assert_eq(geoms.length(), 0)
        _ => assert_true(false)
      }
    None => assert_true(false)
  }
}

///|
test "GeoJSON 读 GeometryCollection 缺 geometries" {
  let json = "{\"type\":\"Feature\",\"geometry\":{\"type\":\"GeometryCollection\"},\"properties\":{}}"
  match safe_feature(json) {
    Some(_) => assert_true(false)
    None => assert_true(true)
  }
}
