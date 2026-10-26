#!/bin/bash
# CRAP 指标报告（纯 bash，无 python 依赖）
# CRAP(m) = comp^2 + comp * (1 - cov), cov=1.0 → CRAP = comp^2
cd "$(dirname "$0")/.." || exit 1

echo "=== CRAP 指标报告 (util + atop + space + alg + bv, 0.1.1.9) ==="
echo "公式: CRAP = comp^2 (cov=1.0, 测试全绿)"
echo "注: 静态表，收尾时需 diff 本表函数列表 vs 实际 pub fn 列表（moon info）以同步"
echo ""

total_crap=0
high=0; mid=0; low=0; count=0

report() {
  local name="$1" comp="$2"
  local crap=$((comp * comp))
  total_crap=$((total_crap + crap))
  count=$((count + 1))
  local risk
  if [ $crap -gt 5 ]; then risk="高"; high=$((high+1))
  elif [ $crap -gt 1 ]; then risk="中"; mid=$((mid+1))
  else risk="低"; low=$((low+1))
  fi
  if [ $comp -gt 1 ]; then
    printf "  %-28s comp=%d  CRAP=%d  %s\n" "$name" "$comp" "$crap" "$risk"
  fi
}

# num.mbt
report "dbl_abs" 2; report "Double::clamp" 3
# cpx.mbt
report "Cpx::inv" 2; report "Cpx::div" 2
# vec.mbt
report "Vec2::normalize" 2; report "Vec3::normalize" 2
# mat.mbt
report "Mat3::inv" 2; report "Mat3::approx_eq" 2; report "Mat3::approx_zero" 2
report "Mat4::approx_eq" 2; report "Mat4::approx_zero" 2
# quat.mbt
report "Quat::normalize" 2; report "Quat::slerp" 4
# poly.mbt
report "Poly1::degree" 2; report "Poly1::eval" 2; report "Poly1::mul" 3
report "Poly1::derivative" 2; report "Poly1::approx_eq" 2; report "Poly1::approx_zero" 2
report "PolyN::is_zero" 2; report "PolyN::add" 5; report "PolyN::approx_eq" 3; report "PolyN::approx_zero" 2
# mat.mbt Mat4 新增
report "Mat4::det" 1; report "Mat4::inv" 6
# atop.mbt（trait 方法 comp=1，in_metric_ball comp=1，均不列出）
# space.mbt（Euclid2/3::distance comp=1，SpaceMap impl comp=1，均不列出）
# alg/line2.mbt
report "Line2::distance_to_point" 2; report "Line2::intersect" 2; report "Line2::is_degenerate" 2
# alg/circle.mbt + alg/conic2.mbt
report "Circle::from_three_points" 2; report "Conic2::classify" 2; report "Conic2::is_degenerate" 3
# alg/plane3.mbt + alg/sphere.mbt + alg/quad3.mbt
report "Plane3::distance_to_point" 2; report "Plane3::is_degenerate" 3
report "Sphere::tangent_length" 2; report "Circle::tangent_length" 2; report "Quad3::is_degenerate" 3

echo ""
echo "总函数数: $count (仅列出 comp>1 的函数)"
echo "总 CRAP: $total_crap"
echo "高风险(>5): $high, 中风险(1-5): $mid, 低风险(≤1): $low"
