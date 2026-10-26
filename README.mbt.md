# moon-geo · MoonBit 生态几何计算库

> MoonBit 语言生态的几何计算库。提供 2D/3D 欧氏几何、求交/变换、Delaunay 三角剖分、布尔运算、BVH 空间索引、半边结构、CRS 投影（UTM/Web Mercator/CGCS2000）与格式 I/O（GeoJSON/STL）。编译到 WASM，适合 Web 端轻量几何计算。

**近期目标**（2-3 年 → 1.0）：2D/3D 欧氏几何 + 求交/变换 + Delaunay/凸包/BVH + GeoJSON/STL I/O + UTM/Web Mercator + 半边结构，全部有测试和文档。

## 目标用户

| 用户 | 当前用什么 | 为什么用 moon-geo |
|------|-----------|-------------------|
| **Web WASM 开发者** | Turf.js / geos-wasm / 手写几何 | MoonBit 编译到 WASM，体积小无 GC 暂停，适合在浏览器做点包含/缓冲区/三角剖分等计算密集任务 |
| **MoonBit 应用开发者** | 无（生态尚缺几何库） | moon-geo 是 MoonBit 生态的几何基础设施，直接 `import` 使用，无需 FFI 桥接 |

## 架构：后端九层 + 前端平台

### 后端库

```
util(-1) → atop(0) → space(1) → alg(2) → bv(3) → brep(4) → algo(5) → parallel(6) → domain(7) → eco(8)
```

| 层 | 包名 | 职责 | 备注 |
|----|------|------|------|
| -1 | `util` | 数域/数值/矩阵/精度体系 | |
| 0 | `atop` | 拓扑空间/流形/范畴化抽象 | |
| 1 | `space` | 欧氏/复/射影/非欧/时空/栅格 | |
| 2 | `alg` | 代数簇/变换/不变量/求交 | |
| 3 | `bv` | 包围体/空间索引树 | |
| 4 | `brep` | 流形/非流形/胞腔复形 | |
| 5 | `algo` | 基础几何/GIS/高阶拓扑 | |
| 6 | `parallel` | CPU多线程/GPU/分布式 | 远期方向，不承诺时间线 |
| 7 | `domain` | CAD/GIS/仿真/视觉/机器人 | 远期方向，不承诺时间线 |
| 8 | `eco` | 语言绑定/格式兼容/引擎对接 | 远期方向，不承诺时间线 |

### 前端平台（`platform/`）

| 层 | 包名 | 职责 | 备注 |
|----|------|------|------|
| P1 | `platform/crs` | CRS/EPSG/投影变换（WGS84/UTM/CGCS2000） | |
| P2 | `platform/mesh` | IndexedMesh + 属性通道 + 网格简化 | |
| P3 | `platform/pcloud` | PointCloud + 降采样/法向/地面滤波/RANSAC/ICP | RANSAC/ICP 远期 |
| P4 | `platform/data` | Feature/Layer/Dataset + RasterDataset + Streaming/LOD | |
| P5 | `platform/io` | 格式 I/O（GeoJSON/STL 已实现；LAS/GeoTIFF/shp/DXF/OBJ/GLTF/OSGB/3DTiles 远期） | |

**时序铁律**：I/O 不能先于数据模型和 CRS——先建 `platform/data` + `platform/crs`，再建 `platform/io`。

## 当前进度

**纪元一·奠基纪元 → 阶段二·能力完善 → `0.1.2.z`**

| 版本 | 任务 | 状态 |
|------|------|------|
| `0.1.1.0` | util num/cpx + CRAP/变异工具 | ✅ |
| `0.1.1.1` | util vec/mat/quat | ✅ |
| `0.1.1.2` | util poly + atop 拓扑空间 Trait | ✅ |
| `0.1.1.3` | space Space Trait + Euclid2 | ✅ |
| `0.1.1.4` | space Euclid3 + SpaceMap | ✅ |
| `0.1.1.5` | alg Geo Trait + Pt2/Pt3 + Line2 + 前瞻性审查完善 | ✅ |
| `0.1.1.6` | alg Circle + Conic2 + discriminant | ✅ |
| `0.1.1.7` | alg Plane3 + Sphere + Quad3 + 幂定理 | ✅ |
| `0.1.1.8` | alg intersect + xform Transform | ✅ |
| `0.1.1.9` | bv Bv Trait + Aabb2/Aabb3 + SphereBv + BVH | ✅ |
| `0.1.1.10` | brep Topo Trait + HEMesh + HalfEdge | ✅ |
| `0.1.1.11` | brep Shell/Solid + check + repair + BRep API | ✅ |
| `0.1.1.12` | 核心 Trait 冻结 + ADR-005 + 稳定性测试 | ✅ |
| `0.1.2.0` | space Complex2 复空间 + 复平面几何 | ✅ |
| `0.1.2.1` | space Proj3 射影空间 + 齐次坐标 + 无穷远点 | ✅ |
| `0.1.2.2` | space StereoMap 球极投影 + 保圆性 | ✅ |
| `0.1.2.3` | platform/crs CRS + WGS84/UTM/CGCS2000 + 投影变换 | ✅ |
| `0.1.2.4` | platform/data Feature/Layer/Dataset 要素模型 | ✅ |
| `0.1.2.5` | space Raster2 栅格空间 + 矢栅转换 | ✅ |
| `0.1.2.6` | algo boolean 布尔运算（交/并/差） | ✅ |
| `0.1.2.7` | algo triangulate + buffer + 拓扑修复 | ✅ |
| `0.1.2.8` | draw style + canvas2 + canvas3 | ✅ |
| `0.1.2.9` | platform/io geojson 读写 + JSON 解析器 | ✅ |
| `0.1.2.10` | platform/mesh IndexedMesh + platform/io STL 读写 | ✅ |
| `0.1.2.11` | 复射影大一统验证 + 阶段二收尾 | ✅ |

测试：664 通过 · 基准：13 · CRAP：490 · 变异分数：100%

> **核心 Trait 冻结**（0.1.1.12）：Geo/Space/Bv/Topo 接口冻结至 1.0 发布前。0.x 阶段不承诺 API 冻结——接口可能调整，到 1.0 后锁定。详见 [ADR-005](docs/adr/005-core-trait-freeze.md)

## 构建与测试

```bash
moon check    # 类型检查
moon test     # 运行测试
moon fmt      # 格式化
moon info     # 生成 .mbti 接口
```

## 文档

- [技术规范](docs/geo%20统一空间数学引擎%20·%20开发立项技术规范.md)
- [迭代详表](docs/geo%20统一空间数学引擎%20·%20迭代计划详表.md)
- [开发规则](docs/rules.md)
- [工程规约](AGENTS.md)

## License

Apache-2.0
