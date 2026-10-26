# FFI 策略 RFC

> 状态：草案  
> 日期：2026-10  
> 对应前瞻性审查 §3.2  

## 1. 背景

moon-geo 作为 MoonBit 语言项目，性能关键路径几乎必然需要 FFI 到 C/C++ 库：
- **BLAS/LAPACK**：矩阵运算，硬件优化
- **PROJ**：坐标投影变换，30 年积累
- **GDAL**：格式 I/O，格式太多自研不现实
- **CGAL**：精确几何谓词
- **CUDA/OpenCL**：GPU 加速

FFI 是双刃剑：获得性能/功能但引入 C 依赖、内存管理复杂度、跨平台编译负担、安全风险。

## 2. 引入评审标准

### 2.1 应该用 FFI 的场景

- 性能差距 ≥ 10x（如矩阵乘法 vs BLAS）
- 功能不可自研或自研成本极高（如 PROJ 投影、GDAL 格式解析）
- 需要硬件加速（GPU/SIMD）

### 2.2 不应该用 FFI 的场景

- 性能差距 < 3x（MoonBit 原生足够）
- 功能可自研且工作量可控（如基础几何运算）
- 仅为便利而非必要（如用 C 字符串替代 MoonBit 字符串）

## 3. 优先 FFI 候选

| 优先级 | 库 | 用途 | 理由 |
|--------|-----|------|------|
| P1 | PROJ | platform/crs 投影变换 | 30 年积累，投影公式陷阱密布，不可重写 |
| P2 | BLAS | util/mat 矩阵运算 | 硬件优化，科学计算标准 |
| P3 | GDAL | platform/io 格式 I/O | 格式太多自研不现实 |
| P4 | CGAL | alg 精确谓词 | exact predicates，工业验证 |

## 4. 安全 Wrapper 模式

C 指针封装为 MoonBit RAII 类型，自动释放：

```
// 概念设计（非实际语法）
struct ProjCRS {
  ptr : RawPointer  // C 指针
}

fn ProjCRS::new(...) -> ProjCRS {
  { ptr: proj_create(...) }
}

fn ProjCRS::drop(self) {
  proj_destroy(self.ptr)
}
```

## 5. 跨平台编译

- C 依赖需提供 CMake/configure 构建
- 评估 vcpkg/conan 包管理
- CI 矩阵需包含 C 依赖的跨平台验证

## 6. 评估 MoonBit FFI 成熟度

待调研：
- 是否有自动绑定生成？
- GC 对象与 C 指针如何交互？
- 错误如何跨边界传递？
- 跨平台编译支持？

## 7. 时间线

- **2027**：platform/crs 落地时评估 PROJ FFI
- **2028**：platform/io 落地时评估 GDAL FFI
- **2029**：性能优化阶段评估 BLAS FFI
- **2030+**：GPU 加速阶段评估 CUDA/OpenCL FFI
