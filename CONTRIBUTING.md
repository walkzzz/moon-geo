# 贡献指南

感谢你对 moon-geo 的兴趣！本文档帮助你快速参与贡献。

## 开发环境

1. 安装 [MoonBit 工具链](https://docs.moonbitlang.com)
2. 克隆仓库：`git clone https://github.com/walkzzz/moon-geo.git`
3. 验证：`moon check && moon test`

## 开发流程

1. **Fork & Branch**：Fork 仓库，从 `master` 创建分支
2. **编码**：遵循 [AGENTS.md](AGENTS.md) 中的编码规范
3. **测试**：确保 `moon check` 0 errors + `moon test` 全通过
4. **格式化**：`moon fmt` 后无 diff
5. **提交**：commit message 含版本号和摘要
6. **PR**：描述变更内容、测试方式、影响范围

## 编码规范

- 浮点比较用 `approx_eq`/`dbl_approx_eq`，禁止 `==` 比浮点
- 命名：大驼峰（类型）、小蛇形（函数/方法/文件）、全大写下划线（常量）
- 顶层块用 `///|` 分隔
- 错误使用 `raise GeoError`（suberror）+ `try/catch`，禁止 panic
- 不可变原则：修改操作返回新对象
- 依赖铁律：上层只能依赖下层，禁止反向/环依赖

## 测试规范

- 黑盒测试（`*_test.mbt`）测公开 API
- 白盒测试（`*_wbtest.mbt`）测私有成员和跨包 trait impl
- 数值断言用 `assert_true(x.approx_eq(y, tol))`
- 极端边界、退化场景全覆盖

## 架构

- **后端库**：九层洋葱架构（util→atop→space→alg→bv→brep→algo→parallel→domain→eco）
- **前端平台**：`platform/` 五层（crs/mesh/pcloud/data/io）
- 详见 [AGENTS.md](AGENTS.md) §0-§1

## Good First Issues

- 标注 `good-first-issue` 的 issue 适合新手
- 补测现有函数的边界用例
- 补充文档/注释

## 联系

- Issue：GitHub Issues
- 讨论：GitHub Discussions
