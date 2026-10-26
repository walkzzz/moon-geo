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

description = "统一空间数学引擎：复射影代数几何 + 代数拓扑内核，覆盖全维度/全数域/全空间类型的通用几何计算"
