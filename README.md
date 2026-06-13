# Sta Computing

基于 R Shiny 的加密货币与股票市场波动可视化分析系统。

本项目是统计计算课程期末大作业。我们参考论文 **High-Performance Simulation of Generalized Tempered Stable Random Variates: Exact and Numerical Methods for Heavy-Tailed Data**，但不完整复现论文中的 FRFT 和全部 GTS 随机变量生成算法。项目重点是结合真实金融数据，展示厚尾、非正态和极端波动条件下统计计算方法的重要性。

## 项目目标

- 使用 Bitcoin 和 S&P 500 过去五年日频数据。
- 对比收益率的经验分布、正态分布和 GTS 厚尾分布。
- 展示正态假设对尾部风险的低估问题。
- 计算 VaR 和 CVaR，并使用 Bootstrap 给出区间估计。
- 使用 Monte Carlo simulation 模拟不同资产权重下的组合收益。
- 使用 permutation test 比较两类资产收益率分布差异。
- 开发一个可交互的 R Shiny App，用于课堂展示和结果解释。

## 环境要求

本机已检测到 R 4.4.2 安装在：

```powershell
C:\Program Files\R\R-4.4.2\bin\Rscript.exe
```

如果 `Rscript` 没有加入 PATH，可以用完整路径运行命令。

安装依赖：

```r
install.packages(c("jsonlite", "shiny", "testthat"))
```

项目核心计算尽量使用 base R 和 `jsonlite`，Shiny App 需要 `shiny`。

## 快速开始

### Linux

**一键运行**：

```bash
# 一键启动
./run.sh
```

**或者分步执行**：

```bash
# 或分步执行
Rscript src/scripts/download_data.R   # 下载数据
Rscript src/scripts/run_app.R         # 启动 Shiny App
Rscript tests/testthat.R              # 运行测试
```



### Windows

```powershell
& "C:\Program Files\R\R-4.4.2\bin\Rscript.exe" src/scripts/download_data.R
& "C:\Program Files\R\R-4.4.2\bin\Rscript.exe" src/scripts/run_app.R
& "C:\Program Files\R\R-4.4.2\bin\Rscript.exe" tests/testthat.R
```

## 项目结构

```text
sta-computing/
  app.R
  config/
  data/
    raw/
    processed/
  docs/
  references/
  src/
    app/
    R/
    scripts/
  tests/
    testthat/
  outputs/
```

说明：

- `src/R/`：数据处理、统计计算、GTS 数值近似、风险指标和绘图函数。
- `src/app/`：Shiny UI 和 Server。
- `src/scripts/`：数据下载和 App 启动脚本。
- `docs/`：项目计划、接口文档、数据源说明、论文阅读笔记和分工文档。
- `references/`：作业要求、开题报告和参考论文。
- `data/raw/`：原始下载数据，不提交 CSV。
- `data/processed/`：处理后的价格和收益率数据，不提交 CSV。

## 数据来源

- Bitcoin：Yahoo Finance Chart API，代码中使用 `BTC-USD`。
- S&P 500：Yahoo Finance Chart API，代码中使用 `^GSPC`。
- CoinMarketCap：作为论文中 Bitcoin 历史数据来源的说明和备用参考。

默认时间范围为 `2021-06-12` 到 `2026-06-12`。数据下载脚本会生成：

- `data/raw/btc_usd_prices.csv`
- `data/raw/gspc_prices.csv`
- `data/processed/prices.csv`
- `data/processed/returns.csv`

## 方法说明

正态模型：

- 使用样本均值和标准差拟合收益率。
- 用于展示传统高斯假设在厚尾数据下的局限。

GTS 模型：

- 使用论文表格中的 Bitcoin 和 S&P 500 七参数 GTS 估计值。
- 使用特征函数数值反演构造近似 PDF/CDF 网格。
- 使用逆变换抽样生成 GTS 模拟收益率。
- 该实现是教学型数值近似，不声称完整复现论文中的 Enhanced FRFT 算法。

Bootstrap：

- 对经验收益率重抽样。
- 计算 VaR 和 CVaR 的置信区间。
- 支持调整 Bootstrap 次数，观察稳定性和计算成本。

Monte Carlo：

- 支持经验重抽样、正态模型和 GTS 模型。
- 用于模拟不同 Bitcoin / S&P 500 权重下的组合收益分布。

Permutation Test：

- 比较 Bitcoin 和 S&P 500 收益率在均值、中位数或方差上的差异。
- 展示非参数统计方法在非正态金融数据中的适用性。

## GitHub 协作流程

目标仓库：

```text
https://github.com/Sunzhuoran-bit/sta-computing
```

建议分支：

- `main`
- `feature/project-scaffold`
- `feature/data-pipeline`
- `feature/statistical-methods`
- `feature/shiny-app`
- `feature/docs-report`

每个 Pull Request 至少说明：

- 改了什么
- 为什么改
- 如何测试

## 局限性

- 本项目不是论文的完整复现。
- GTS 参数来自论文，不在本项目中重新估计。
- GTS 模拟使用特征函数数值反演和离散 CDF 网格，不实现完整 Enhanced FRFT。
- 风险结果用于课程展示和统计计算说明，不构成投资建议。
