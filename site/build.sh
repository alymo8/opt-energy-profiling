#!/usr/bin/env bash
# Assemble the GitHub Pages site: the page itself, the paper PDFs and the
# figures it shows from the final run (run-8). Usage: bash site/build.sh <out_dir>
set -euo pipefail

OUT="${1:-_site}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FIG="${ROOT}/results/e2e_experiments/run-8/opt-run-20260320-002006/reports-new/figures"

rm -rf "${OUT}"
mkdir -p "${OUT}/figures"
cp "${ROOT}/site/index.html" "${ROOT}/site/favicon.svg" "${OUT}/"
cp "${ROOT}/paper/opt-350m-energy-profiling-report.pdf" "${OUT}/paper.pdf"
cp "${ROOT}/paper/opt-350m-energy-profiling-slides.pdf" "${OUT}/slides.pdf"

for f in \
  cross_batch/throughput_steps_per_sec_vs_batch.png \
  cross_batch/energy_per_step_vs_batch.png \
  cross_batch/profileC_phase_times_vs_batch.png \
  cross_batch/profileC_gpu_vs_batch.png \
  batch_16/profileC_resource_timeline.png \
  batch_16/profileC_gpu_idle_windows_timeline.png \
  batch_8/profileC_gpu_idle_windows_timeline.png \
  batch_4/profileC_gpu_idle_windows_timeline.png; do
  cp "${FIG}/${f}" "${OUT}/figures/${f//\//_}"
done
touch "${OUT}/.nojekyll"
