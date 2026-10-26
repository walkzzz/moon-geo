# MoonBit 开发踩坑与语法速查

> 基于 moon-geo 项目（moon 0.1.20261020）开发中确认的非显然规则与陷阱。
> 按类别组织，每条均经 `moon check` / `moon test` 验证。

---

## 1. 语法规则

### 1.1 浮点字面量必须带小数点

```moonbit
let x = 1.0e-8  // ✅ 合法
let y = 1e-8    // ❌ 解析错误
let z = 1.0     // ✅ 合法
```

### 1.2 `fn` 是关键字，不能用作变量名

```moonbit
let fn = 0      // ❌ 编译错误
let fn_offset = 0 // ✅ 改名
```

### 1.3 范围循环起始值不支持表达式

```moonbit
for j in (i + 1)..n { ... }  // ❌ 编译报错
let start = i + 1             // ✅ 先提取为变量
for j in start..<n { ... }
```

### 1.4 不支持 `fun(x) { ... }` lambda 语法

```moonbit
arr.map(fun(x) { x * 2 })  // ❌ 报错
// ✅ 用 while 循环替代
let result = []
for i in 0..<arr.length() { result.push(arr[i] * 2) }
```

### 1.5 元组访问用 `.0`/`.1` 而非 `._0`/`._1`

```moonbit
let t = (1, 2)
let a = t.0  // ✅
let b = t._0 // ❌ 编译报错
```

### 1.6 `not()` 已废弃，用 `!expr`

```moonbit
if not(x.is_empty()) { ... }  // ❌ 废弃
if !x.is_empty() { ... }       // ✅
```

### 1.7 `raise` 在 match 分支中需用块包裹

```moonbit
match x {
  Some(v) => raise Error(...)  // ❌ 错误码 3800
  Some(v) => { raise Error(...) } // ✅ 块包裹
  _ => default
}
```

### 1.8 struct 更新语法 `{ ..self, field: value }`

```moonbit
let updated = { ..original, x: 42.0, }
```

### 1.9 `moon.pkg` 用 `import` 语法而非 JSON

```moonbit
// moon.pkg 文件
import {
  "walkzzz/moon-geo/util",
  "moonbitlang/core/math",
}
```

---

## 2. 类型系统

### 2.1 foreign type 限制

内置类型 `Double`/`Int` 等是 foreign type：
- **不能** `pub extend Double with Trait::{method}`（报 "Cannot define method for foreign type"）
- `impl Trait for Double` 语法包内可用，但 **trait impl 不导出到黑盒测试**
- 对策：foreign type 的 trait 方法用白盒测试验证；黑盒测试用导出的自由函数

### 2.2 `pub enum` vs `pub(all) enum` 可见性

```moonbit
pub enum Color { Red }       // 外部包可 match 但不能构造
pub(all) enum Color { Red }  // 外部包可构造
```

### 2.3 `pub(open) trait` 才能被外部包实现

```moonbit
pub trait Foo { ... }       // 外部包不能 impl
pub(open) trait Foo { ... } // 外部包可 impl
```

### 2.4 不支持泛型 trait（`trait[T]` 语法）

```moonbit
trait[T] Mapper { ... }  // ❌ 编译报错
// ✅ 用非泛型 trait 做元数据接口，泛型方法下放到具体类型
```

### 2.5 `assert_eq` 需要 `Debug` trait

```moonbit
pub enum MyEnum { A, B } derive(Eq, Debug) // 必须 derive Debug 才能 assert_eq
```

### 2.6 struct 字段默认 public 可读

```moonbit
pub struct Pt { x : Double }
let p = Pt::{ x: 1.0 }
let x = p.x  // ✅ 直接字段访问，pub 修饰符冗余
```

### 2.7 跨包 struct 字段访问需用方法

```moonbit
// @alg.Pt2 的 x/y 字段无 pub 修饰，跨包不能直接访问
let x = pt.x   // ❌ 跨包不可用
let x = pt.x() // ✅ 用方法调用
```

---

## 3. 错误处理

### 3.1 suberror 定义错误类型

```moonbit
pub(all) suberror GeoError {
  DegenerateInput(String, Array[String])
  OutOfBounds(String)
  FormatError(String)
  TopoInconsistent(String)
} derive(Debug)
```

### 3.2 raise 函数签名

```moonbit
pub fn f(x : Double) -> Double raise @util.GeoError {
  if x < 0.0 { raise @util.GeoError::FormatError("负数") }
  x.sqrt()
}
```

### 3.3 `!` 后缀运算符限制

```moonbit
// ❌ 测试函数中不能用 ! 调用 raise 函数（错误码 3002）
let x = f()!

// ❌ ! 不能嵌在构造器内
Some(f()!)

// ✅ try 块内直接调用，无需 !
try {
  let x = f(...)
  // 使用 x
} catch {
  _ => handler
}

// ✅ test 块中可直接调用 raise 函数（test 块传播 raise）
test "foo" {
  let mesh = HEMesh::from_triangles(pts, tris) // 直接调用，无需 ! 或 try-catch
}
```

### 3.4 `panic()` 在测试中不可用

```moonbit
test "fail" { panic("...") }  // ❌
test "fail" { assert_true(false) } // ✅
```

---

## 4. `@math` 包 API

### 4.1 数学函数是自由函数，非 Double 方法

```moonbit
x.sin()       // ❌ Double 没有 sin 方法
@math.sin(x)  // ✅ 自由函数

x.pow(2.0)        // ❌ 废弃
@math.pow(x, 2.0) // ✅
```

### 4.2 常量与函数名

| 废弃 | 正确 |
|------|------|
| `@math.pi` | `@math.PI` |
| `@math.log(x)` | `@math.ln(x)` |
| `base.pow(exp)` | `@math.pow(base, exp)` |

### 4.3 需在 moon.pkg 声明依赖

```moonbit
// moon.pkg
import { "moonbitlang/core/math", }
```

---

## 5. 字符与字符串

### 5.1 `Char::to_string()` 返回数字码而非字符

```moonbit
'A'.to_string()       // → "65"（Unicode 码点），不是 "A"
"\{'A'}"              // → "65"，同样返回数字码
s.substring(start=i, end=i+1) // ✅ 提取单字符子串
```

### 5.2 Byte 字面量

```moonbit
let b = b'\x00'     // ✅ byte 字面量语法
let b = 0x0.to_byte() // ❌ Int 没有 to_byte 方法
let b = (0 : Int32).to_byte() // ✅ Int32 有 to_byte
```

---

## 6. 数值转换

### 6.1 `Int` vs `Int32` 方法差异

```moonbit
(0 : Int).to_byte()   // ❌ Int 没有 to_byte
(0 : Int32).to_byte() // ✅ Int32 有 to_byte
```

### 6.2 Float 相关

```moonbit
// Float::from_double 在 moonbitlang/core/float 包中，需导入
let f = @float.Float::from_double(1.0)
let bytes = f.to_le_bytes()           // 4 字节 Bytes (float32 LE)
let f2 = @float.Float::reinterpret_from_int(bits : Int32)
let d = f2.to_double()                // Float → Double
```

### 6.3 Bytes 构造

```moonbit
let bytes = Bytes::from_iter(arr.iter()) // 从 Array[Byte] 构造
```

---

## 7. 测试

### 7.1 黑盒 vs 白盒测试

| 类型 | 后缀 | 可见性 | 用途 |
|------|------|--------|------|
| 黑盒 | `_test.mbt` | 外部视角 | 测公开 API |
| 白盒 | `_wbtest.mbt` | 包内视角 | 测私有成员、跨包 trait impl |

### 7.2 黑盒测试显式包引用

```moonbit
// 黑盒测试中用显式全限定
assert_true(@util.dbl_approx_eq(x, 0.0, @util.EPS)) // ✅
assert_true(dbl_approx_eq(x, 0.0, EPS))              // ❌ 裸引用触发警告
```

### 7.3 黑盒测试看不到跨包 trait impl

```moonbit
// 源码: impl @atop.Dim for Euclid2 — 编译通过
// 黑盒测试: @atop.Dim::dim(p) — ❌ "no impl is defined"
// 对策: 用白盒测试 _wbtest.mbt
```

### 7.4 数值断言禁止 `assert_eq` 比浮点

```moonbit
assert_eq(0.1 + 0.2, 0.3)                          // ❌
assert_true(@util.dbl_approx_eq(0.1 + 0.2, 0.3, @util.EPS)) // ✅
```

### 7.5 bench 语法

```moonbit
test "bench name" (it : @bench.T) {
  it.bench(fn() {
    let result = computation()
    it.keep(result)
  })
}
// 运行: moon bench --target native
```

---

## 8. trait 与 impl

### 8.1 impl 语法（每个方法单独声明）

```moonbit
impl Trait for Type with fn method1(self : Self) { ... }
impl Trait for Type with fn method2(self : Self) { ... }
// ❌ 不用 Rust 风格 grouped block
```

### 8.2 `pub extend` 提升方法为点语法

```moonbit
impl Geo for Pt2 with fn geo_dim(_) { GeoDim::TwoD }
pub extend Pt2 with Geo::{geo_dim, is_degenerate}
// 之后可 pt.geo_dim() 而非 Geo::geo_dim(pt)
```

### 8.3 trait 对象运行时多态

```moonbit
// pub(open) trait + object-safe 方法 → 可用 &Trait
let geos : Array[&Geo] = [pt1 as &Geo, pt2 as &Geo]
geos[0].geo_dim()
```

### 8.4 derive(Eq, Debug) 触发警告

```moonbit
pub struct Foo { ... } derive(Eq, Debug) // 触发 implicit_impl_as_method 警告
// 建议: 加 pub extend Foo with Eq::{not_equal, equal}
//        加 pub extend Foo with @moonbitlang/core/debug.Debug::{to_repr}
```

---

## 9. 工具链

### 9.1 验证命令

```bash
moon check    # 类型检查（快速）
moon test     # 运行测试
moon fmt      # 格式化
moon info     # 生成 .mbti 接口文件
moon bench    # 运行基准测试
```

### 9.2 `.moon/cache/deps` 缓存锁定（Windows）

Windows 下 `.mbtx` 工具脚本因依赖缓存锁频繁失败。对策：优先用 bash 脚本（`.sh`）而非 `.mbtx`。

### 9.3 `warning-off` 注解当前版本不可用

```moonbit
//warning-off(unused_constructor)  // ❌ 不生效
// 对策: 接受良性警告，重构消除未用代码
```

### 9.4 移除 moon.pkg deps 前必须检查测试文件

测试文件（`_test.mbt` / `_wbtest.mbt`）中常以 `@util.X` 引用 dep 符号。仅查源文件就移除 dep 会导致测试编译报 "Unresolved import"。

---

## 10. Git / Windows git-bash

### 10.1 多行 commit 消息可能静默失败

含特殊字符（括号、换行）的多行 commit 消息可能不报错但不创建 commit。对策：用单行消息。

```bash
# ❌ 可能静默失败
git commit -m "fix: 修复A
新增B（测试）"

# ✅ 单行
git commit -m "fix: fix A and add B with tests"
```

### 10.2 `cat >>` 和 Python `open('a')` 可能静默失败

Windows git-bash 下追加内容可能静默失败。对策：用 `edit` 工具而非 shell 追加。

### 10.3 `sed -i` 在 git-bash 下工作正常

```bash
sed -i "s/old/new/" file.md  # ✅ 可用
```

### 10.4 推送命令

```bash
GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no -p 22" git push origin master
```

---

## 11. 精度与公差

### 11.1 三层公差体系

```moonbit
@util.dbl_approx_eq(a, b, tol)                    // 绝对公差
@util.rel_approx_eq(a, b, rel_tol)                 // 相对公差
@util.mixed_approx_eq(a, b, abs_tol, rel_tol)      // 混合公差（推荐）
@util.scaled_approx_zero(a, scale, rel_tol)        // 带量级标定的判零
```

### 11.2 大尺度坐标不能用裸 EPS

```moonbit
// ❌ 半径 1e6 的圆，disc 量级 1e12，EPS=1e-8 判零失效
if disc < -@util.EPS { ... }

// ✅ 用 scaled_approx_zero，公差随量级自适应
let disc_scale = (qb * qb).abs() + (4.0 * qa * qc).abs()
if @util.scaled_approx_zero(disc, disc_scale, @util.EPS) { ... }
```

---

## 12. 常见编译错误码

| 错误码 | 原因 | 对策 |
|--------|------|------|
| 3800 | raise 在 match 分支未包裹 | 用 `{ raise ... }` 块包裹 |
| 3002 | `!` 用在测试函数或构造器内 | 用 `try/catch` 或直接调用 |
| — | `trait[T]` 泛型 trait | 改用非泛型 trait |
| — | `pub trait` 被外部包 impl | 改为 `pub(open) trait` |
| — | `pub enum` 被外部包构造 | 改为 `pub(all) enum` |
| — | foreign type extend | 用自由函数替代 |
