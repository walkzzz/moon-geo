// STL 格式读写
// platform/io，将 IndexedMesh 转为 STL 字符串 / 从 STL 解析为 IndexedMesh
// 支持 ASCII STL 格式
// 顶点/法向用 @alg.Pt3，通过 x()/y()/z() 访问坐标

///|
/// 将 IndexedMesh 序列化为 ASCII STL 字符串
pub fn mesh_to_stl_ascii(mesh : @mesh.IndexedMesh, name : String) -> String {
  let sb = StringBuilder::new()
  sb.write_string("solid ")
  sb.write_string(name)
  sb.write_char('\n')
  let n = mesh.triangle_count()
  for i in 0..<n {
    match mesh.get_triangle(i) {
      Some(tri) => {
        let v0 = get_vtx(mesh, tri.v0)
        let v1 = get_vtx(mesh, tri.v1)
        let v2 = get_vtx(mesh, tri.v2)
        match mesh.get_normal(i) {
          Some(nrm) =>
            sb.write_string("  facet normal \{nrm.x()} \{nrm.y()} \{nrm.z()}\n")
          None => sb.write_string("  facet normal 0.0 0.0 0.0\n")
        }
        sb.write_string("    outer loop\n")
        sb.write_string("      vertex \{v0.x()} \{v0.y()} \{v0.z()}\n")
        sb.write_string("      vertex \{v1.x()} \{v1.y()} \{v1.z()}\n")
        sb.write_string("      vertex \{v2.x()} \{v2.y()} \{v2.z()}\n")
        sb.write_string("    endloop\n")
        sb.write_string("  endfacet\n")
      }
      None => ()
    }
  }
  sb.write_string("endsolid ")
  sb.write_string(name)
  sb.write_char('\n')
  sb.to_string()
}

///|
/// 从 ASCII STL 字符串解析为 IndexedMesh
pub fn mesh_from_stl_ascii(
  stl : String,
) -> @mesh.IndexedMesh raise @util.GeoError {
  let lines = split_lines(stl)
  let mut mesh = @mesh.IndexedMesh::new()
  let mut current_verts : Array[(Double, Double, Double)] = []
  let mut in_outer_loop = false
  for line in lines {
    let trimmed = trim(line)
    let lower = to_lower(trimmed)
    if lower == "outer loop" {
      in_outer_loop = true
      current_verts = []
    } else if lower == "endloop" {
      in_outer_loop = false
      if current_verts.length() >= 3 {
        let (m, i0) = mesh.add_vertex(
          current_verts[0].0,
          current_verts[0].1,
          current_verts[0].2,
        )
        mesh = m
        let (m2, i1) = mesh.add_vertex(
          current_verts[1].0,
          current_verts[1].1,
          current_verts[1].2,
        )
        mesh = m2
        let (m3, i2) = mesh.add_vertex(
          current_verts[2].0,
          current_verts[2].1,
          current_verts[2].2,
        )
        mesh = m3
        mesh = mesh.add_triangle(i0, i1, i2)
      }
    } else if starts_with(lower, "vertex") {
      if in_outer_loop {
        let coords = parse_vertex_line(trimmed)
        current_verts.push(coords)
      }
    } else if starts_with(lower, "facet normal") {
      let parts = split_whitespace(trimmed)
      if parts.length() >= 5 {
        let nx = local_parse_double(parts[2])
        let ny = local_parse_double(parts[3])
        let nz = local_parse_double(parts[4])
        mesh = mesh.add_normal(nx, ny, nz)
      }
    }
  }
  if mesh.triangle_count() == 0 {
    raise @util.GeoError::FormatError("STL 未包含任何面片")
  }
  mesh
}

///|
/// 获取顶点坐标
fn get_vtx(mesh : @mesh.IndexedMesh, i : Int32) -> @alg.Pt3 {
  match mesh.get_vertex(i) {
    Some(v) => v
    None => @alg.Pt3::new(0.0, 0.0, 0.0)
  }
}

///|
/// 解析 vertex 行
fn parse_vertex_line(line : String) -> (Double, Double, Double) {
  let parts = split_whitespace(line)
  if parts.length() >= 4 {
    let x = local_parse_double(parts[1])
    let y = local_parse_double(parts[2])
    let z = local_parse_double(parts[3])
    (x, y, z)
  } else {
    (0.0, 0.0, 0.0)
  }
}

///|
/// 按行分割字符串
fn split_lines(s : String) -> Array[String] {
  let result : Array[String] = []
  let mut current = ""
  let n = s.length()
  for i in 0..<n {
    let ch = s[i]
    if ch == '\n' {
      result.push(current)
      current = ""
    } else if ch != '\r' {
      current += s.substring(start=i, end=i + 1)
    }
  }
  if current.length() > 0 {
    result.push(current)
  }
  result
}

///|
/// 去除首尾空白
fn trim(s : String) -> String {
  let n = s.length()
  let mut start = 0
  let mut end = n
  while start < end {
    let ch = s[start]
    if ch == ' ' || ch == '\t' {
      start += 1
    } else {
      break
    }
  }
  while end > start {
    let ch = s[end - 1]
    if ch == ' ' || ch == '\t' {
      end -= 1
    } else {
      break
    }
  }
  s.substring(start~, end~)
}

///|
/// 转小写
fn to_lower(s : String) -> String {
  let lower = "abcdefghijklmnopqrstuvwxyz"
  let mut result = ""
  let n = s.length()
  for i in 0..<n {
    let ch = s[i]
    if ch >= 'A' && ch <= 'Z' {
      let idx = ch.to_int() - 'A'.to_int()
      result += lower.substring(start=idx, end=idx + 1)
    } else {
      result += s.substring(start=i, end=i + 1)
    }
  }
  result
}

///|
/// 前缀匹配
fn starts_with(s : String, prefix : String) -> Bool {
  if s.length() < prefix.length() {
    return false
  }
  let n = prefix.length()
  for i in 0..<n {
    if s[i] != prefix[i] {
      return false
    }
  }
  true
}

///|
/// 按空白分割
fn split_whitespace(s : String) -> Array[String] {
  let result : Array[String] = []
  let mut current = ""
  let n = s.length()
  for i in 0..<n {
    let ch = s[i]
    if ch == ' ' || ch == '\t' {
      if current.length() > 0 {
        result.push(current)
        current = ""
      }
    } else {
      current += s.substring(start=i, end=i + 1)
    }
  }
  if current.length() > 0 {
    result.push(current)
  }
  result
}
