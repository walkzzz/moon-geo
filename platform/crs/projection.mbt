// 投影变换：UTM 正反算 + Web Mercator + 坐标变换
// P1 层 platform/crs，依赖 util（GeoError）、math（三角函数）
// UTM 公式参考 Snyder "Map Projections - A Working Manual" USGS PP-1395
// Web Mercator 参考 EPSG:3857 球面墨卡托定义

///|
/// UTM 投影
pub struct UtmProjection {
  ellipsoid : Ellipsoid
  zone : Int32
  north : Bool
}

///|
/// 构造 UTM 投影（默认 WGS84 椭球）
pub fn UtmProjection::new(zone : Int32, north : Bool) -> UtmProjection {
  { ellipsoid: wgs84_ellipsoid(), zone, north, }
}

///|
/// 用指定椭球构造 UTM 投影
pub fn UtmProjection::with_ellipsoid(
  ellipsoid : Ellipsoid,
  zone : Int32,
  north : Bool,
) -> UtmProjection {
  { ellipsoid, zone, north, }
}

///|
/// UTM 投影常量
const UTM_K0 : Double = 0.9996

///|
const UTM_FE : Double = 500000.0

///|
const UTM_FN_SOUTH : Double = 10000000.0

///|
/// UTM 正算：经纬度（度）→ 投影坐标（米）
pub fn UtmProjection::forward(
  self : UtmProjection,
  lon_deg : Double,
  lat_deg : Double,
) -> (Double, Double) raise @util.GeoError {
  if lat_deg < -80.0 || lat_deg > 84.0 {
    raise @util.GeoError::Unsupported(
      "UTM valid latitude range is -80 to 84 degrees",
    )
  }
  if self.zone < 1 || self.zone > 60 {
    raise @util.GeoError::OutOfBounds("UTM zone must be 1-60, got \{self.zone}")
  }
  let e = self.ellipsoid
  let a = e.a
  let e2 = e.e_sq
  let ep2 = e.ep_sq
  let pi = @math.PI
  let phi = lat_deg * pi / 180.0
  let lam = lon_deg * pi / 180.0
  let lam0 = utm_central_meridian(self.zone) * pi / 180.0
  let sin_phi = @math.sin(phi)
  let cos_phi = @math.cos(phi)
  let tan_phi = @math.tan(phi)
  let n = a / (1.0 - e2 * sin_phi * sin_phi).sqrt()
  let t = tan_phi * tan_phi
  let c = ep2 * cos_phi * cos_phi
  let aa = (lam - lam0) * cos_phi
  let e4 = e2 * e2
  let e6 = e4 * e2
  let m = a *
    (
      (1.0 - e2 / 4.0 - 3.0 * e4 / 64.0 - 5.0 * e6 / 256.0) * phi -
      (3.0 * e2 / 8.0 + 3.0 * e4 / 32.0 + 45.0 * e6 / 1024.0) *
      @math.sin(2.0 * phi) +
      (15.0 * e4 / 256.0 + 45.0 * e6 / 1024.0) * @math.sin(4.0 * phi) -
      35.0 * e6 / 3072.0 * @math.sin(6.0 * phi)
    )
  let a3 = aa * aa * aa
  let a5 = a3 * aa * aa
  let easting = UTM_FE +
    UTM_K0 *
    n *
    (
      aa +
      (1.0 - t + c) * a3 / 6.0 +
      (5.0 - 18.0 * t + t * t + 72.0 * c - 58.0 * ep2) * a5 / 120.0
    )
  let fn_offset = if self.north { 0.0 } else { UTM_FN_SOUTH }
  let a2 = aa * aa
  let a4 = a2 * a2
  let a6 = a4 * a2
  let northing = fn_offset +
    UTM_K0 *
    (
      m +
      n *
      tan_phi *
      (
        a2 / 2.0 +
        (5.0 - t + 9.0 * c + 4.0 * c * c) * a4 / 24.0 +
        (61.0 - 58.0 * t + t * t + 600.0 * c - 330.0 * ep2) * a6 / 720.0
      )
    )
  (easting, northing)
}

///|
/// UTM 反算：投影坐标（米）→ 经纬度（度）
pub fn UtmProjection::inverse(
  self : UtmProjection,
  easting : Double,
  northing : Double,
) -> (Double, Double) raise @util.GeoError {
  if self.zone < 1 || self.zone > 60 {
    raise @util.GeoError::OutOfBounds("UTM zone must be 1-60, got \{self.zone}")
  }
  let e = self.ellipsoid
  let a = e.a
  let e2 = e.e_sq
  let ep2 = e.ep_sq
  let pi = @math.PI
  let fn_offset = if self.north { 0.0 } else { UTM_FN_SOUTH }
  let e4 = e2 * e2
  let e6 = e4 * e2
  let m = (northing - fn_offset) / UTM_K0
  let mu = m / (a * (1.0 - e2 / 4.0 - 3.0 * e4 / 64.0 - 5.0 * e6 / 256.0))
  let e1 = (1.0 - (1.0 - e2).sqrt()) / (1.0 + (1.0 - e2).sqrt())
  let e1_2 = e1 * e1
  let e1_3 = e1_2 * e1
  let e1_4 = e1_3 * e1
  let phi1 = mu +
    (3.0 * e1 / 2.0 - 27.0 * e1_3 / 32.0) * @math.sin(2.0 * mu) +
    (21.0 * e1_2 / 16.0 - 55.0 * e1_4 / 32.0) * @math.sin(4.0 * mu) +
    151.0 * e1_3 / 96.0 * @math.sin(6.0 * mu) +
    1097.0 * e1_4 / 512.0 * @math.sin(8.0 * mu)
  let sin_phi1 = @math.sin(phi1)
  let cos_phi1 = @math.cos(phi1)
  let tan_phi1 = @math.tan(phi1)
  let t1 = tan_phi1 * tan_phi1
  let c1 = ep2 * cos_phi1 * cos_phi1
  let n1 = a / (1.0 - e2 * sin_phi1 * sin_phi1).sqrt()
  let r1 = a * (1.0 - e2) / @math.pow(1.0 - e2 * sin_phi1 * sin_phi1, 1.5)
  let d = (easting - UTM_FE) / (n1 * UTM_K0)
  let d2 = d * d
  let d3 = d2 * d
  let d4 = d2 * d2
  let d5 = d4 * d
  let d6 = d4 * d2
  let phi = phi1 -
    n1 *
    tan_phi1 /
    r1 *
    (
      d2 / 2.0 -
      (5.0 + 3.0 * t1 + 10.0 * c1 - 4.0 * c1 * c1 - 9.0 * ep2) * d4 / 24.0 +
      (
        61.0 +
        90.0 * t1 +
        298.0 * c1 +
        45.0 * t1 * t1 -
        252.0 * ep2 -
        3.0 * c1 * c1
      ) *
      d6 /
      720.0
    )
  let lam0 = utm_central_meridian(self.zone) * pi / 180.0
  let lam = lam0 +
    (
      d -
      (1.0 + 2.0 * t1 + c1) * d3 / 6.0 +
      (5.0 - 2.0 * c1 + 28.0 * t1 - 3.0 * c1 * c1 + 8.0 * ep2 + 24.0 * t1 * t1) *
      d5 /
      120.0
    ) /
    cos_phi1
  let lon_deg = lam * 180.0 / pi
  let lat_deg = phi * 180.0 / pi
  (lon_deg, lat_deg)
}

///|
/// Web Mercator 投影（EPSG:3857，球面墨卡托）
pub struct WebMercator {
  dummy : Unit
}

///|
pub fn WebMercator::new() -> WebMercator {
  { dummy: (), }
}

///|
const WEB_MERCATOR_R : Double = 6378137.0

///|
/// Web Mercator 正算：经纬度（度）→ 投影坐标（米）
pub fn WebMercator::forward(
  self : WebMercator,
  lon_deg : Double,
  lat_deg : Double,
) -> (Double, Double) raise @util.GeoError {
  ignore(self)
  if lat_deg < -85.05112878 || lat_deg > 85.05112878 {
    raise @util.GeoError::Unsupported(
      "Web Mercator valid latitude range is -85.0511 to 85.0511 degrees",
    )
  }
  let pi = @math.PI
  let lon_rad = lon_deg * pi / 180.0
  let lat_rad = lat_deg * pi / 180.0
  let x = WEB_MERCATOR_R * lon_rad
  let y = WEB_MERCATOR_R * @math.ln(@math.tan(pi / 4.0 + lat_rad / 2.0))
  (x, y)
}

///|
/// Web Mercator 反算：投影坐标（米）→ 经纬度（度）
pub fn WebMercator::inverse(
  self : WebMercator,
  x : Double,
  y : Double,
) -> (Double, Double) raise @util.GeoError {
  ignore(self)
  let pi = @math.PI
  let lon_rad = x / WEB_MERCATOR_R
  let lat_rad = 2.0 * @math.atan(@math.exp(y / WEB_MERCATOR_R)) - pi / 2.0
  let lon_deg = lon_rad * 180.0 / pi
  let lat_deg = lat_rad * 180.0 / pi
  (lon_deg, lat_deg)
}

///|
/// 坐标变换：在两个 CRS 之间转换坐标
/// 输入坐标的语义取决于 from_crs.kind：
/// - Geographic: (lon_deg, lat_deg)
/// - Projected: (easting, northing)
/// 输出坐标的语义取决于 to_crs.kind
pub fn transform_coord(
  coord : (Double, Double),
  from_crs : Crs,
  to_crs : Crs,
) -> (Double, Double) raise @util.GeoError {
  let lon_lat = to_geographic(coord, from_crs)
  from_geographic(lon_lat, to_crs)
}

///|
/// 将坐标转换为地理坐标（经纬度，度）
fn to_geographic(
  coord : (Double, Double),
  crs : Crs,
) -> (Double, Double) raise @util.GeoError {
  match crs.kind {
    CrsKind::Geographic => coord
    CrsKind::Projected =>
      match crs.projection {
        Some(ProjectionMethod::Utm(zone, north)) => {
          let proj = UtmProjection::with_ellipsoid(
            datum_ellipsoid(crs.datum),
            zone,
            north,
          )
          proj.inverse(coord.0, coord.1)
        }
        Some(ProjectionMethod::WebMercator) => {
          let proj = WebMercator::new()
          proj.inverse(coord.0, coord.1)
        }
        None =>
          raise @util.GeoError::FormatError(
            "Projected CRS has no projection method",
          )
      }
  }
}

///|
/// 将地理坐标（经纬度，度）转换为目标 CRS 坐标
fn from_geographic(
  lon_lat : (Double, Double),
  crs : Crs,
) -> (Double, Double) raise @util.GeoError {
  match crs.kind {
    CrsKind::Geographic => lon_lat
    CrsKind::Projected =>
      match crs.projection {
        Some(ProjectionMethod::Utm(zone, north)) => {
          let proj = UtmProjection::with_ellipsoid(
            datum_ellipsoid(crs.datum),
            zone,
            north,
          )
          proj.forward(lon_lat.0, lon_lat.1)
        }
        Some(ProjectionMethod::WebMercator) => {
          let proj = WebMercator::new()
          proj.forward(lon_lat.0, lon_lat.1)
        }
        None =>
          raise @util.GeoError::FormatError(
            "Projected CRS has no projection method",
          )
      }
  }
}
