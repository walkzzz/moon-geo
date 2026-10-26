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
/// 将 IndexedMesh 序列化为 binary STL Bytes
/// binary 格式：80 字节头 + 4 字节三角形数 + 每三角形 50 字节
pub fn mesh_to_stl_binary(mesh : @mesh.IndexedMesh, header : String) -> Bytes {
  let n = mesh.triangle_count()
  let out : Array[Byte] = []
  // 80 字节头（header 限 ASCII，非 ASCII 字符静默截断为单字节）
  let header_bytes = header.to_array()
  let header_len = if header_bytes.length() < 80 {
    header_bytes.length()
  } else {
    80
  }
  for i in 0..<header_len {
    out.push(header_bytes[i].to_int().to_byte())
  }
  for _ in header_len..<80 {
    out.push(b'\x00')
  }
  // 4 字节三角形数 (little-endian uint32)
  write_uint32_le(out, n)
  // 每个三角形 50 字节
  for i in 0..<n {
    match mesh.get_triangle(i) {
      Some(tri) => {
        let v0 = get_vtx(mesh, tri.v0)
        let v1 = get_vtx(mesh, tri.v1)
        let v2 = get_vtx(mesh, tri.v2)
        match mesh.get_normal(i) {
          Some(nrm) => {
            write_float_le(out, nrm.x())
            write_float_le(out, nrm.y())
            write_float_le(out, nrm.z())
          }
          None => {
            write_float_le(out, 0.0)
            write_float_le(out, 0.0)
            write_float_le(out, 0.0)
          }
        }
        write_float_le(out, v0.x())
        write_float_le(out, v0.y())
        write_float_le(out, v0.z())
        write_float_le(out, v1.x())
        write_float_le(out, v1.y())
        write_float_le(out, v1.z())
        write_float_le(out, v2.x())
        write_float_le(out, v2.y())
        write_float_le(out, v2.z())
        // 2 字节属性字节计数
        out.push(b'\x00')
        out.push(b'\x00')
      }
      None => ()
    }
  }
  Bytes::from_iter(out.iter())
}

///|
/// 从 binary STL Bytes 解析为 IndexedMesh
pub fn mesh_from_stl_binary(
  bytes : Bytes,
) -> @mesh.IndexedMesh raise @util.GeoError {
  let total = bytes.length()
  if total < 84 {
    raise @util.GeoError::FormatError(
      "binary STL 过短：\{total} < 84 字节",
    )
  }
  let n = read_uint32_le(bytes, 80)
  if n == 0 {
    raise @util.GeoError::FormatError("binary STL 未包含任何面片")
  }
  let expected = 84 + n * 50
  if total < expected {
    raise @util.GeoError::FormatError(
      "binary STL 字节数不足：期望 \{expected}，实际 \{total}",
    )
  }
  let mut mesh = @mesh.IndexedMesh::new()
  let mut offset = 84
  for _ in 0..<n {
    let nx = read_float_le(bytes, offset)
    let ny = read_float_le(bytes, offset + 4)
    let nz = read_float_le(bytes, offset + 8)
    let v0x = read_float_le(bytes, offset + 12)
    let v0y = read_float_le(bytes, offset + 16)
    let v0z = read_float_le(bytes, offset + 20)
    let v1x = read_float_le(bytes, offset + 24)
    let v1y = read_float_le(bytes, offset + 28)
    let v1z = read_float_le(bytes, offset + 32)
    let v2x = read_float_le(bytes, offset + 36)
    let v2y = read_float_le(bytes, offset + 40)
    let v2z = read_float_le(bytes, offset + 44)
    let (m, i0) = mesh.add_vertex(v0x, v0y, v0z)
    mesh = m
    let (m2, i1) = mesh.add_vertex(v1x, v1y, v1z)
    mesh = m2
    let (m3, i2) = mesh.add_vertex(v2x, v2y, v2z)
    mesh = m3
    mesh = mesh.add_triangle(i0, i1, i2)
    mesh = mesh.add_normal(nx, ny, nz)
    offset += 50
  }
  mesh
}

///|
/// 写入 float32 little-endian (4 字节)
fn write_float_le(arr : Array[Byte], d : Double) -> Unit {
  let f = Float::from_double(d)
  let bts = f.to_le_bytes()
  for i in 0..<4 {
    match bts.get(i) {
      Some(b) => arr.push(b)
      None => arr.push(b'\x00')
    }
  }
}

///|
/// 读取 float32 little-endian，返回 Double
fn read_float_le(bytes : Bytes, offset : Int32) -> Double {
  let b0 = byte_at(bytes, offset)
  let b1 = byte_at(bytes, offset + 1)
  let b2 = byte_at(bytes, offset + 2)
  let b3 = byte_at(bytes, offset + 3)
  let bits = b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
  Float::reinterpret_from_int(bits).to_double()
}

///|
/// 写入 uint32 little-endian (4 字节)
fn write_uint32_le(arr : Array[Byte], val : Int32) -> Unit {
  arr.push((val & 0xFF).to_byte())
  arr.push(((val >> 8) & 0xFF).to_byte())
  arr.push(((val >> 16) & 0xFF).to_byte())
  arr.push(((val >> 24) & 0xFF).to_byte())
}

///|
/// 读取 uint32 little-endian
fn read_uint32_le(bytes : Bytes, offset : Int32) -> Int32 {
  let b0 = byte_at(bytes, offset)
  let b1 = byte_at(bytes, offset + 1)
  let b2 = byte_at(bytes, offset + 2)
  let b3 = byte_at(bytes, offset + 3)
  b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
}

///|
/// 安全读取字节，越界返回 0
fn byte_at(bytes : Bytes, idx : Int32) -> Int32 {
  match bytes.get(idx) {
    Some(b) => b.to_int()
    None => 0
  }
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
fn parse_vertex_line(
  line : String,
) -> (Double, Double, Double) raise @util.GeoError {
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
