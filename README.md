# shell
工作中常用到的shell归档

### spring cloud相关脚本
>位于springcloud目录下，主要用于基于微服务应用的启动、停止、查看状态等操作。  
也可将脚本添加到开机自启动。

用法如下：  
首先将各个微服务包加到脚本中的packages里面，然后指向下列命令：
```bash
./springcloud.sh start ##启动服务
./springcloud.sh stop ##结束所有服务
./springcloud.sh status ##查看各个服务状态
```
### 应用程序安装相关脚本 
> 位于setup目录
