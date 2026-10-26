// CRS 白盒测试
// 测试椭球参数、UTM 正反算、Web Mercator、EPSG 查询、坐标变换

///|
test "wgs84_ellipsoid parameters" {
  let e = wgs84_ellipsoid()
  assert_true(@util.dbl_approx_eq(e.a, 6378137.0, 1.0e-6))
  assert_true(@util.dbl_approx_eq(e.f, 1.0 / 298.257223563, 1.0e-15))
  assert_true(@util.dbl_approx_eq(e.b, 6356752.314245, 1.0e-3))
  assert_true(e.e_sq > 0.0 && e.e_sq < 0.01)
  assert_true(e.ep_sq > 0.0 && e.ep_sq < 0.01)
}

///|
test "cgcs2000_ellipsoid parameters" {
  let e = cgcs2000_ellipsoid()
  assert_true(@util.dbl_approx_eq(e.a, 6378137.0, 1.0e-6))
  assert_true(@util.dbl_approx_eq(e.f, 1.0 / 298.257222101, 1.0e-15))
  assert_true(e.e_sq > 0.0 && e.e_sq < 0.01)
}

///|
test "wgs84 vs cgcs2000 nearly identical" {
  let w = wgs84_ellipsoid()
  let c = cgcs2000_ellipsoid()
  assert_true(@util.dbl_approx_eq(w.a, c.a, 1.0e-6))
  assert_true(@util.dbl_approx_eq(w.b, c.b, 0.01))
  assert_true(@util.dbl_approx_eq(w.e_sq, c.e_sq, 1.0e-10))
}

///|
test "utm_central_meridian" {
  assert_true(@util.dbl_approx_eq(utm_central_meridian(1), -177.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(utm_central_meridian(30), -3.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(utm_central_meridian(31), 3.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(utm_central_meridian(50), 117.0, 1.0e-10))
  assert_true(@util.dbl_approx_eq(utm_central_meridian(60), 177.0, 1.0e-10))
}

///|
test "utm_zone_from_lon" {
  assert_eq(utm_zone_from_lon(-180.0), 1)
  assert_eq(utm_zone_from_lon(-179.0), 1)
  assert_eq(utm_zone_from_lon(-177.0), 1)
  assert_eq(utm_zone_from_lon(-174.0), 2)
  assert_eq(utm_zone_from_lon(0.0), 31)
  assert_eq(utm_zone_from_lon(116.0), 50)
  assert_eq(utm_zone_from_lon(116.4), 50)
  assert_eq(utm_zone_from_lon(180.0), 61)
}

///|
test "utm forward inverse roundtrip beijing" {
  let proj = UtmProjection::new(50, true)
  let lon = 116.4
  let lat = 39.9
  let (e, n) = proj.forward(lon, lat)
  assert_true(e > 400000.0 && e < 600000.0)
  assert_true(n > 4000000.0 && n < 5000000.0)
  let (lon2, lat2) = proj.inverse(e, n)
  assert_true(@util.dbl_approx_eq(lon, lon2, 1.0e-8))
  assert_true(@util.dbl_approx_eq(lat, lat2, 1.0e-8))
}

///|
test "utm forward inverse roundtrip newyork" {
  let proj = UtmProjection::new(18, true)
  let lon = -74.0
  let lat = 40.7
  let (e, n) = proj.forward(lon, lat)
  let (lon2, lat2) = proj.inverse(e, n)
  assert_true(@util.dbl_approx_eq(lon, lon2, 1.0e-8))
  assert_true(@util.dbl_approx_eq(lat, lat2, 1.0e-8))
}

///|
test "utm forward inverse roundtrip sydney" {
  let proj = UtmProjection::new(56, false)
  let lon = 151.2
  let lat = -33.8
  let (e, n) = proj.forward(lon, lat)
  let (lon2, lat2) = proj.inverse(e, n)
  assert_true(@util.dbl_approx_eq(lon, lon2, 1.0e-8))
  assert_true(@util.dbl_approx_eq(lat, lat2, 1.0e-8))
}

///|
test "utm forward inverse roundtrip london" {
  let proj = UtmProjection::new(30, true)
  let lon = -0.126
  let lat = 51.5
  let (e, n) = proj.forward(lon, lat)
  let (lon2, lat2) = proj.inverse(e, n)
  assert_true(@util.dbl_approx_eq(lon, lon2, 1.0e-8))
  assert_true(@util.dbl_approx_eq(lat, lat2, 1.0e-8))
}

///|
test "utm forward inverse roundtrip equator" {
  let proj = UtmProjection::new(31, true)
  let lon = 3.0
  let lat = 0.0
  let (e, n) = proj.forward(lon, lat)
  assert_true(@util.dbl_approx_eq(e, 500000.0, 0.001))
  assert_true(@util.dbl_approx_eq(n, 0.0, 0.001))
  let (lon2, lat2) = proj.inverse(e, n)
  assert_true(@util.dbl_approx_eq(lon, lon2, 1.0e-8))
  assert_true(@util.dbl_approx_eq(lat, lat2, 1.0e-8))
}

///|
test "utm southern hemisphere false northing" {
  let proj_north = UtmProjection::new(31, true)
  let proj_south = UtmProjection::new(31, false)
  let (e_n, n_n) = proj_north.forward(0.0, 1.0)
  let (e_s, n_s) = proj_south.forward(0.0, -1.0)
  assert_true(@util.dbl_approx_eq(e_n, e_s, 0.001))
  assert_true(n_s > 9000000.0)
  assert_true(@util.dbl_approx_eq(n_n + n_s, 10000000.0, 0.001))
}

///|
test "utm cgcs2000 roundtrip" {
  let ellipsoid = cgcs2000_ellipsoid()
  let proj = UtmProjection::with_ellipsoid(ellipsoid, 50, true)
  let lon = 116.4
  let lat = 39.9
  let (e, n) = proj.forward(lon, lat)
  let (lon2, lat2) = proj.inverse(e, n)
  assert_true(@util.dbl_approx_eq(lon, lon2, 1.0e-8))
  assert_true(@util.dbl_approx_eq(lat, lat2, 1.0e-8))
}

///|
test "web mercator forward inverse roundtrip" {
  let proj = WebMercator::new()
  let lon = 116.4
  let lat = 39.9
  let (x, y) = proj.forward(lon, lat)
  let (lon2, lat2) = proj.inverse(x, y)
  assert_true(@util.dbl_approx_eq(lon, lon2, 1.0e-8))
  assert_true(@util.dbl_approx_eq(lat, lat2, 1.0e-8))
}

///|
test "web mercator origin" {
  let proj = WebMercator::new()
  let (x, y) = proj.forward(0.0, 0.0)
  assert_true(@util.dbl_approx_eq(x, 0.0, 1.0e-6))
  assert_true(@util.dbl_approx_eq(y, 0.0, 1.0e-6))
}

///|
test "web mercator 180 degrees" {
  let proj = WebMercator::new()
  let (x, y) = proj.forward(180.0, 0.0)
  let expected = 6378137.0 * @math.PI
  assert_true(@util.dbl_approx_eq(x, expected, 0.001))
  assert_true(@util.dbl_approx_eq(y, 0.0, 0.001))
}

///|
test "web mercator roundtrip extreme" {
  let proj = WebMercator::new()
  let lon = -122.42
  let lat = 37.77
  let (x, y) = proj.forward(lon, lat)
  let (lon2, lat2) = proj.inverse(x, y)
  assert_true(@util.dbl_approx_eq(lon, lon2, 1.0e-8))
  assert_true(@util.dbl_approx_eq(lat, lat2, 1.0e-8))
}

///|
test "epsg lookup common" {
  let c4326 = epsg_lookup(4326)
  assert_true(c4326 is Some(_))
  let c3857 = epsg_lookup(3857)
  assert_true(c3857 is Some(_))
  let c4490 = epsg_lookup(4490)
  assert_true(c4490 is Some(_))
}

///|
test "epsg lookup utm" {
  let c32650 = epsg_lookup(32650)
  assert_true(c32650 is Some(_))
  let c32756 = epsg_lookup(32756)
  assert_true(c32756 is Some(_))
}

///|
test "epsg lookup unknown" {
  let c = epsg_lookup(99999)
  assert_true(c is None)
}

///|
test "epsg code retrieval" {
  let crs = wgs84_geographic()
  assert_eq(epsg_code(crs), Some(4326))
  let utm = wgs84_utm(50, true)
  assert_eq(epsg_code(utm), Some(32650))
  let wm = web_mercator()
  assert_eq(epsg_code(wm), Some(3857))
}

///|
test "crs equivalent" {
  let a = wgs84_geographic()
  let b = wgs84_geographic()
  assert_true(crs_equivalent(a, b))
  let c = web_mercator()
  assert_false(crs_equivalent(a, c))
}

///|
test "transform coord geographic to utm and back" {
  let from = wgs84_geographic()
  let to = wgs84_utm(50, true)
  let lon = 116.4
  let lat = 39.9
  let (e, n) = transform_coord((lon, lat), from, to)
  assert_true(e > 400000.0 && e < 600000.0)
  assert_true(n > 4000000.0 && n < 5000000.0)
  let (lon2, lat2) = transform_coord((e, n), to, from)
  assert_true(@util.dbl_approx_eq(lon, lon2, 1.0e-8))
  assert_true(@util.dbl_approx_eq(lat, lat2, 1.0e-8))
}

///|
test "transform coord geographic to web mercator and back" {
  let from = wgs84_geographic()
  let to = web_mercator()
  let lon = -122.42
  let lat = 37.77
  let (x, y) = transform_coord((lon, lat), from, to)
  let (lon2, lat2) = transform_coord((x, y), to, from)
  assert_true(@util.dbl_approx_eq(lon, lon2, 1.0e-8))
  assert_true(@util.dbl_approx_eq(lat, lat2, 1.0e-8))
}

///|
test "transform coord utm to utm same zone identity" {
  let from = wgs84_utm(50, true)
  let to = wgs84_utm(50, true)
  let (e, n) = (448501.0, 4418639.0)
  let (e2, n2) = transform_coord((e, n), from, to)
  assert_true(@util.dbl_approx_eq(e, e2, 0.001))
  assert_true(@util.dbl_approx_eq(n, n2, 0.001))
}

///|
test "transform coord utm to web mercator" {
  let from = wgs84_utm(50, true)
  let to = web_mercator()
  let (e, n) = (500000.0, 4000000.0)
  let (x, y) = transform_coord((e, n), from, to)
  let (e2, n2) = transform_coord((x, y), to, from)
  assert_true(@util.dbl_approx_eq(e, e2, 0.001))
  assert_true(@util.dbl_approx_eq(n, n2, 0.001))
}

///|
test "datum ellipsoid lookup" {
  let w = datum_ellipsoid(Datum::WGS84)
  assert_true(@util.dbl_approx_eq(w.a, 6378137.0, 1.0e-6))
  let c = datum_ellipsoid(Datum::CGCS2000)
  assert_true(@util.dbl_approx_eq(c.a, 6378137.0, 1.0e-6))
}

///|
test "crs kind and datum" {
  let geo = wgs84_geographic()
  assert_true(geo.kind is CrsKind::Geographic)
  assert_true(geo.datum is Datum::WGS84)
  let utm = wgs84_utm(50, true)
  assert_true(utm.kind is CrsKind::Projected)
  assert_true(utm.datum is Datum::WGS84)
  let wm = web_mercator()
  assert_true(wm.kind is CrsKind::Projected)
}

///|
test "utm 绝对精度锚点-中央经线赤道" {
  let proj = UtmProjection::new(50, true)
  let (e, n) = proj.forward(117.0, 0.0)
  assert_true(@util.dbl_approx_eq(e, 500000.0, 1.0e-6))
  assert_true(@util.dbl_approx_eq(n, 0.0, 1.0e-6))
}

///|
test "utm 绝对精度锚点-南半球赤道" {
  let proj = UtmProjection::new(50, false)
  let (e, n) = proj.forward(117.0, 0.0)
  assert_true(@util.dbl_approx_eq(e, 500000.0, 1.0e-6))
  assert_true(@util.dbl_approx_eq(n, 10000000.0, 1.0e-6))
}

///|
test "utm 绝对精度锚点-中央经线高纬" {
  let proj = UtmProjection::new(31, true)
  let (e, _) = proj.forward(3.0, 60.0)
  assert_true(@util.dbl_approx_eq(e, 500000.0, 1.0e-6))
}
