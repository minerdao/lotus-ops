# 自动Pledge脚本使用说明
## 1. 脚本参数修改
可根据pledge方式修改脚本参数，具体个数和时间间隔根据集群情况进行计算设置。
```
pleNum=1 #一次性pledge的个数
tm=3 # 每隔x分钟执行一轮
```
## 2. 启动脚本
启动脚本的命令为：`nohup bash auto_pledge_sector.sh >pledge.log 2>&1 &`
## 3. 集群参数计算方法
- 中小集群设置方法（50个worker进程以下）
中小集群可以采取集中Pledge的方法，即瞬时给每个worker进程pledge 1个任务，确保每个进程都会执行到一个ap，此时`pleNum`的值应该等于p1p2-worker进程的数量，间隔时间需要根据单台封装数据的理论值来进行计算。
比如以FilGuard团队推荐的7542+1T内存+单显卡标准p1p2-worker设备，按照FilGuard团队优化软件的效率3T/台来进行设置：
  ```
  pleNum=2 #每台机器会启动两个worker进程执行任务
  tm=30 # 每隔30分钟执行一轮
  ``` 
  那么每天单台pledge的数量是`1440/30*2=96`，那么该台机器一天的有效存储为：`96*32=3072`，即`3TB`。

- 中大集群设置方法（50个worker进程以上）
中大集群可以采取平滑pledge的方法，即每个x分钟pledge1个任务，FilGuard团队优化软件调度中，在worker机器`myscheduler.json`文件中设置`"AutoPledgeDiff": 1`即为调度平均分配任务模式（每个任务会均匀分配到各个worker机器上）。
同样以FilGuard团队推荐的7542+1T内存+单显卡标准p1p2-worker设备，按照FilGuard团队优化软件的效率3T/台来进行设置：
  ```
  pleNum=1 #每次只会派发一个任务
  tm=15 # 每隔15分钟执行一轮
  ``` 

