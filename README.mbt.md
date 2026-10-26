# moon-geo · 统一空间数学引擎 + 数据处理平台

> MoonBit 实现的开源学术驱动空间数学基础设施。**后端库**：以复射影代数几何 + 代数拓扑为底层内核的统一空间数学引擎（九层洋葱，终身稳定）。**前端平台**：`platform/` 数据处理平台，承载要素/图层/数据集 + CRS + 格式 I/O + 流式/LOD，覆盖点云/倾斜摄影/正射影像/栅格/矢量/CAD/3D 模型等真实业务数据类型。

**20 年规划**（2026 → 2046）：4 纪元 × 5 年，核心架构终身稳定。

## 架构：后端九层 + 前端平台

### 后端库：统一空间数学引擎

```
util(-1) → atop(0) → space(1) → alg(2) → bv(3) → brep(4) → algo(5) → parallel(6) → domain(7) → eco(8)
```

| 层 | 包名 | 职责 |
|----|------|------|
| -1 | `util` | 数域/数值/矩阵/精度体系 |
| 0 | `atop` | 拓扑空间/流形/范畴化抽象 |
| 1 | `space` | 欧氏/复/射影/非欧/时空/栅格 |
| 2 | `alg` | 代数簇/变换/不变量/求交 |
| 3 | `bv` | 包围体/空间索引树 |
| 4 | `brep` | 流形/非流形/胞腔复形 |
| 5 | `algo` | 基础几何/GIS/高阶拓扑 |
| 6 | `parallel` | CPU多线程/GPU/分布式 |
| 7 | `domain` | CAD/GIS/仿真/视觉/机器人 |
| 8 | `eco` | 语言绑定/格式兼容/引擎对接 |

### 前端平台：数据处理平台（`platform/`）

| 层 | 包名 | 职责 |
|----|------|------|
| P1 | `platform/crs` | CRS/EPSG/投影变换（WGS84/UTM/CGCS2000） |
| P2 | `platform/mesh` | IndexedMesh + 属性通道（法向/UV/材质）+ 网格简化 |
| P3 | `platform/pcloud` | PointCloud + 属性 + 降采样/法向/地面滤波/RANSAC/ICP |
| P4 | `platform/data` | Feature/Layer/Dataset + RasterDataset/Tiled/Pyramid + Streaming/LOD |
| P5 | `platform/io` | 格式 I/O（LAS/GeoTIFF/shp/DXF/OBJ/GLTF/OSGB/3DTiles）+ 流式 |

**时序铁律**：I/O 不能先于数据模型和 CRS——先建 `platform/data` + `platform/crs`，再建 `platform/io`。

## 当前进度

**纪元一·奠基纪元 → 阶段一·基础可用（2026）→ `0.1.1.z`**

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

测试：226 通过 · CRAP：210 · 变异分数：100%

## 构建与测试

```bash
moon check    # 类型检查
moon test     # 运行测试
moon fmt      # 格式化
moon info     # 生成 .mbti 接口
moon prove    # 形式化验证（需 Why3 + SMT 求解器）
```

## 文档

- [技术规范](docs/geo%20统一空间数学引擎%20·%20开发立项技术规范.md)（1128 行）
- [迭代详表](docs/geo%20统一空间数学引擎%20·%20迭代计划详表.md)（441 行，排到 2046）
- [开发规则](docs/rules.md)
- [工程规约](AGENTS.md)（§0-§8，含 CRAP/变异/多手段测试/迭代收尾流程）

## License

Apache-2.0
