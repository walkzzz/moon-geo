// 一元/多元多项式工具
// 第-1层 util

///|
/// 一元多项式：coeffs[0] + coeffs[1]*x + coeffs[2]*x^2 + ...
pub(all) struct Poly1 {
  coeffs : Array[Double]
} derive(Debug)

///|
/// 从系数数组构造（升幂排列）
pub fn Poly1::new(coeffs : Array[Double]) -> Poly1 {
  { coeffs, }
}

///|
/// 常数多项式
pub fn Poly1::constant(c : Double) -> Poly1 {
  { coeffs: [c], }
}

///|
/// 零多项式
pub fn Poly1::zero() -> Poly1 {
  { coeffs: [], }
}

///|
/// 多项式次数（最高非零系数的指数；零多项式返回 -1）
pub fn Poly1::degree(self : Poly1) -> Int32 {
  let n = self.coeffs.length()
  let mut d = -1
  for i in 0..<n {
    if !dbl_approx_zero(self.coeffs[i], EPS) {
      d = i
    }
  }
  d
}

///|
/// 求值（Horner 法）
pub fn Poly1::eval(self : Poly1, x : Double) -> Double {
  let n = self.coeffs.length()
  if n == 0 {
    return 0.0
  }
  let mut result = self.coeffs[n - 1]
  for i in 1..<n {
    let idx = n - 1 - i
    result = result * x + self.coeffs[idx]
  }
  result
}

///|
/// 加法
pub fn Poly1::add(self : Poly1, other : Poly1) -> Poly1 {
  let na = self.coeffs.length()
  let nb = other.coeffs.length()
  let n = if na > nb { na } else { nb }
  let r = Array::make(n, 0.0)
  for i in 0..<na {
    r[i] = r[i] + self.coeffs[i]
  }
  for i in 0..<nb {
    r[i] = r[i] + other.coeffs[i]
  }
  { coeffs: r, }
}

///|
/// 减法
pub fn Poly1::sub(self : Poly1, other : Poly1) -> Poly1 {
  let na = self.coeffs.length()
  let nb = other.coeffs.length()
  let n = if na > nb { na } else { nb }
  let r = Array::make(n, 0.0)
  for i in 0..<na {
    r[i] = r[i] + self.coeffs[i]
  }
  for i in 0..<nb {
    r[i] = r[i] - other.coeffs[i]
  }
  { coeffs: r, }
}

///|
/// 乘法（卷积）
pub fn Poly1::mul(self : Poly1, other : Poly1) -> Poly1 {
  let na = self.coeffs.length()
  let nb = other.coeffs.length()
  if na == 0 || nb == 0 {
    return { coeffs: [], }
  }
  let n = na + nb - 1
  let r = Array::make(n, 0.0)
  for i in 0..<na {
    for j in 0..<nb {
      r[i + j] = r[i + j] + self.coeffs[i] * other.coeffs[j]
    }
  }
  { coeffs: r, }
}

///|
/// 标量乘
pub fn Poly1::scale(self : Poly1, s : Double) -> Poly1 {
  let r = Array::make(self.coeffs.length(), 0.0)
  for i in 0..<self.coeffs.length() {
    r[i] = self.coeffs[i] * s
  }
  { coeffs: r, }
}

///|
/// 求导：d/dx(a_i * x^i) = i * a_i * x^(i-1)
pub fn Poly1::derivative(self : Poly1) -> Poly1 {
  let n = self.coeffs.length()
  if n <= 1 {
    return { coeffs: [], }
  }
  let r = Array::make(n - 1, 0.0)
  let mut k = 1.0
  for i in 1..<n {
    r[i - 1] = self.coeffs[i] * k
    k += 1.0
  }
  { coeffs: r, }
}

///|
/// 是否为零多项式
pub fn Poly1::is_zero(self : Poly1) -> Bool {
  self.degree() == -1
}

///|
impl ApproxEq for Poly1 with fn approx_eq(self, other, tol) {
  let na = self.coeffs.length()
  let nb = other.coeffs.length()
  let n = if na > nb { na } else { nb }
  let mut ok = true
  for i in 0..<n {
    let a = if i < na { self.coeffs[i] } else { 0.0 }
    let b = if i < nb { other.coeffs[i] } else { 0.0 }
    if !dbl_approx_eq(a, b, tol) {
      ok = false
    }
  }
  ok
}

///|
impl ApproxEq for Poly1 with fn approx_zero(self, tol) {
  let mut ok = true
  for i in 0..<self.coeffs.length() {
    if !dbl_approx_zero(self.coeffs[i], tol) {
      ok = false
    }
  }
  ok
}

///|
pub extend Poly1 with @debug.Debug::{to_repr}

///|
pub extend Poly1 with ApproxEq::{approx_eq, approx_zero}

///|
/// 多元多项式项：coeff * x0^exps[0] * x1^exps[1] * ...
pub(all) struct PolyTerm {
  coeff : Double
  exps : Array[Int32]
} derive(Debug)

///|
/// 多元多项式：项的和
pub(all) struct PolyN {
  terms : Array[PolyTerm]
} derive(Debug)

///|
pub fn PolyTerm::new(coeff : Double, exps : Array[Int32]) -> PolyTerm {
  { coeff, exps, }
}

///|
pub fn PolyN::new(terms : Array[PolyTerm]) -> PolyN {
  { terms, }
}

///|
/// 零多项式
pub fn PolyN::zero() -> PolyN {
  { terms: [], }
}

///|
/// 求值：代入各变量值
pub fn PolyN::eval(self : PolyN, xs : Array[Double]) -> Double {
  let mut result = 0.0
  for i in 0..<self.terms.length() {
    let term = self.terms[i]
    let mut prod = term.coeff
    for j in 0..<term.exps.length() {
      let e = term.exps[j]
      let mut pow = 1.0
      for _ in 0..<e {
        pow = pow * xs[j]
      }
      prod = prod * pow
    }
    result = result + prod
  }
  result
}

///|
/// 加法（合并同类项：相同 exps 的项系数相加，规范化表示）
pub fn PolyN::add(self : PolyN, other : PolyN) -> PolyN {
  let r : Array[PolyTerm] = []
  let na = self.terms.length()
  let nb = other.terms.length()
  let all = Array::make(na + nb, PolyTerm::new(0.0, []))
  for i in 0..<na {
    all[i] = self.terms[i]
  }
  for i in 0..<nb {
    all[na + i] = other.terms[i]
  }
  for i in 0..<all.length() {
    let t = all[i]
    let mut found = -1
    for j in 0..<r.length() {
      if found < 0 {
        let re = r[j].exps
        if re.length() == t.exps.length() {
          let mut same = true
          for k in 0..<t.exps.length() {
            if re[k] != t.exps[k] {
              same = false
            }
          }
          if same {
            found = j
          }
        }
      }
    }
    if found >= 0 {
      r[found] = PolyTerm::new(r[found].coeff + t.coeff, r[found].exps)
    } else {
      r.push(t)
    }
  }
  { terms: r, }
}

///|
/// 标量乘
pub fn PolyN::scale(self : PolyN, s : Double) -> PolyN {
  let r = Array::make(self.terms.length(), PolyTerm::new(0.0, []))
  for i in 0..<self.terms.length() {
    let t = self.terms[i]
    r[i] = PolyTerm::new(t.coeff * s, t.exps)
  }
  { terms: r, }
}

///|
/// 是否为零多项式
pub fn PolyN::is_zero(self : PolyN) -> Bool {
  let mut ok = true
  for i in 0..<self.terms.length() {
    if !dbl_approx_zero(self.terms[i].coeff, EPS) {
      ok = false
    }
  }
  ok
}

///|
/// 比较两个指数数组的字典序（用于排序 PolyTerm）
fn compare_exps(a : Array[Int32], b : Array[Int32]) -> Int32 {
  let la = a.length()
  let lb = b.length()
  let n = if la < lb { la } else { lb }
  for i in 0..<n {
    if a[i] < b[i] {
      return -1
    }
    if a[i] > b[i] {
      return 1
    }
  }
  la - lb
}

///|
/// 两个指数数组是否相等
fn exps_equal(a : Array[Int32], b : Array[Int32]) -> Bool {
  if a.length() != b.length() {
    return false
  }
  let mut ok = true
  for i in 0..<a.length() {
    if a[i] != b[i] {
      ok = false
    }
  }
  ok
}

///|
impl ApproxEq for PolyN with fn approx_eq(self, other, tol) {
  let na = self.terms.length()
  let nb = other.terms.length()
  if na != nb {
    return false
  }
  let sa = Array::make(na, PolyTerm::new(0.0, []))
  for i in 0..<na {
    sa[i] = self.terms[i]
  }
  let sb = Array::make(nb, PolyTerm::new(0.0, []))
  for i in 0..<nb {
    sb[i] = other.terms[i]
  }
  sa.sort_by(fn(t1, t2) { compare_exps(t1.exps, t2.exps) })
  sb.sort_by(fn(t1, t2) { compare_exps(t1.exps, t2.exps) })
  let mut ok = true
  for i in 0..<na {
    if !exps_equal(sa[i].exps, sb[i].exps) {
      ok = false
    }
    if !dbl_approx_eq(sa[i].coeff, sb[i].coeff, tol) {
      ok = false
    }
  }
  ok
}

///|
impl ApproxEq for PolyN with fn approx_zero(self, tol) {
  let mut ok = true
  for i in 0..<self.terms.length() {
    if !dbl_approx_zero(self.terms[i].coeff, tol) {
      ok = false
    }
  }
  ok
}

///|
pub extend PolyTerm with @debug.Debug::{to_repr}

///|
pub extend PolyN with @debug.Debug::{to_repr}

///|
pub extend PolyN with ApproxEq::{approx_eq, approx_zero}
