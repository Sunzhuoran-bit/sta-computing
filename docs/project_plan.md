# Project Plan

## 项目定位

本项目实现一个基于 R Shiny 的金融收益率厚尾分析系统。项目围绕 Bitcoin 和 S&P 500 日收益率，展示传统正态模型、GTS 厚尾模型和非参数统计计算方法在金融风险分析中的差异。

课程要求包括论文综述、模拟试验、实例验证和算法评价。本项目选择 Shiny App 作为主要交付形式，同时保留可测试的 R 函数接口，方便四人并行开发。

## 交付内容

- Shiny 可视化系统：价格走势、收益率分布、Q-Q 图、尾部风险、Bootstrap、Monte Carlo、置换检验。
- 数据脚本：自动下载 Bitcoin 和 S&P 500 日频数据，并生成收益率。
- 统计计算模块：正态拟合、GTS 数值近似、VaR/CVaR、Bootstrap、Monte Carlo、Permutation Test。
- 文档：README、接口说明、数据来源、论文笔记、团队分工。
- 测试：核心数据处理和统计函数的 testthat 单元测试。

## 实施阶段

1. 项目初始化
   - 建立英文目录结构。
   - 移动参考材料到 `references/`。
   - 初始化 Git 仓库并连接 GitHub 远端。

2. 数据管道
   - 实现 Yahoo Finance Chart API 下载函数。
   - 清洗价格数据，计算百分比日对数收益率。
   - 保存 raw 和 processed CSV。

3. 统计方法
   - 实现正态拟合和正态模拟。
   - 使用论文默认 GTS 参数构造特征函数。
   - 使用数值反演构造 GTS PDF/CDF 网格。
   - 实现 VaR、CVaR、Bootstrap、Monte Carlo、Permutation Test。

4. Shiny App
   - 设计侧边栏控件。
   - 设计数据、分布、尾部风险、模拟、检验、项目说明等页面。
   - 将所有图表和表格绑定到核心函数。

5. 验证与交付
   - 运行数据下载脚本。
   - 运行单元测试。
   - 启动 Shiny App 检查主要页面。
   - 提交并推送到 GitHub。

## 验收标准

- 所有文件名和目录名为英文。
- `src/scripts/download_data.R` 能生成数据文件。
- `src/scripts/run_app.R` 能启动 Shiny App。
- README 可以指导其他同学从零运行项目。
- 统计函数有基础测试。
- Git 仓库连接到 `Sunzhuoran-bit/sta-computing`。
