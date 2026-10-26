// GeoJSON 反序列化
// platform/io，将 GeoJSON 字符串解析为 Feature/Layer/Dataset
// 依赖 json_parser 解析 JSON，再映射到 data 模型
// 解析出的坐标用 @alg.Pt2/Pt3 构造

///|
/// 从 GeoJSON 字符串解析 Feature
pub fn feature_from_geojson(
  json : String,
) -> @data.Feature raise @util.GeoError {
  let v = parse_json(json)
  feature_from_json(v)
}

///|
/// 从 GeoJSON 字符串解析 Layer（FeatureCollection）
pub fn layer_from_geojson(
  json : String,
  layer_name : String,
) -> @data.Layer raise @util.GeoError {
  let v = parse_json(json)
  layer_from_json(v, layer_name)
}

///|
/// 从 JsonValue 解析 Feature
fn feature_from_json(v : JsonValue) -> @data.Feature raise @util.GeoError {
  match json_get(v, "type") {
    Some(JsonString(t)) =>
      if t != "Feature" {
        raise @util.GeoError::FormatError(
          "期望 Feature 类型，得到: \{t}",
        )
      }
    None => raise @util.GeoError::FormatError("Feature 缺少 type 字段")
    _ => raise @util.GeoError::FormatError("Feature type 字段应为字符串")
  }
  let crs = parse_crs_from_json(v)
  let mut feature = @data.Feature::new(crs)
  match json_get(v, "geometry") {
    Some(geom_json) =>
      match geom_json {
        JsonNull => ()
        _ => {
          let geom = geometry_from_json(geom_json)
          feature = feature.with_geometry(geom)
        }
      }
    None => ()
  }
  match json_get(v, "properties") {
    Some(props) => feature = parse_properties(feature, props)
    None => ()
  }
  feature
}

///|
/// 从 JsonValue 解析 Layer
fn layer_from_json(
  v : JsonValue,
  name : String,
) -> @data.Layer raise @util.GeoError {
  let crs = parse_crs_from_json(v)
  let mut layer = @data.Layer::new(name, crs)
  match json_get(v, "features") {
    Some(JsonArray(features)) =>
      for f_json in features {
        let feature = feature_from_json(f_json)
        layer = layer.add_feature(feature)
      }
    _ =>
      raise @util.GeoError::FormatError(
        "FeatureCollection 缺少 features 数组",
      )
  }
  layer
}

///|
/// 从 JsonValue 解析 CRS
fn parse_crs_from_json(v : JsonValue) -> @crs.Crs {
  match json_get(v, "crs") {
    Some(crs_json) =>
      match json_get(crs_json, "properties") {
        Some(props) =>
          match json_get(props, "name") {
            Some(JsonString(name)) => parse_crs_name(name)
            _ => @crs.wgs84_geographic()
          }
        _ => @crs.wgs84_geographic()
      }
    None => @crs.wgs84_geographic()
  }
}

///|
/// 从 CRS 名称字符串解析 CRS
fn parse_crs_name(name : String) -> @crs.Crs {
  if name.contains("EPSG::4326") || name.contains("EPSG:4326") {
    return @crs.wgs84_geographic()
  }
  if name.contains("EPSG::4490") || name.contains("EPSG:4490") {
    return @crs.cgcs2000_geographic()
  }
  if name.contains("EPSG::3857") || name.contains("EPSG:3857") {
    return @crs.web_mercator()
  }
  @crs.wgs84_geographic()
}

///|
/// 从 JsonValue 解析 Geometry
fn geometry_from_json(v : JsonValue) -> @data.Geometry raise @util.GeoError {
  match json_get(v, "type") {
    Some(JsonString(type_str)) =>
      match json_get(v, "coordinates") {
        Some(coords) => parse_geometry_by_type(type_str, coords)
        None =>
          match type_str {
            "GeometryCollection" =>
              match json_get(v, "geometries") {
                Some(JsonArray(geoms)) => {
                  let result : Array[@data.Geometry] = []
                  for geom_json in geoms {
                    result.push(geometry_from_json(geom_json))
                  }
                  @data.GeometryCollection(result)
                }
                _ =>
                  raise @util.GeoError::FormatError(
                    "GeometryCollection 缺少 geometries 字段",
                  )
              }
            _ =>
              raise @util.GeoError::FormatError(
                "几何缺少 coordinates 字段",
              )
          }
      }
    _ => raise @util.GeoError::FormatError("几何缺少 type 字段")
  }
}

///|
/// 按类型解析几何
fn parse_geometry_by_type(
  type_str : String,
  coords : JsonValue,
) -> @data.Geometry raise @util.GeoError {
  match type_str {
    "Point" => parse_point(coords)
    "LineString" => parse_line_string(coords)
    "Polygon" => parse_polygon(coords)
    "MultiPoint" => {
      let pts = parse_coord_array(coords)
      @data.MultiPoint(pts)
    }
    "MultiLineString" => parse_multi_line_string(coords)
    "MultiPolygon" => parse_multi_polygon(coords)
    _ =>
      raise @util.GeoError::Unsupported("不支持的几何类型: \{type_str}")
  }
}

///|
/// 解析 Point 坐标
fn parse_point(coords : JsonValue) -> @data.Geometry raise @util.GeoError {
  match coords {
    JsonArray(arr) => {
      if arr.length() < 2 {
        raise @util.GeoError::FormatError(
          "Point 坐标至少需要 2 个元素",
        )
      }
      let x = get_number(arr[0])
      let y = get_number(arr[1])
      if arr.length() >= 3 {
        let z = get_number(arr[2])
        @data.PointZ(@alg.Pt3::new(x, y, z))
      } else {
        @data.Point(@alg.Pt2::new(x, y))
      }
    }
    _ => raise @util.GeoError::FormatError("Point coordinates 应为数组")
  }
}

///|
/// 解析 LineString 坐标
fn parse_line_string(coords : JsonValue) -> @data.Geometry raise @util.GeoError {
  let pts = parse_coord_array(coords)
  @data.LineString(pts)
}

///|
/// 解析 Polygon 坐标
fn parse_polygon(coords : JsonValue) -> @data.Geometry raise @util.GeoError {
  match coords {
    JsonArray(rings) => {
      if rings.length() == 0 {
        raise @util.GeoError::FormatError("Polygon 至少需要一个环")
      }
      let exterior = parse_coord_array(rings[0])
      let interiors : Array[Array[@alg.Pt2]] = []
      let n = rings.length()
      for i in 1..<n {
        let ring = parse_coord_array(rings[i])
        interiors.push(ring)
      }
      @data.Polygon(exterior, interiors)
    }
    _ => raise @util.GeoError::FormatError("Polygon coordinates 应为数组")
  }
}

///|
/// 解析 MultiLineString 坐标
fn parse_multi_line_string(
  coords : JsonValue,
) -> @data.Geometry raise @util.GeoError {
  match coords {
    JsonArray(lines) => {
      let result : Array[Array[@alg.Pt2]] = []
      for line_json in lines {
        let line = parse_coord_array(line_json)
        result.push(line)
      }
      @data.MultiLineString(result)
    }
    _ =>
      raise @util.GeoError::FormatError(
        "MultiLineString coordinates 应为数组",
      )
  }
}

///|
/// 解析 MultiPolygon 坐标
fn parse_multi_polygon(
  coords : JsonValue,
) -> @data.Geometry raise @util.GeoError {
  match coords {
    JsonArray(polygons) => {
      let result : Array[(Array[@alg.Pt2], Array[Array[@alg.Pt2]])] = []
      for poly_json in polygons {
        match poly_json {
          JsonArray(rings) => {
            if rings.length() == 0 {
              raise @util.GeoError::FormatError(
                "MultiPolygon 子多边形至少需要一个环",
              )
            }
            let exterior = parse_coord_array(rings[0])
            let interiors : Array[Array[@alg.Pt2]] = []
            let n = rings.length()
            for i in 1..<n {
              let ring = parse_coord_array(rings[i])
              interiors.push(ring)
            }
            result.push((exterior, interiors))
          }
          _ =>
            raise @util.GeoError::FormatError(
              "MultiPolygon 子多边形应为数组",
            )
        }
      }
      @data.MultiPolygon(result)
    }
    _ =>
      raise @util.GeoError::FormatError("MultiPolygon coordinates 应为数组")
  }
}

///|
/// 解析坐标数组 [[x1,y1], [x2,y2], ...]
fn parse_coord_array(v : JsonValue) -> Array[@alg.Pt2] raise @util.GeoError {
  match v {
    JsonArray(arr) => {
      let result : Array[@alg.Pt2] = []
      for coord in arr {
        match coord {
          JsonArray(xy) => {
            if xy.length() < 2 {
              raise @util.GeoError::FormatError(
                "坐标至少需要 2 个元素",
              )
            }
            let x = get_number(xy[0])
            let y = get_number(xy[1])
            result.push(@alg.Pt2::new(x, y))
          }
          _ => raise @util.GeoError::FormatError("坐标应为数组")
        }
      }
      result
    }
    _ => raise @util.GeoError::FormatError("坐标数组应为 JSON 数组")
  }
}

///|
/// 从 JsonValue 获取数字（抛错版）
fn get_number(v : JsonValue) -> Double raise @util.GeoError {
  match v {
    JsonNumber(d) => d
    _ => raise @util.GeoError::FormatError("期望数字")
  }
}

///|
/// 解析 properties 对象，设置到 Feature
fn parse_properties(
  feature : @data.Feature,
  props : JsonValue,
) -> @data.Feature raise @util.GeoError {
  match props {
    JsonObject(entries) => {
      let mut f = feature
      for (key, val) in entries {
        let fv = json_to_field_value(val)
        f = f.set(key, fv)
      }
      f
    }
    JsonNull => feature
    _ => raise @util.GeoError::FormatError("properties 应为对象")
  }
}

///|
/// JsonValue 转 FieldValue
fn json_to_field_value(v : JsonValue) -> @data.FieldValue {
  match v {
    JsonNumber(d) => @data.DoubleVal(d)
    JsonString(s) => @data.StringVal(s)
    JsonBool(b) => @data.BoolVal(b)
    JsonNull => @data.NullVal
    JsonObject(_) => @data.NullVal
    JsonArray(_) => @data.NullVal
  }
}
