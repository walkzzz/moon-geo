// 数据集模型
// P4 层 platform/data
// Dataset = Layer 集合 + 元数据

///|
/// 数据集
pub struct Dataset {
  name : String
  layers : Array[Layer]
  metadata : Array[(String, String)]
}

///|
/// 构造空数据集
pub fn Dataset::new(name : String) -> Dataset {
  { name, layers: [], metadata: [], }
}

///|
/// 获取数据集名称
pub fn Dataset::name(self : Dataset) -> String {
  self.name
}

///|
/// 添加图层（返回新数据集）
pub fn Dataset::add_layer(self : Dataset, layer : Layer) -> Dataset {
  let new_layers = Array::new()
  for l in self.layers {
    new_layers.push(l)
  }
  new_layers.push(layer)
  { name: self.name, layers: new_layers, metadata: self.metadata, }
}

///|
/// 图层数量
pub fn Dataset::layer_count(self : Dataset) -> Int32 {
  self.layers.length()
}

///|
/// 按名称查找图层
pub fn Dataset::get_layer(self : Dataset, name : String) -> Layer? {
  for l in self.layers {
    if l.name() == name {
      return Some(l)
    }
  }
  None
}

///|
/// 按索引获取图层
pub fn Dataset::get_layer_by_index(self : Dataset, index : Int32) -> Layer? {
  if index < 0 || index >= self.layers.length() {
    None
  } else {
    Some(self.layers[index])
  }
}

///|
/// 设置元数据（返回新数据集，同名键被替换）
pub fn Dataset::set_meta(
  self : Dataset,
  key : String,
  value : String,
) -> Dataset {
  let new_meta : Array[(String, String)] = []
  for (k, v) in self.metadata {
    if k != key {
      new_meta.push((k, v))
    }
  }
  new_meta.push((key, value))
  { name: self.name, layers: self.layers, metadata: new_meta, }
}

///|
/// 获取元数据
pub fn Dataset::get_meta(self : Dataset, key : String) -> String? {
  for (k, v) in self.metadata {
    if k == key {
      return Some(v)
    }
  }
  None
}

///|
/// 获取所有元数据
pub fn Dataset::metadata(self : Dataset) -> Array[(String, String)] {
  self.metadata
}

///|
/// 总要素数（所有图层要素之和）
pub fn Dataset::total_features(self : Dataset) -> Int32 {
  let mut total = 0
  for l in self.layers {
    total += l.feature_count()
  }
  total
}
