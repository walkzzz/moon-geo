// 坐标参考系核心定义
// P1 层 platform/crs，依赖 util（GeoError）
// 定义椭球参数、基准面、CRS 类型、投影方法
// 预定义 WGS84 / CGCS2000 常用 CRS

///|
/// 椭球参数
pub struct Ellipsoid {
  a : Double
  b : Double
  f : Double
  e_sq : Double
  ep_sq : Double
}

///|
/// WGS84 椭球（EPSG:7030）
pub fn wgs84_ellipsoid() -> Ellipsoid {
  let a = 6378137.0
  let f = 1.0 / 298.257223563
  let b = a * (1.0 - f)
  let e_sq = 2.0 * f - f * f
  let ep_sq = e_sq / (1.0 - e_sq)
  { a, b, f, e_sq, ep_sq, }
}

///|
/// CGCS2000 椭球（与 WGS84 几乎一致，扁率微差）
pub fn cgcs2000_ellipsoid() -> Ellipsoid {
  let a = 6378137.0
  let f = 1.0 / 298.257222101
  let b = a * (1.0 - f)
  let e_sq = 2.0 * f - f * f
  let ep_sq = e_sq / (1.0 - e_sq)
  { a, b, f, e_sq, ep_sq, }
}

///|
/// 基准面
pub enum Datum {
  WGS84
  CGCS2000
}

///|
/// 获取基准面对应的椭球
pub fn datum_ellipsoid(datum : Datum) -> Ellipsoid {
  match datum {
    Datum::WGS84 => wgs84_ellipsoid()
    Datum::CGCS2000 => cgcs2000_ellipsoid()
  }
}

///|
/// CRS 类型
pub enum CrsKind {
  Geographic
  Projected
}

///|
/// 投影方法
pub enum ProjectionMethod {
  Utm(Int32, Bool)
  WebMercator
}

///|
/// 坐标参考系
pub struct Crs {
  kind : CrsKind
  datum : Datum
  projection : ProjectionMethod?
  epsg : Int32?
}

///|
/// WGS84 地理坐标系（EPSG:4326，经纬度，度）
pub fn wgs84_geographic() -> Crs {
  {
    kind: CrsKind::Geographic,
    datum: Datum::WGS84,
    projection: None,
    epsg: Some(4326),
  }
}

///|
/// CGCS2000 地理坐标系（EPSG:4490，经纬度，度）
pub fn cgcs2000_geographic() -> Crs {
  {
    kind: CrsKind::Geographic,
    datum: Datum::CGCS2000,
    projection: None,
    epsg: Some(4490),
  }
}

///|
/// WGS84 UTM 投影坐标系（北半球 EPSG:326xx，南半球 EPSG:327xx）
pub fn wgs84_utm(zone : Int32, north : Bool) -> Crs {
  let epsg = if north { 32600 + zone } else { 32700 + zone }
  {
    kind: CrsKind::Projected,
    datum: Datum::WGS84,
    projection: Some(ProjectionMethod::Utm(zone, north)),
    epsg: Some(epsg),
  }
}

///|
/// Web Mercator 投影坐标系（EPSG:3857，球面墨卡托）
pub fn web_mercator() -> Crs {
  {
    kind: CrsKind::Projected,
    datum: Datum::WGS84,
    projection: Some(ProjectionMethod::WebMercator),
    epsg: Some(3857),
  }
}

///|
/// 根据 UTM 带号计算中央经线（度）
pub fn utm_central_meridian(zone : Int32) -> Double {
  zone.to_double() * 6.0 - 183.0
}

///|
/// 根据经度计算 UTM 带号
pub fn utm_zone_from_lon(lon_deg : Double) -> Int32 {
  ((lon_deg + 180.0) / 6.0).floor().to_int() + 1
}
