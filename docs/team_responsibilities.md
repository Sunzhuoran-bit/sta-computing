# Team Responsibilities

## Member A: Project Lead / GitHub / Documentation

职责：

- 初始化 Git 仓库并维护远端仓库。
- 维护 README、项目计划和接口文档。
- 管理 issue、branch 和 pull request。
- 负责最终合并、提交规范和项目结构检查。

主要文件：

- `README.md`
- `docs/project_plan.md`
- `docs/interfaces.md`
- `.gitignore`
- `DESCRIPTION`

## Member B: Data Pipeline / Exploratory Visualization

职责：

- 实现数据下载脚本。
- 清洗 Bitcoin 和 S&P 500 价格数据。
- 计算日收益率。
- 绘制价格走势、收益率直方图、Q-Q 图和尾部图。
- 维护数据来源说明。

主要文件：

- `src/R/data_fetch.R`
- `src/R/data_clean.R`
- `src/R/returns.R`
- `src/R/plots.R`
- `src/scripts/download_data.R`
- `docs/data_sources.md`

## Member C: Statistical Computing

职责：

- 实现正态模型和 GTS 模型对比。
- 实现 VaR、CVaR。
- 实现 Bootstrap 区间估计。
- 实现 Monte Carlo simulation。
- 实现 permutation test。
- 编写统计函数测试。

主要文件：

- `src/R/normal_model.R`
- `src/R/gts_model.R`
- `src/R/risk_metrics.R`
- `src/R/bootstrap.R`
- `src/R/monte_carlo.R`
- `src/R/permutation_test.R`
- `tests/testthat/`

## Member D: Shiny App / Presentation

职责：

- 设计 Shiny 页面结构。
- 实现交互控件和结果展示。
- 集成图表、表格和统计结果。
- 优化课堂展示体验。
- 协助准备演示讲稿和截图。

主要文件：

- `app.R`
- `src/app/ui.R`
- `src/app/server.R`
- `outputs/figures/`

## Collaboration Rules

主分支：

- `main`

功能分支：

- `feature/project-scaffold`
- `feature/data-pipeline`
- `feature/statistical-methods`
- `feature/shiny-app`
- `feature/docs-report`

Pull Request 要求：

- 说明改了什么。
- 说明为什么改。
- 说明如何测试。
- 不提交大型临时文件。
- 不提交 `data/raw/*.csv` 和 `data/processed/*.csv`。

提交信息建议：

```text
Add Yahoo Finance data pipeline
Implement risk metrics
Build Shiny distribution tabs
Document team responsibilities
```
