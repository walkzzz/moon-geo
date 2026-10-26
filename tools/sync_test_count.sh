#!/bin/bash
# 自动同步测试数到 README.mbt.md 和 docs/rules.md
# 从 moon test 输出解析测试数，回写文档
# 用法: bash tools/sync_test_count.sh
# 应在每次迭代收尾时执行（AGENTS.md §6.8 步骤 7）
cd "$(dirname "$0")/.." || exit 1

echo "运行 moon test..."
output=$(moon test 2>&1)
test_count=$(echo "$output" | grep "Total tests:" | sed 's/.*Total tests: \([0-9]*\).*/\1/')

if [ -z "$test_count" ]; then
  echo "错误: 无法从 moon test 输出解析测试数"
  echo "$output" | tail -5
  exit 1
fi

echo "测试数: $test_count"

for f in README.mbt.md docs/rules.md; do
  if grep -q "测试：[0-9]* 通过" "$f"; then
    sed -i "s/测试：[0-9]* 通过/测试：$test_count 通过/" "$f"
    echo "已更新 $f"
  else
    echo "警告: $f 中未找到 '测试：N 通过' 行"
  fi
done

echo "同步完成"
