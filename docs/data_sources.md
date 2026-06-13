# Data Sources

## Assets

本项目默认分析两个资产：

| Asset | Symbol | Source |
| --- | --- | --- |
| Bitcoin | `BTC-USD` | Yahoo Finance Chart API |
| S&P 500 Index | `^GSPC` | Yahoo Finance Chart API |

默认时间范围：

```text
2021-06-12 to 2026-06-12
```

## Download Method

数据脚本：

```powershell
& "C:\Program Files\R\R-4.4.2\bin\Rscript.exe" src/scripts/download_data.R
```

脚本会访问类似以下接口：

```text
https://query1.finance.yahoo.com/v8/finance/chart/BTC-USD
https://query1.finance.yahoo.com/v8/finance/chart/%5EGSPC
```

输出文件：

- `data/raw/btc_usd_prices.csv`
- `data/raw/gspc_prices.csv`
- `data/processed/prices.csv`
- `data/processed/returns.csv`

## Fields

价格数据字段：

- `date`：交易日期
- `symbol`：资产代码
- `open`：开盘价
- `high`：最高价
- `low`：最低价
- `close`：收盘价
- `adjusted`：调整后收盘价，如果 API 返回
- `volume`：成交量

收益率字段：

- `log_return`：百分比日对数收益率
- `simple_return`：百分比简单收益率

## Paper Consistency

参考论文中 Bitcoin 和 Ethereum 数据来自 CoinMarketCap，S&P 500 与 SPY ETF 数据来自 Yahoo Finance。为了提高课程项目的可复现性，本项目统一使用 Yahoo Finance Chart API 自动下载 Bitcoin 与 S&P 500 数据，并在论文笔记中说明该差异。
