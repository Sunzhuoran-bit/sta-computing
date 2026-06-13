# Paper Reading Notes

参考论文：

**High-Performance Simulation of Generalized Tempered Stable Random Variates: Exact and Numerical Methods for Heavy-Tailed Data**，Aubain Nzokem and Daniel Maposa，2025。

## 论文核心问题

金融收益率经常出现尖峰厚尾、偏态和极端波动。传统正态分布假设难以描述尾部风险，因此论文研究 Generalized Tempered Stable Distribution，也就是 GTS 分布，用于模拟重尾金融数据。

GTS 分布通过对稳定分布进行指数 tempering，在保留厚尾特征的同时保证矩存在，因此适合金融风险建模。

## 论文主要方法

论文比较了多类 GTS 随机变量生成方法：

- Standard Stable Rejection
- Double Rejection
- Two-Dimensional Single Rejection
- Inverse Levy measure series representation
- Shot Noise series representation
- FRFT-based inverse transform sampling

论文结论认为，Enhanced FRFT-based inversion 方法在拟合精度和尾部表现上最好，特别是在 Bitcoin、Ethereum、S&P 500 和 SPY ETF 等金融数据上表现稳定。

## 本项目采用内容

本项目不完整复现所有算法，而是采用以下内容：

- 使用 GTS 作为厚尾参考模型。
- 使用论文给出的 Bitcoin 和 S&P 500 GTS 参数。
- 使用 GTS 特征函数进行数值反演，构造教学型 PDF/CDF 网格。
- 通过 Q-Q 图、直方图和尾部图展示 GTS 与正态模型的差异。
- 将 GTS 思想用于 VaR、CVaR 和 Monte Carlo 风险模拟展示。

## 本项目不采用内容

- 不重新估计七参数 GTS。
- 不实现完整 Enhanced FRFT。
- 不复现论文中全部六类随机变量生成算法。
- 不处理 Ethereum 和 SPY ETF，除非后续扩展。

## 默认 GTS 参数

Bitcoin：

| Parameter | Value |
| --- | ---: |
| mu | -0.1216 |
| beta_plus | 0.3155 |
| beta_minus | 0.4066 |
| alpha_plus | 0.7477 |
| alpha_minus | 0.5446 |
| lambda_plus | 0.2465 |
| lambda_minus | 0.1748 |

S&P 500：

| Parameter | Value |
| --- | ---: |
| mu | -0.2494 |
| beta_plus | 0.3286 |
| beta_minus | 0.0886 |
| alpha_plus | 0.7924 |
| alpha_minus | 0.5422 |
| lambda_plus | 1.2797 |
| lambda_minus | 0.9371 |

## 课堂展示角度

展示时应强调：

- 金融收益率不是理想正态数据。
- 厚尾会影响尾部风险估计。
- Bootstrap 可以衡量风险指标的不确定性。
- Monte Carlo 可以帮助理解资产配置下的组合风险。
- 置换检验不依赖正态假设，适合比较非正态金融收益率。
