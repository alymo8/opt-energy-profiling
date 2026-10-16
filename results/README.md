# Results

| Path | What it is |
| :--- | :--- |
| `e2e_experiments/run-8/opt-run-20260320-002006/` | **Final run reported in the paper.** OPT-350m, fp32, seq len 1024, batch sizes 4/8/16 × profiles A/B/C × 3 repeats of 300 s. |
| `e2e_experiments/run-8/.../reports-new/` | Aggregated output of `scripts/aggregate_opt_experiments.py`: `cross_batch_summary.csv`, `overall_summary.json`, `integrity_report.json`, and every figure (`figures/batch_*`, `figures/cross_batch`). `reports/` is an earlier aggregation of the same raw data. |
| `e2e_experiments/run-4/` | Earlier end-to-end sweep (March 8), kept for comparison. |
| `exploratory/` | Single exploratory runs and the exact commands used for them (`run-configs/`). |

Each `batch_<B>/profile_<P>/repeat_<R>/` directory holds that run's raw logs: `run_timing.json`, plus the CodeCarbon CSVs (Profile B) or the per-step `simple`/`resource` CSVs (Profile C). The top-level `manifest.json` records every command that was run.

Absolute cluster paths in the logs were replaced with `<repo>`.
