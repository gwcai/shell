#!/bin/bash

# springcloud - this script starts and stops the spring cloud service
#
# chkconfig:   - 86 16
# description:  include the spring cloud base service and other self define service.
#               please set file format to unix,so that linux os can recognize this shell.
#               :set ff=unix
# processname: gdp_cloud

##包列表
JAR_PATH=/home/springcloud
packages={}
packages[0]=$JAR_PATH/discovery-0.1.2-SNAPSHOT.jar
packages[1]=$JAR_PATH/config-0.1.2-SNAPSHOT.jar
packages[2]=$JAR_PATH/auth-0.1.2-SNAPSHOT.jar
packages[3]=$JAR_PATH/gateway-0.1.2-SNAPSHOT.jar
packages[4]=$JAR_PATH/user-service-0.1.2-SNAPSHOT.jar
packages[5]=$JAR_PATH/code-service-0.1.2-SNAPSHOT.jar

#config-server配置路径
CONFIG_SERVICE_URL="http://127.0.0.1:8761/eureka/apps/config-server"

#获取进程id：参数为jar包名
getPid(){	
    pid=`ps -ef | grep $1 | grep -v grep | awk '{print $2}'`
    echo $pid
}

#发送http请求:参数为url；请求成功返回1，失败返回0
http_ok(){
    code=`curl -I -m 10 -o /dev/null -s $1 -l -w %{http_code}`
    if [ "$code" -eq "200" ]; then
        return 1
    else
        return 0
    fi
}

start_service(){
    pid=`getPid ${packages[$1]}`
    if [ $pid ]; then
        kill -9 $pid
    fi
    
    echo "start ${packages[$1]}";
    if [ ! -d 'logs' ];then
      mkdir logs
    fi
    nohup java -jar ${packages[$1]} $2 >> logs/$1_`date +%Y%m%d`.log &
    check_ok $1
}

stop(){
    j=0
     for j in ${!packages[@]};
     do
        pid=`getPid ${packages[$j]}`
	    i=0
	echo $pid
	    while [ $i -lt ${#pid[@]} ]
	    do
		    if [[ ${pid[$i]} != ''  ]];then
		        kill ${pid[$i]}
		        echo "kill ${pid[$i]},${packages[$j]}"
		    fi
		    let i++
	    done
	done
}

check_status(){
    echo 'check all service status'
    j=0
     for j in ${!packages[@]};
     do
        pid=`getPid ${packages[$j]}`
        if [ {$pid} ]; then
            echo "${packages[$j]} ok. pid=$pid"
        else
            echo "${packages[$j]} not ok."
        fi
     done
}

#检测进程是否启动
check_ok(){
    service=${packages[$1]}
    echo "check $service status"
    while :
     do
        pid=`getPid $service`
        if [ $pid ]; then
            echo "${packages[$j]} ok. pid=$pid"
	    break;
        else
            echo "${packages[$j]} not ok."
	    sleep 1s
        fi
     done
}


start(){
    option=$1
    wait_time=90
    echo $1
    echo $2
    if [[ $option -eq "-t"  ]];then
        wait_time=$2
    fi
    if [ ! $wait_time ]; then
	wait_time=90
    fi

    echo 'start discovery';
    start_service 0

    echo 'start config';
    start_service 1 --spring.profiles.active=native

    echo "wait until $wait_time s to ensure config-service completely started!"
    i=1;
    while [ $i -le $wait_time ]
        do
            sleep 1s
            #发送hht请求判断config是否启动
            http_ok "${CONFIG_SERVICE_URL}"
	    if [ $? -eq "1" ];then
                echo "config-server started ok!time used:$i";
                break;
            fi
            echo -n "."
            let i++
	    if [ $i -eq $wait_time  ];then
		let wait_time+=5
	    fi
            if [ $wait_time -eq "180" ];then
		echo "warning:check config-server timeout!"
                break;
	    fi
         done

     echo 'start other service'
     for j in ${!packages[@]};
     do
	    if [[ $j -ge "2" ]];then
        	start_service $j
	    fi
     done
}

case "$1" in
    start)
        start $2 $3;
	check_status;
        ;;
    stop)
        stop;;
    status)
	check_status;;
    *)
    echo $"Usage: $0 {start|stop|status}"
    exit 2
esac
