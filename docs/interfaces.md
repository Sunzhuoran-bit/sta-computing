# Interfaces

## Data

```r
fetch_yahoo_prices(symbol, start_date, end_date)
```

从 Yahoo Finance Chart API 下载日频价格数据。返回字段：

- `date`
- `symbol`
- `open`
- `high`
- `low`
- `close`
- `adjusted`
- `volume`

```r
clean_price_data(price_data)
```

检查必需字段，转换日期和数值列，移除无效价格和重复日期。

```r
compute_returns(price_data, price_col = "adjusted")
```

计算百分比日对数收益率和简单收益率。返回字段：

- `date`
- `symbol`
- `close`
- `price`
- `log_return`
- `simple_return`

## Distribution Models

```r
fit_normal_model(returns)
```

返回样本均值、标准差和样本量。

```r
get_gts_parameters(asset_id)
```

根据 `BTC-USD`、`bitcoin`、`^GSPC` 或 `sp500` 返回论文中的默认 GTS 参数。

```r
gts_characteristic_function(t, params)
```

计算 GTS 特征函数。

```r
build_gts_grid(params, x_grid, t_max, n_t)
```

使用特征函数数值反演构造近似 PDF/CDF 网格。该接口是教学型近似，不是完整 FRFT 实现。

```r
simulate_gts(n, params, grid, seed)
```

基于离散 CDF 网格进行逆变换抽样。

## Risk And Simulation

```r
calculate_var_cvar(returns, probs)
```

基于损失 `loss = -return` 计算 VaR 和 CVaR。

```r
bootstrap_risk_intervals(returns, probs, b, seed)
```

对收益率重抽样，返回 VaR/CVaR 的 95% Bootstrap 区间。

```r
simulate_portfolio(returns, weights, model, n_sims, horizon, seed)
```

支持三种模型：

- `empirical`：经验收益率重抽样
- `normal`：多元正态模拟
- `gts`：独立 GTS 模拟

```r
permutation_test_returns(x, y, statistic, n_perm, seed)
```

比较两个资产收益率的均值、中位数或方差差异。

## Shiny Contract

Shiny 不直接实现统计逻辑，只调用 `src/R/` 中的函数。这样可以保证：

- 函数可以单独测试。
- 展示逻辑和计算逻辑分离。
- 小组成员可以并行开发。
