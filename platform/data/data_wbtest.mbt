// platform/data 白盒测试
// 测试 FieldValue、Geometry、Feature、Layer、Dataset
// Geometry 坐标用 @alg.Pt2/Pt3

///|
test "field value type_of" {
  assert_true(IntVal(42).type_of() is FieldType::Integer)
  assert_true(DoubleVal(3.14).type_of() is FieldType::Double)
  assert_true(StringVal("hello").type_of() is FieldType::String)
  assert_true(BoolVal(true).type_of() is FieldType::Boolean)
  assert_true(NullVal.type_of() is FieldType::String)
}

///|
test "field value as_int" {
  assert_eq(IntVal(42).as_int(), Some(42))
  assert_true(DoubleVal(3.14).as_int() is None)
  assert_true(NullVal.as_int() is None)
}

///|
test "field value as_double" {
  assert_true(
    @util.dbl_approx_eq(DoubleVal(3.14).as_double().unwrap(), 3.14, 1.0e-10),
  )
  assert_true(
    @util.dbl_approx_eq(IntVal(42).as_double().unwrap(), 42.0, 1.0e-10),
  )
  assert_true(NullVal.as_double() is None)
}

///|
test "field value as_string" {
  assert_eq(StringVal("hello").as_string(), Some("hello"))
  assert_true(IntVal(42).as_string() is None)
}

///|
test "field value as_bool" {
  assert_eq(BoolVal(true).as_bool(), Some(true))
  assert_eq(BoolVal(false).as_bool(), Some(false))
  assert_true(IntVal(42).as_bool() is None)
}

///|
test "field value is_null" {
  assert_true(NullVal.is_null())
  assert_false(IntVal(0).is_null())
  assert_false(StringVal("").is_null())
}

///|
test "field type match" {
  assert_true(field_type_match(FieldType::Integer, IntVal(42)))
  assert_true(field_type_match(FieldType::Double, DoubleVal(3.14)))
  assert_true(field_type_match(FieldType::String, StringVal("hi")))
  assert_true(field_type_match(FieldType::Boolean, BoolVal(true)))
  assert_true(field_type_match(FieldType::Integer, NullVal))
  assert_false(field_type_match(FieldType::Integer, DoubleVal(3.14)))
}

///|
test "geometry type_name" {
  assert_eq(Point(@alg.Pt2::new(1.0, 2.0)).type_name(), "Point")
  assert_eq(PointZ(@alg.Pt3::new(1.0, 2.0, 3.0)).type_name(), "PointZ")
  assert_eq(LineString([]).type_name(), "LineString")
  assert_eq(Polygon([], []).type_name(), "Polygon")
  assert_eq(MultiPoint([]).type_name(), "MultiPoint")
}

///|
test "geometry coord_count" {
  assert_eq(Point(@alg.Pt2::new(1.0, 2.0)).coord_count(), 1)
  assert_eq(PointZ(@alg.Pt3::new(1.0, 2.0, 3.0)).coord_count(), 1)
  assert_eq(
    LineString([@alg.Pt2::new(1.0, 2.0), @alg.Pt2::new(3.0, 4.0)]).coord_count(),
    2,
  )
  assert_eq(
    MultiPoint([
      @alg.Pt2::new(1.0, 2.0),
      @alg.Pt2::new(3.0, 4.0),
      @alg.Pt2::new(5.0, 6.0),
    ]).coord_count(),
    3,
  )
}

///|
test "feature basic" {
  let crs = @crs.wgs84_geographic()
  let f = Feature::new(crs)
  assert_false(f.has_geometry())
  assert_eq(f.attr_count(), 0)
}

///|
test "feature with geometry" {
  let crs = @crs.wgs84_geographic()
  let f = Feature::new(crs).with_geometry(Point(@alg.Pt2::new(116.4, 39.9)))
  assert_true(f.has_geometry())
  assert_true(f.geometry() is Some(_))
}

///|
test "feature set get attributes" {
  let crs = @crs.wgs84_geographic()
  let f = Feature::new(crs)
    .with_geometry(Point(@alg.Pt2::new(116.4, 39.9)))
    .set("name", StringVal("Beijing"))
    .set("population", IntVal(21540000))
    .set("area", DoubleVal(16410.0))
  assert_eq(f.attr_count(), 3)
  assert_eq(f.get("name"), Some(StringVal("Beijing")))
  assert_eq(f.get("population"), Some(IntVal(21540000)))
  assert_true(f.get("nonexistent") is None)
}

///|
test "feature set replaces existing" {
  let crs = @crs.wgs84_geographic()
  let f = Feature::new(crs).set("x", IntVal(1)).set("x", IntVal(2))
  assert_eq(f.attr_count(), 1)
  assert_eq(f.get("x"), Some(IntVal(2)))
}

///|
test "feature field_names" {
  let crs = @crs.wgs84_geographic()
  let f = Feature::new(crs).set("a", IntVal(1)).set("b", StringVal("hello"))
  let names = f.field_names()
  assert_eq(names.length(), 2)
}

///|
test "feature transform crs geographic to utm" {
  let geo_crs = @crs.wgs84_geographic()
  let utm_crs = @crs.wgs84_utm(50, true)
  let f = Feature::new(geo_crs)
    .with_geometry(Point(@alg.Pt2::new(116.4, 39.9)))
    .set("name", StringVal("Beijing"))
  let f2 = f.transform_crs(utm_crs)
  assert_true(f2.crs().epsg is Some(32650))
  match f2.geometry() {
    Some(Point(p)) => {
      assert_true(p.x() > 400000.0 && p.x() < 600000.0)
      assert_true(p.y() > 4000000.0 && p.y() < 5000000.0)
    }
    _ => assert_true(false)
  }
  assert_eq(f2.get("name"), Some(StringVal("Beijing")))
}

///|
test "feature transform crs same crs identity" {
  let crs = @crs.wgs84_geographic()
  let f = Feature::new(crs).with_geometry(Point(@alg.Pt2::new(116.4, 39.9)))
  let f2 = f.transform_crs(crs)
  match (f2.geometry(), f.geometry()) {
    (Some(Point(p1)), Some(Point(p2))) => {
      assert_true(@util.dbl_approx_eq(p1.x(), p2.x(), 1.0e-10))
      assert_true(@util.dbl_approx_eq(p1.y(), p2.y(), 1.0e-10))
    }
    _ => assert_true(false)
  }
}

///|
test "feature transform crs linestring" {
  let geo_crs = @crs.wgs84_geographic()
  let utm_crs = @crs.wgs84_utm(50, true)
  let f = Feature::new(geo_crs).with_geometry(
    LineString([@alg.Pt2::new(116.0, 39.0), @alg.Pt2::new(117.0, 40.0)]),
  )
  let f2 = f.transform_crs(utm_crs)
  match f2.geometry() {
    Some(LineString(coords)) => assert_eq(coords.length(), 2)
    _ => assert_true(false)
  }
}

///|
test "feature transform crs polygon" {
  let geo_crs = @crs.wgs84_geographic()
  let utm_crs = @crs.wgs84_utm(50, true)
  let exterior = [
    @alg.Pt2::new(116.0, 39.0),
    @alg.Pt2::new(117.0, 39.0),
    @alg.Pt2::new(117.0, 40.0),
    @alg.Pt2::new(116.0, 40.0),
    @alg.Pt2::new(116.0, 39.0),
  ]
  let f = Feature::new(geo_crs).with_geometry(Polygon(exterior, []))
  let f2 = f.transform_crs(utm_crs)
  match f2.geometry() {
    Some(Polygon(ext, _)) => assert_eq(ext.length(), 5)
    _ => assert_true(false)
  }
}

///|
test "layer basic" {
  let crs = @crs.wgs84_geographic()
  let layer = Layer::new("cities", crs)
  assert_eq(layer.name(), "cities")
  assert_eq(layer.feature_count(), 0)
}

///|
test "layer add features" {
  let crs = @crs.wgs84_geographic()
  let f1 = Feature::new(crs)
    .with_geometry(Point(@alg.Pt2::new(116.4, 39.9)))
    .set("name", StringVal("Beijing"))
  let f2 = Feature::new(crs)
    .with_geometry(Point(@alg.Pt2::new(121.4, 31.2)))
    .set("name", StringVal("Shanghai"))
  let layer = Layer::new("cities", crs).add_feature(f1).add_feature(f2)
  assert_eq(layer.feature_count(), 2)
  assert_true(layer.get_feature(0) is Some(_))
  assert_true(layer.get_feature(1) is Some(_))
  assert_true(layer.get_feature(2) is None)
  assert_true(layer.get_feature(-1) is None)
}

///|
test "layer add fields" {
  let crs = @crs.wgs84_geographic()
  let layer = Layer::new("cities", crs)
    .add_field("name", FieldType::String)
    .add_field("population", FieldType::Integer)
  assert_eq(layer.field_count(), 2)
}

///|
test "layer filter" {
  let crs = @crs.wgs84_geographic()
  let f1 = Feature::new(crs).set("country", StringVal("China"))
  let f2 = Feature::new(crs).set("country", StringVal("USA"))
  let f3 = Feature::new(crs).set("country", StringVal("China"))
  let layer = Layer::new("cities", crs)
    .add_feature(f1)
    .add_feature(f2)
    .add_feature(f3)
  let filtered = layer.filter("country", StringVal("China"))
  assert_eq(filtered.feature_count(), 2)
}

///|
test "layer transform crs" {
  let geo_crs = @crs.wgs84_geographic()
  let utm_crs = @crs.wgs84_utm(50, true)
  let f = Feature::new(geo_crs).with_geometry(Point(@alg.Pt2::new(116.4, 39.9)))
  let layer = Layer::new("test", geo_crs).add_feature(f)
  let layer2 = layer.transform_crs(utm_crs)
  assert_eq(layer2.feature_count(), 1)
  assert_true(layer2.crs().epsg is Some(32650))
}

///|
test "dataset basic" {
  let ds = Dataset::new("my_dataset")
  assert_eq(ds.name(), "my_dataset")
  assert_eq(ds.layer_count(), 0)
  assert_eq(ds.total_features(), 0)
}

///|
test "dataset add layers" {
  let crs = @crs.wgs84_geographic()
  let layer1 = Layer::new("cities", crs).add_feature(Feature::new(crs))
  let layer2 = Layer::new("roads", crs)
    .add_feature(Feature::new(crs))
    .add_feature(Feature::new(crs))
  let ds = Dataset::new("data").add_layer(layer1).add_layer(layer2)
  assert_eq(ds.layer_count(), 2)
  assert_eq(ds.total_features(), 3)
}

///|
test "dataset get layer by name" {
  let crs = @crs.wgs84_geographic()
  let layer1 = Layer::new("cities", crs)
  let layer2 = Layer::new("roads", crs)
  let ds = Dataset::new("data").add_layer(layer1).add_layer(layer2)
  assert_true(ds.get_layer("cities") is Some(_))
  assert_true(ds.get_layer("roads") is Some(_))
  assert_true(ds.get_layer("nonexistent") is None)
}

///|
test "dataset get layer by index" {
  let crs = @crs.wgs84_geographic()
  let layer1 = Layer::new("cities", crs)
  let layer2 = Layer::new("roads", crs)
  let ds = Dataset::new("data").add_layer(layer1).add_layer(layer2)
  assert_true(ds.get_layer_by_index(0) is Some(_))
  assert_true(ds.get_layer_by_index(1) is Some(_))
  assert_true(ds.get_layer_by_index(2) is None)
  assert_true(ds.get_layer_by_index(-1) is None)
}

///|
test "dataset metadata" {
  let ds = Dataset::new("data")
    .set_meta("author", "test")
    .set_meta("version", "1.0")
  assert_eq(ds.get_meta("author"), Some("test"))
  assert_eq(ds.get_meta("version"), Some("1.0"))
  assert_true(ds.get_meta("nonexistent") is None)
  let ds2 = ds.set_meta("author", "updated")
  assert_eq(ds2.get_meta("author"), Some("updated"))
  assert_eq(ds.get_meta("author"), Some("test"))
}

///|
test "feature immutability" {
  let crs = @crs.wgs84_geographic()
  let f1 = Feature::new(crs).set("x", IntVal(1))
  let f2 = f1.set("y", IntVal(2))
  assert_eq(f1.attr_count(), 1)
  assert_eq(f2.attr_count(), 2)
  assert_eq(f1.get("y"), None)
  assert_eq(f2.get("y"), Some(IntVal(2)))
}

///|
test "feature pointz transform" {
  let geo_crs = @crs.wgs84_geographic()
  let utm_crs = @crs.wgs84_utm(50, true)
  let f = Feature::new(geo_crs).with_geometry(
    PointZ(@alg.Pt3::new(116.4, 39.9, 50.0)),
  )
  let f2 = f.transform_crs(utm_crs)
  match f2.geometry() {
    Some(PointZ(p)) => assert_true(@util.dbl_approx_eq(p.z(), 50.0, 1.0e-10))
    _ => assert_true(false)
  }
}

///|
test "feature no geometry transform" {
  let geo_crs = @crs.wgs84_geographic()
  let utm_crs = @crs.wgs84_utm(50, true)
  let f = Feature::new(geo_crs).set("name", StringVal("attr_only"))
  let f2 = f.transform_crs(utm_crs)
  assert_false(f2.has_geometry())
  assert_eq(f2.get("name"), Some(StringVal("attr_only")))
}

///|
test "geometry multipoint coord_count" {
  let g = MultiPoint([
    @alg.Pt2::new(1.0, 2.0),
    @alg.Pt2::new(3.0, 4.0),
    @alg.Pt2::new(5.0, 6.0),
    @alg.Pt2::new(7.0, 8.0),
  ])
  assert_eq(g.coord_count(), 4)
}

///|
test "geometry multilinestring coord_count" {
  let g = MultiLineString([
    [@alg.Pt2::new(1.0, 2.0), @alg.Pt2::new(3.0, 4.0)],
    [@alg.Pt2::new(5.0, 6.0), @alg.Pt2::new(7.0, 8.0), @alg.Pt2::new(9.0, 10.0)],
  ])
  assert_eq(g.coord_count(), 5)
}

///|
test "geometry polygon coord_count" {
  let exterior = [
    @alg.Pt2::new(0.0, 0.0),
    @alg.Pt2::new(10.0, 0.0),
    @alg.Pt2::new(10.0, 10.0),
    @alg.Pt2::new(0.0, 10.0),
    @alg.Pt2::new(0.0, 0.0),
  ]
  let hole = [
    @alg.Pt2::new(2.0, 2.0),
    @alg.Pt2::new(8.0, 2.0),
    @alg.Pt2::new(8.0, 8.0),
    @alg.Pt2::new(2.0, 8.0),
    @alg.Pt2::new(2.0, 2.0),
  ]
  let g = Polygon(exterior, [hole])
  assert_eq(g.coord_count(), 10)
}
