# CPU核心分配优化版使用说明：

使用官方代码开启SDR时，会默认使用4个CPU核心，在使用7542等主流CPU时，由于只有32核心，故开启sdr进行p1计算时，最多只能跑8个并发，为提升CPU核心利用率及使用SDR跑更多的p1并发，对SDR CPU核心分配进行优化。

优化思路：将官方程序中，SDR使用4个CPU核心改为使用2个CPU核心，同时使用环境变量`ENV_CPU_CORE_BEGIN_NUM`、`ENV_CPU_CORE_END_NUM`来绑定进程CPU核心组。

使用方法：lotus-worker运行前添加`FIL_PROOFS_USE_MULTICORE_SDR`、`FIL_PROOFS_MULTICORE_SDR_PRODUCERS`、`ENV_CPU_CORE_BEGIN_NUM`、`ENV_CPU_CORE_END_NUM`环境变量。以CPU AMD7542为例，`FIL_PROOFS_USE_MULTICORE_SDR`设置值为1，`FIL_PROOFS_MULTICORE_SDR_PRODUCERS`设置值为1，`ENV_CPU_CORE_BEGIN_NUM`、`ENV_CPU_CORE_END_NUM`取值范围为0-16，内存足够时可以支持16并发开启sdr。

eg：若需要启动两个worker进程进行封装，可对进程分别指定CPU核心组范围，确保两个进程CPU核心分配不会冲突，7302等l3CPU核心设置`FIL_PROOFS_MULTICORE_SDR_PRODUCERS`值为2.

