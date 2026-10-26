// 要素模型：Geometry + Feature
// P4 层 platform/data，依赖 util（GeoError）、crs（Crs + transform_coord）、alg（Pt2/Pt3）
// Geometry 对应 GeoJSON 几何类型，坐标用 @alg.Pt2/Pt3 而非裸元组
// Feature = Geometry + Attributes + CRS

///|
/// 几何类型（GeoJSON 风格）
pub(all) enum Geometry {
  Point(@alg.Pt2)
  PointZ(@alg.Pt3)
  LineString(Array[@alg.Pt2])
  Polygon(Array[@alg.Pt2], Array[Array[@alg.Pt2]])
  MultiPoint(Array[@alg.Pt2])
  MultiLineString(Array[Array[@alg.Pt2]])
  MultiPolygon(Array[(Array[@alg.Pt2], Array[Array[@alg.Pt2]])])
  GeometryCollection(Array[Geometry])
}

///|
/// 几何类型名称
pub fn Geometry::type_name(g : Geometry) -> String {
  match g {
    Point(_) => "Point"
    PointZ(_) => "PointZ"
    LineString(_) => "LineString"
    Polygon(_, _) => "Polygon"
    MultiPoint(_) => "MultiPoint"
    MultiLineString(_) => "MultiLineString"
    MultiPolygon(_) => "MultiPolygon"
    GeometryCollection(_) => "GeometryCollection"
  }
}

///|
/// 获取几何的坐标数量
pub fn Geometry::coord_count(g : Geometry) -> Int32 {
  match g {
    Point(_) => 1
    PointZ(_) => 1
    LineString(coords) => coords.length()
    Polygon(exterior, interiors) => {
      let count = exterior.length()
      let mut total = count
      for ring in interiors {
        total += ring.length()
      }
      total
    }
    MultiPoint(coords) => coords.length()
    MultiLineString(lines) => {
      let mut total = 0
      for line in lines {
        total += line.length()
      }
      total
    }
    MultiPolygon(polygons) => {
      let mut total = 0
      for (exterior, interiors) in polygons {
        total += exterior.length()
        for ring in interiors {
          total += ring.length()
        }
      }
      total
    }
    GeometryCollection(geoms) => {
      let mut total = 0
      for g in geoms {
        total += g.coord_count()
      }
      total
    }
  }
}

///|
/// 要素：Geometry + Attributes + CRS
pub struct Feature {
  geometry : Geometry?
  attributes : Array[(String, FieldValue)]
  crs : @crs.Crs
}

///|
/// 构造空要素（无几何，无属性）
pub fn Feature::new(crs : @crs.Crs) -> Feature {
  { geometry: None, attributes: [], crs, }
}

///|
/// 设置几何（返回新要素）
pub fn Feature::with_geometry(self : Feature, geom : Geometry) -> Feature {
  { geometry: Some(geom), attributes: self.attributes, crs: self.crs, }
}

///|
/// 获取几何
pub fn Feature::geometry(self : Feature) -> Geometry? {
  self.geometry
}

///|
/// 获取 CRS
pub fn Feature::crs(self : Feature) -> @crs.Crs {
  self.crs
}

///|
/// 设置属性（返回新要素，同名属性被替换）
pub fn Feature::set(
  self : Feature,
  name : String,
  value : FieldValue,
) -> Feature {
  let new_attrs : Array[(String, FieldValue)] = []
  for (k, v) in self.attributes {
    if k != name {
      new_attrs.push((k, v))
    }
  }
  new_attrs.push((name, value))
  { geometry: self.geometry, attributes: new_attrs, crs: self.crs, }
}

///|
/// 获取属性值
pub fn Feature::get(self : Feature, name : String) -> FieldValue? {
  for (k, v) in self.attributes {
    if k == name {
      return Some(v)
    }
  }
  None
}

///|
/// 获取所有属性名
pub fn Feature::field_names(self : Feature) -> Array[String] {
  let names : Array[String] = []
  for (k, _) in self.attributes {
    names.push(k)
  }
  names
}

///|
/// 属性数量
pub fn Feature::attr_count(self : Feature) -> Int32 {
  self.attributes.length()
}

///|
/// 判断是否有几何
pub fn Feature::has_geometry(self : Feature) -> Bool {
  match self.geometry {
    Some(_) => true
    None => false
  }
}

///|
/// CRS 变换：将要素几何变换到目标 CRS（返回新要素）
pub fn Feature::transform_crs(
  self : Feature,
  target : @crs.Crs,
) -> Feature raise @util.GeoError {
  if @crs.crs_equivalent(self.crs, target) {
    return self
  }
  match self.geometry {
    None => self
    Some(geom) => {
      let new_geom = transform_geometry(geom, self.crs, target)
      { geometry: Some(new_geom), attributes: self.attributes, crs: target, }
    }
  }
}

///|
/// 变换几何的所有坐标
fn transform_geometry(
  geom : Geometry,
  from : @crs.Crs,
  to : @crs.Crs,
) -> Geometry raise @util.GeoError {
  match geom {
    Point(p) => {
      let (nx, ny) = @crs.transform_coord((p.x(), p.y()), from, to)
      Point(@alg.Pt2::new(nx, ny))
    }
    PointZ(p) => {
      let (nx, ny) = @crs.transform_coord((p.x(), p.y()), from, to)
      PointZ(@alg.Pt3::new(nx, ny, p.z()))
    }
    LineString(coords) => {
      let new_coords : Array[@alg.Pt2] = []
      for p in coords {
        let (nx, ny) = @crs.transform_coord((p.x(), p.y()), from, to)
        new_coords.push(@alg.Pt2::new(nx, ny))
      }
      LineString(new_coords)
    }
    Polygon(exterior, interiors) => {
      let new_ext = transform_ring(exterior, from, to)
      let new_ints : Array[Array[@alg.Pt2]] = []
      for ring in interiors {
        new_ints.push(transform_ring(ring, from, to))
      }
      Polygon(new_ext, new_ints)
    }
    MultiPoint(coords) => {
      let new_coords : Array[@alg.Pt2] = []
      for p in coords {
        let (nx, ny) = @crs.transform_coord((p.x(), p.y()), from, to)
        new_coords.push(@alg.Pt2::new(nx, ny))
      }
      MultiPoint(new_coords)
    }
    MultiLineString(lines) => {
      let new_lines : Array[Array[@alg.Pt2]] = []
      for line in lines {
        new_lines.push(transform_ring(line, from, to))
      }
      MultiLineString(new_lines)
    }
    MultiPolygon(polygons) => {
      let new_polys : Array[(Array[@alg.Pt2], Array[Array[@alg.Pt2]])] = []
      for (ext, ints) in polygons {
        let new_ext = transform_ring(ext, from, to)
        let new_ints : Array[Array[@alg.Pt2]] = []
        for ring in ints {
          new_ints.push(transform_ring(ring, from, to))
        }
        new_polys.push((new_ext, new_ints))
      }
      MultiPolygon(new_polys)
    }
    GeometryCollection(geoms) => {
      let new_geoms : Array[Geometry] = []
      for g in geoms {
        new_geoms.push(transform_geometry(g, from, to))
      }
      GeometryCollection(new_geoms)
    }
  }
}

///|
/// 变换坐标环
fn transform_ring(
  ring : Array[@alg.Pt2],
  from : @crs.Crs,
  to : @crs.Crs,
) -> Array[@alg.Pt2] raise @util.GeoError {
  let result : Array[@alg.Pt2] = []
  for p in ring {
    let (nx, ny) = @crs.transform_coord((p.x(), p.y()), from, to)
    result.push(@alg.Pt2::new(nx, ny))
  }
  result
}
