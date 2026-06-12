# Contributing

本项目按小组协作方式开发。所有成员应从功能分支提交 Pull Request，再合并到 `main`。

## Branches

- `feature/project-scaffold`
- `feature/data-pipeline`
- `feature/statistical-methods`
- `feature/shiny-app`
- `feature/docs-report`

## Pull Request Checklist

- 文件名和目录名使用英文。
- 代码可以被 `source()` 加载。
- 新增统计函数应包含基础测试。
- README 或 docs 已同步更新。
- 不提交下载得到的 CSV 数据。

## Local Checks

```powershell
& "C:\Program Files\R\R-4.4.2\bin\Rscript.exe" src/scripts/download_data.R
& "C:\Program Files\R\R-4.4.2\bin\Rscript.exe" tests/testthat.R
```
