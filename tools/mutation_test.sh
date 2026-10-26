#!/bin/bash
# 变异测试脚本：对 util 包源码应用变异，运行 moon test 验证测试套件能否捕获
# 变异分数 MS = killed / total × 100%
cd "$(dirname "$0")/.." || exit 1

killed=0
survived=0
total=0
echo "=== 变异测试报告 ==="
echo "变异体 | 状态"
echo "-------|------"

run_mutation() {
  local file="$1" old="$2" new="$3" desc="$4"
  total=$((total+1))
  cp "$file" "$file.bak"
  python3 -c "import sys; p,o,n=sys.argv[1:4]; c=open(p,encoding='utf-8').read(); open(p,'w',encoding='utf-8').write(c.replace(o,n,1))" "$file" "$old" "$new"
  moon test > /dev/null 2>&1
  local code=$?
  mv "$file.bak" "$file"
  if [ $code -ne 0 ]; then
    killed=$((killed+1))
    echo "$desc | KILLED"
  else
    survived=$((survived+1))
    echo "$desc | SURVIVED"
  fi
}

# === num.mbt 变异 ===
run_mutation "util/num.mbt" "dbl_abs(self - other)" "dbl_abs(self + other)" "Double::approx_eq: - -> +"

# === cpx.mbt 变异 ===
run_mutation "util/cpx.mbt" "self.re + other.re" "self.re - other.re" "Cpx::add re: + -> -"
run_mutation "util/cpx.mbt" "self.im + other.im" "self.im - other.im" "Cpx::add im: + -> -"
run_mutation "util/cpx.mbt" "self.re * self.re + self.im * self.im" "self.re * self.re - self.im * self.im" "Cpx::norm_sq: + -> -"
run_mutation "util/cpx.mbt" "im: -self.im" "im: self.im" "Cpx::conj: drop neg"
run_mutation "util/cpx.mbt" "re: self.re * inv_d, im: -self.im * inv_d" "re: -self.re * inv_d, im: self.im * inv_d" "Cpx::inv: flip sign"
run_mutation "util/cpx.mbt" "self.re * other.re - self.im * other.im" "self.re * other.re + self.im * other.im" "Cpx::mul re: - -> +"
run_mutation "util/cpx.mbt" "self.re * other.im + self.im * other.re" "self.re * other.im - self.im * other.re" "Cpx::mul im: + -> -"

# === vec.mbt 变异 ===
run_mutation "util/vec.mbt" "self.x * other.x + self.y * other.y" "self.x * other.x - self.y * other.y" "Vec2::dot: + -> -"
run_mutation "util/vec.mbt" "self.x * other.y - self.y * other.x" "self.x * other.y + self.y * other.x" "Vec2::cross: - -> +"
run_mutation "util/vec.mbt" "self.x + other.x" "self.x - other.x" "Vec2::add x: + -> -"

# === mat.mbt 变异 ===
run_mutation "util/mat.mbt" "m[0] * (m[4] * m[8] - m[5] * m[7])" "m[0] * (m[4] * m[8] + m[5] * m[7])" "Mat3::det: - -> +"

# === quat.mbt 变异 ===
run_mutation "util/quat.mbt" "self.w * other.w - self.x * other.x - self.y * other.y - self.z * other.z" "self.w * other.w + self.x * other.x - self.y * other.y - self.z * other.z" "Quat::mul w: - -> +"

# === poly.mbt 变异 ===
run_mutation "util/poly.mbt" "result = result * x + self.coeffs[idx]" "result = result * x - self.coeffs[idx]" "Poly1::eval: + -> -"
run_mutation "util/poly.mbt" "r[i + j] = r[i + j] + self.coeffs[i] * other.coeffs[j]" "r[i + j] = r[i + j] - self.coeffs[i] * other.coeffs[j]" "Poly1::mul: + -> -"
run_mutation "util/poly.mbt" "r[i - 1] = self.coeffs[i] * k" "r[i - 1] = self.coeffs[i] / k" "Poly1::derivative: * -> /"
run_mutation "util/poly.mbt" "r[i] = r[i] + other.coeffs[i]" "r[i] = r[i] - other.coeffs[i]" "Poly1::add: + -> -"
run_mutation "util/poly.mbt" "result = result + prod" "result = result - prod" "PolyN::eval: + -> -"

# === space/euclid3.mbt 变异 ===
run_mutation "space/euclid3.mbt" "dx * dx + dy * dy + dz * dz" "dx * dx - dy * dy + dz * dz" "Euclid3::distance: + -> -"

# === space/space_map.mbt 变异 ===
run_mutation "space/space_map.mbt" "Euclid3::new(src.x(), src.y(), self.z_offset)" "Euclid3::new(src.y(), src.x(), self.z_offset)" "Embed2In3::map: swap x/y"
run_mutation "space/space_map.mbt" "Euclid2::new(src.x(), src.y())" "Euclid2::new(src.y(), src.x())" "Project3To2::map: swap x/y"

# === alg/line2.mbt 变异 ===
run_mutation "alg/line2.mbt" "self.b * other.c - other.b * self.c" "self.b * other.c + other.b * self.c" "Line2::intersect x: - -> +"
run_mutation "alg/line2.mbt" "other.a * self.c - self.a * other.c" "other.a * self.c + self.a * other.c" "Line2::intersect y: - -> +"
run_mutation "alg/line2.mbt" "p1.x() * p2.y() - p2.x() * p1.y()" "p1.x() * p2.y() + p2.x() * p1.y()" "Line2::from_two_points c: - -> +"

# === alg/circle.mbt 变异 ===
run_mutation "alg/circle.mbt" "3.14159265358979323846 * self.r * self.r" "3.14159265358979323846 * self.r + self.r" "Circle::area: * -> +"

# === alg/conic2.mbt 变异 ===
run_mutation "alg/conic2.mbt" "self.b * self.b - 4.0 * self.a * self.c" "self.b * self.b + 4.0 * self.a * self.c" "Conic2::discriminant: - -> +"

# === alg/sphere.mbt 变异 ===
run_mutation "alg/sphere.mbt" "dx * dx + dy * dy + dz * dz - self.r * self.r" "dx * dx + dy * dy + dz * dz + self.r * self.r" "Sphere::power: - -> +"
run_mutation "alg/sphere.mbt" "4.0 / 3.0 * 3.14159265358979323846 * self.r * self.r * self.r" "4.0 / 3.0 * 3.14159265358979323846 * self.r * self.r + self.r" "Sphere::volume: * -> +"

ms=$(python3 -c "print(f'{$killed/$total*100:.1f}')" 2>/dev/null || echo "N/A")
echo ""
echo "变异分数 MS = $killed/$total = $ms%"
echo "杀死: $killed, 存活: $survived"
