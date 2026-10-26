// EPSG 查询（常用子集）
// P1 层 platform/crs，依赖 util（GeoError）
// 仅收录最常用 CRS，全量 EPSG 库远期实现

///|
/// 根据 EPSG 编码查找 CRS
pub fn epsg_lookup(code : Int32) -> Crs? {
  match code {
    4326 => Some(wgs84_geographic())
    4490 => Some(cgcs2000_geographic())
    3857 => Some(web_mercator())
    _ =>
      if code >= 32601 && code <= 32660 {
        Some(wgs84_utm(code - 32600, true))
      } else if code >= 32701 && code <= 32760 {
        Some(wgs84_utm(code - 32700, false))
      } else {
        None
      }
  }
}

///|
/// 获取 CRS 的 EPSG 编码（如有）
pub fn epsg_code(crs : Crs) -> Int32? {
  crs.epsg
}

///|
/// 判断两个 CRS 是否等价（相同 EPSG 编码即等价）
pub fn crs_equivalent(a : Crs, b : Crs) -> Bool {
  match (a.epsg, b.epsg) {
    (Some(ea), Some(eb)) => ea == eb
    _ => false
  }
}
