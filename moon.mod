// Learn more about moon.mod configuration:
// https://docs.moonbitlang.com/en/latest/toolchain/moon/module.html
//
// To add a dependency, run this command in your terminal:
//   moon add moonbitlang/x
//
// Or manually declare it in `import`, for example:
// import {
//   "moonbitlang/x@0.4.6",
// }

name = "walkzzz/moon-geo"

version = "0.1.1"

readme = "README.mbt.md"

repository = "https://github.com/walkzzz/moon-geo"

license = "Apache-2.0"

keywords = [ "geometry", "math", "spatial", "moonbit", "cgal", "topology" ]

preferred_target = "wasm"

description = "MoonBit 生态几何计算库：2D/3D 欧氏几何 + 求交/变换 + Delaunay + 布尔运算 + BVH + 半边结构 + CRS 投影 + 格式 I/O"
