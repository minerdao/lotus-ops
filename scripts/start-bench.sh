export RUST_LOG=debug
export FIL_PROOFS_PARAMETER_CACHE=/home/fil/disk_md0/proof_params/v28
export FIL_PROOFS_MAXIMIZE_CACHING=1
export FIL_PROOFS_USE_GPU_COLUMN_BUILDER=1
export FIL_PROOFS_USE_GPU_TREE_BUILDER=1
export FIL_PROOFS_USE_MULTICORE_SDR=1
export FIL_PROOFS_MULTICORE_SDR_PRODUCERS=1
# export ENV_CPU_CORE_BEGIN_NUM=0
# export ENV_CPU_CORE_END_NUM=8

lotus-bench sealing --sector-size 32GiB --skip-unseal --num-sectors=1 --parallel=1 --storage-dir /home/fil/disk_md0/bench --skip-commit2 true --skip-unseal true 2>&1 | tee /home/fil/logs/bench.log
