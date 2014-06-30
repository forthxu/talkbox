#!/bin/bash
# echo "please input port:" 
# read PORT

#skynet目录
SKYNET_PATH="./skynet/"

#运行脚本
run()
{
	#检查启动程序
	if [ ! -x "${2}" ]; then
		echo "你妹啊，启动程序没有,${2} "
		exit
	fi
	#关闭程序
	if [ -a "${TMP_PATH}kill_${1}.sh" ]; then
		echo "关闭程序："
		sh ${TMP_PATH}kill_${1}.sh
	fi
	#设置日志存储
	DATA_DAY=`date +%Y-%m-%d`
	DATA_SECOND=`date +%Y-%m-%d-%H-%M-%S`
	LOG_NAME="${LOG_PATH}${1}_${DATA_DAY}.log"
	BACKUP_LOG_NAME="${LOG_PATH}${1}_${DATA_SECOND}_old.log"
	#备份日志
	if [ -a "${LOG_NAME}" ]; then
		# mv ${LOG_NAME} ${BACKUP_LOG_NAME}
		rm -rf ${LOG_NAME}
	fi
	#启动
	nohup ${2} ${3} >> ${LOG_NAME} 2>&1 &
	# (${2} ${3} &)
	#生成关闭的程序
	echo "#!/bin/bash" > ${TMP_PATH}kill_${1}.sh
	echo "echo 'run: ${2} ${3} pid: $!'" >> ${TMP_PATH}kill_${1}.sh	
	echo "kill -9 $!" >> ${TMP_PATH}kill_${1}.sh
	chmod 777 ${TMP_PATH}kill_${1}.sh
	# sleep 1
	#显示运行的程序
	echo "运行程序："
	# echo "nohup ${2} ${3} >> ${LOG_NAME} 2>&1 &"
	echo "run:$2 $3  pid:$!  log:${LOG_NAME} "
	#打印启动错误
	sleep 3
	if [ -s "${LOG_NAME}" ]; then
		echo "启动日志："
		cat ${LOG_NAME}
		# exit
	fi
	sleep 1
}

echo "  >>---------- 开始 ----------"
echo "  >>---------- 处理protocbuf ----------"

# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
cd ./3rd/pbc/ && make && cd ./binding/lua/ && make && cd ../../../../ && cp -f ./3rd/pbc/binding/lua/protobuf.lua ./skynet/lualib/ && cp -f ./3rd/pbc/binding/lua/protobuf.so ./skynet/luaclib/

protoc -o ./res/talkbox.pb ./res/talkbox.proto

echo "  >>---------- 处理协议 ----------"
cd ./3rd/p/ && gcc -g -O2 -Wall -I../../skynet/3rd/lua   -fPIC --shared ./lua-p.c -o ./p.so && cd ../../ && cp -f ./3rd/p/p.so ./skynet/luaclib/

echo "  >>---------- 进入skynet目录 ----------"
echo ""
cd ${SKYNET_PATH};
#日志目录
LOG_PATH="../log/"
if [ ! -x "$LOG_PATH" ]; then
	mkdir "$LOG_PATH"
fi

#tmp目录
TMP_PATH="../tmp/"
if [ ! -x "$TMP_PATH" ]; then
	mkdir "$TMP_PATH"
fi
echo ""
echo "  >>---------- 编译 ----------"
echo ""
make linux;
echo ""
echo "  >>---------- 执行 ---------"
echo ""
run a ./skynet ../configs/talkbox.cfg
echo ""
echo "  >>---------- 结束 ----------"
