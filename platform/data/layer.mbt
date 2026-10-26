// 图层模型
// P4 层 platform/data
// Layer = Feature 集合 + 字段模式 + CRS

///|
/// 图层
pub struct Layer {
  name : String
  features : Array[Feature]
  schema : Array[(String, FieldType)]
  crs : @crs.Crs
}

///|
/// 构造空图层
pub fn Layer::new(name : String, crs : @crs.Crs) -> Layer {
  { name, features: [], schema: [], crs, }
}

///|
/// 获取图层名称
pub fn Layer::name(self : Layer) -> String {
  self.name
}

///|
/// 获取图层 CRS
pub fn Layer::crs(self : Layer) -> @crs.Crs {
  self.crs
}

///|
/// 添加要素（返回新图层）
pub fn Layer::add_feature(self : Layer, feature : Feature) -> Layer {
  let new_features = Array::new()
  for f in self.features {
    new_features.push(f)
  }
  new_features.push(feature)
  {
    name: self.name,
    features: new_features,
    schema: self.schema,
    crs: self.crs,
  }
}

///|
/// 要素数量
pub fn Layer::feature_count(self : Layer) -> Int32 {
  self.features.length()
}

///|
/// 获取要素（按索引）
pub fn Layer::get_feature(self : Layer, index : Int32) -> Feature? {
  if index < 0 || index >= self.features.length() {
    None
  } else {
    Some(self.features[index])
  }
}

///|
/// 添加字段到模式（返回新图层）
pub fn Layer::add_field(self : Layer, name : String, ft : FieldType) -> Layer {
  let new_schema = Array::new()
  for (k, v) in self.schema {
    if k != name {
      new_schema.push((k, v))
    }
  }
  new_schema.push((name, ft))
  {
    name: self.name,
    features: self.features,
    schema: new_schema,
    crs: self.crs,
  }
}

///|
/// 获取字段模式
pub fn Layer::schema(self : Layer) -> Array[(String, FieldType)] {
  self.schema
}

///|
/// 字段数量
pub fn Layer::field_count(self : Layer) -> Int32 {
  self.schema.length()
}

///|
/// CRS 变换：将图层所有要素变换到目标 CRS（返回新图层）
pub fn Layer::transform_crs(
  self : Layer,
  target : @crs.Crs,
) -> Layer raise @util.GeoError {
  if @crs.crs_equivalent(self.crs, target) {
    return self
  }
  let new_features = Array::new()
  for f in self.features {
    new_features.push(f.transform_crs(target))
  }
  { name: self.name, features: new_features, schema: self.schema, crs: target, }
}

///|
/// 按属性过滤要素
pub fn Layer::filter(
  self : Layer,
  field_name : String,
  value : FieldValue,
) -> Layer {
  let new_features = Array::new()
  for f in self.features {
    match f.get(field_name) {
      Some(v) => if field_value_equal(v, value) { new_features.push(f) }
      None => ()
    }
  }
  {
    name: self.name,
    features: new_features,
    schema: self.schema,
    crs: self.crs,
  }
}

///|
/// 字段值相等判断
fn field_value_equal(a : FieldValue, b : FieldValue) -> Bool {
  match (a, b) {
    (IntVal(x), IntVal(y)) => x == y
    (DoubleVal(x), DoubleVal(y)) => @util.dbl_approx_eq(x, y, 1.0e-10)
    (StringVal(x), StringVal(y)) => x == y
    (BoolVal(x), BoolVal(y)) => x == y
    (NullVal, NullVal) => true
    _ => false
  }
}
