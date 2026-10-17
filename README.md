# Energy and Resource Profiling of OPT-350m Training

**Project site:** https://alymo8.github.io/opt-energy-profiling/
**Paper (PDF):** [paper/opt-350m-energy-profiling-report.pdf](paper/opt-350m-energy-profiling-report.pdf) · **Slides:** [paper/opt-350m-energy-profiling-slides.pdf](paper/opt-350m-energy-profiling-slides.pdf)

Research at McGill University, by Aly Mohamed.

We profile training of Meta's [OPT-350m](https://huggingface.co/facebook/opt-350m) at batch sizes 4, 8 and 16 on a shared Slurm GPU cluster. For each run we measure wall-clock time, energy and per-step resource use under three instrumentation profiles. Each configuration runs for 300 seconds and is repeated 3 times.

## Key findings

| | Batch 4 | Batch 8 | Batch 16 |
| :--- | ---: | ---: | ---: |
| Samples / s | 16.2 | 21.9 | 25.3 |
| Energy per step (µWh) | 12.0 | 19.3 | 35.3 |
| Optimizer step (ms) | 96.0 | 95.7 | 95.9 |
| Optimizer share of step time | 39% | 26% | 15% |
| Avg. GPU utilization | 83% | ~92% | ~92% |
| Energy-profiling overhead (Profile B) | 1.49% | 1.46% | 1.61% |

- **Measurement is cheap.** Fine-grained per-step profiling adds under 0.1% overhead. The CodeCarbon energy profile adds about 1.5%, well under the 5% budget.
- **The optimizer step is a fixed cost.** AdamW takes 96 ms whatever the batch size. At batch 4 that is 39% of each step, which makes it the main source of GPU underutilization.
- **Larger batches are more energy-efficient.** Samples per joule rise 55% from batch 4 to batch 16. Over a fixed 5-minute window, total energy stays nearly flat.
- **The GPU never reaches 100% utilization.** It peaks around 92%. The paper suggests fused optimizer kernels, gradient checkpointing, and co-scheduling work into the idle windows.

## Repository layout

```
paper/        Final report and presentation slides (PDF)
src/          Training framework: config, OPT/GPT-2 models, synthetic data, trainer, stats collectors
launch.py     CLI entry point
scripts/      Slurm/launch wrappers, experiment runner, aggregation and plotting
analysis/     Stand-alone plotting scripts for per-step CSV logs
config/       Slurm job configuration
results/      Experiment outputs (see results/README.md); run-8 is the run reported in the paper
docs/         Framework documentation (overview, environments, Slurm, programming guide)
site/         Source of the GitHub Pages project site
```

## Measurement profiles

| Profile | `--trainer_stats` | What it records |
| :--- | :--- | :--- |
| A (baseline) | `noop` | End-to-end runtime only |
| B (energy) | `codecarbon` | End-to-end GPU energy via CodeCarbon (offline, 40 gCO₂/kWh, Quebec grid) |
| C (fine-grained) | `composite` (`simple,resource`) | CUDA-synchronized forward/backward/optimizer timings, plus NVML power/energy/utilization/memory and psutil CPU/RAM/I/O per step |

## Reproducing the experiments

Set up the Python environment (see [docs/environments.md](docs/environments.md)):

```bash
pip install -r requirements.txt
python3 launch.py --help
```

Run the full sweep (batch sizes × profiles × 3 repeats, 300 s each), then aggregate:

```bash
python3 scripts/run_opt_experiments.py --repo-root . \
  --output-root ./results/e2e_experiments/run-N \
  --launcher "python3 launch.py" --duration-sec 300 --repeats 3

python3 scripts/aggregate_opt_experiments.py ./results/e2e_experiments/run-N/<opt-run-timestamp>
```

On Slurm, use `--launcher "./scripts/srun.sh"`, or submit the whole pipeline in the background with `RUN_NUM=N sbatch scripts/slurm_opt_pipeline.sbatch` from the repo root. Edit the `#SBATCH` account/partition lines for your cluster first. A single run (batch 8, Profile A) looks like this:

```bash
./scripts/srun.sh --model opt --data opt --trainer simple \
  --learning_rate 1e-06 --seed 1234 \
  --model_configs.opt.hf_name facebook/opt-350m --model_configs.opt.dtype fp32 \
  --data_configs.opt.batch_size 8 --data_configs.opt.seq_len 1024 \
  --data_configs.opt.num_workers 0 --data_configs.opt.max_samples 100000000 \
  --trainer_configs.simple.max_duration_sec 300.0 --trainer_configs.simple.warmup_steps 1 \
  --trainer_stats noop
```

See [docs/overview.md](docs/overview.md) for how the framework works internally, and [docs/ToC.md](docs/ToC.md) for the rest of the documentation.

## Acknowledgements

This builds on the COMP 597 starter code provided by the course staff at McGill University (the auto-discovery CLI, Slurm wrappers and GPT-2 example). Thanks to the course staff and to the classmates who contributed to the shared starter repository.

## Citation

```bibtex
@techreport{mohamed2026optenergy,
  title       = {Energy and Resource Profiling of OPT-350m Training},
  author      = {Mohamed, Aly},
  institution = {McGill University, COMP 597: Sustainability in Systems Design},
  year        = {2026},
  month       = apr,
  url         = {https://alymo8.github.io/opt-energy-profiling/}
}
```
