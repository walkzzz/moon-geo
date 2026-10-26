// 索引网格
// platform/mesh，P2 层
// IndexedMesh = vertices + indices + normals

///|
/// 3D 顶点（Double 三元组）
pub struct Vertex3 {
  x : Double
  y : Double
  z : Double
}

///|
pub fn Vertex3::new(x : Double, y : Double, z : Double) -> Vertex3 {
  { x, y, z, }
}

///|
/// 三角面片索引
pub struct Triangle {
  v0 : Int32
  v1 : Int32
  v2 : Int32
}

///|
pub fn Triangle::new(v0 : Int32, v1 : Int32, v2 : Int32) -> Triangle {
  { v0, v1, v2, }
}

///|
/// 法向量
pub struct Normal3 {
  x : Double
  y : Double
  z : Double
}

///|
pub fn Normal3::new(x : Double, y : Double, z : Double) -> Normal3 {
  { x, y, z, }
}

///|
/// 索引网格
pub struct IndexedMesh {
  vertices : Array[Vertex3]
  triangles : Array[Triangle]
  normals : Array[Normal3]
}

///|
/// 构造空网格
pub fn IndexedMesh::new() -> IndexedMesh {
  { vertices: [], triangles: [], normals: [], }
}

///|
/// 添加顶点（返回新网格 + 顶点索引）
pub fn IndexedMesh::add_vertex(
  self : IndexedMesh,
  x : Double,
  y : Double,
  z : Double,
) -> (IndexedMesh, Int32) {
  let new_verts = copy_vertices(self.vertices)
  let idx = new_verts.length()
  new_verts.push(Vertex3::new(x, y, z))
  (
    { vertices: new_verts, triangles: self.triangles, normals: self.normals, },
    idx,
  )
}

///|
/// 添加三角面片（返回新网格）
pub fn IndexedMesh::add_triangle(
  self : IndexedMesh,
  v0 : Int32,
  v1 : Int32,
  v2 : Int32,
) -> IndexedMesh {
  let new_tris = copy_triangles(self.triangles)
  new_tris.push(Triangle::new(v0, v1, v2))
  { vertices: self.vertices, triangles: new_tris, normals: self.normals, }
}

///|
/// 添加法向量（返回新网格）
pub fn IndexedMesh::add_normal(
  self : IndexedMesh,
  x : Double,
  y : Double,
  z : Double,
) -> IndexedMesh {
  let new_norms = copy_normals(self.normals)
  new_norms.push(Normal3::new(x, y, z))
  { vertices: self.vertices, triangles: self.triangles, normals: new_norms, }
}

///|
/// 顶点数
pub fn IndexedMesh::vertex_count(self : IndexedMesh) -> Int32 {
  self.vertices.length()
}

///|
/// 三角面片数
pub fn IndexedMesh::triangle_count(self : IndexedMesh) -> Int32 {
  self.triangles.length()
}

///|
/// 法向量数
pub fn IndexedMesh::normal_count(self : IndexedMesh) -> Int32 {
  self.normals.length()
}

///|
/// 获取顶点
pub fn IndexedMesh::get_vertex(self : IndexedMesh, i : Int32) -> Vertex3? {
  if i < 0 || i >= self.vertices.length() {
    None
  } else {
    Some(self.vertices[i])
  }
}

///|
/// 获取三角面片
pub fn IndexedMesh::get_triangle(self : IndexedMesh, i : Int32) -> Triangle? {
  if i < 0 || i >= self.triangles.length() {
    None
  } else {
    Some(self.triangles[i])
  }
}

///|
/// 获取法向量
pub fn IndexedMesh::get_normal(self : IndexedMesh, i : Int32) -> Normal3? {
  if i < 0 || i >= self.normals.length() {
    None
  } else {
    Some(self.normals[i])
  }
}

///|
/// 计算面片法向量（叉积法）
pub fn compute_normal(v0 : Vertex3, v1 : Vertex3, v2 : Vertex3) -> Normal3 {
  let ex = v1.x - v0.x
  let ey = v1.y - v0.y
  let ez = v1.z - v0.z
  let fx = v2.x - v0.x
  let fy = v2.y - v0.y
  let fz = v2.z - v0.z
  let nx = ey * fz - ez * fy
  let ny = ez * fx - ex * fz
  let nz = ex * fy - ey * fx
  let len = (nx * nx + ny * ny + nz * nz).sqrt()
  if len < 1.0e-12 {
    Normal3::new(0.0, 0.0, 1.0)
  } else {
    Normal3::new(nx / len, ny / len, nz / len)
  }
}

///|
/// 重算法向量（为每个面片计算法向量）
pub fn IndexedMesh::recompute_normals(self : IndexedMesh) -> IndexedMesh {
  let new_norms : Array[Normal3] = []
  for tri in self.triangles {
    match
      (
        self.get_vertex(tri.v0),
        self.get_vertex(tri.v1),
        self.get_vertex(tri.v2),
      ) {
      (Some(v0), Some(v1), Some(v2)) => {
        let n = compute_normal(v0, v1, v2)
        new_norms.push(n)
      }
      _ => new_norms.push(Normal3::new(0.0, 0.0, 1.0))
    }
  }
  { vertices: self.vertices, triangles: self.triangles, normals: new_norms, }
}

///|
fn copy_vertices(vertices : Array[Vertex3]) -> Array[Vertex3] {
  let result : Array[Vertex3] = []
  for v in vertices {
    result.push(v)
  }
  result
}

///|
fn copy_triangles(triangles : Array[Triangle]) -> Array[Triangle] {
  let result : Array[Triangle] = []
  for t in triangles {
    result.push(t)
  }
  result
}

///|
fn copy_normals(normals : Array[Normal3]) -> Array[Normal3] {
  let result : Array[Normal3] = []
  for n in normals {
    result.push(n)
  }
  result
}
