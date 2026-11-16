#!/system/bin/sh
MODDIR=${0%/*}
LOG="/data/local/tmp/pid_limit.log"
BIN="$MODDIR/bin/pid_wrap"

# 等待系统完全启动
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 2
done
sleep 5

# 检查二进制文件
if [ ! -x "$BIN" ]; then
    echo "$(date): 错误 - 找不到可执行的 pid_wrap 文件！" >> $LOG
    exit 1
fi

# 开机先无脑执行一次，直接压制（不管它现在是多少）
"$BIN"
echo "$(date): 开机强制重置完成。当前 PID 状态已接管。" >> $LOG

# 进入无感监控循环，死守 5000 红线
while true; do
    # 读取内核分配的最后一个 PID 号
    CURRENT_PID=$(cat /proc/sys/kernel/ns_last_pid 2>/dev/null)
    
    # 防止读取失败报错
    case "$CURRENT_PID" in ''|*[!0-9]*) CURRENT_PID=0 ;; esac

    # 只要超过 5000，瞬间拨回
    if [ "$CURRENT_PID" -gt 5000 ]; then
        "$BIN"
        NEW_PID=$(cat /proc/sys/kernel/ns_last_pid 2>/dev/null)
        echo "$(date): 拦截超限！原 PID: $CURRENT_PID -> 重置为: $NEW_PID" >> $LOG
        sleep 2 # 重置后稍微等一下，防止瞬间又触发
    fi
    
    # 每 3 秒静默检查一次，你打游戏、切应用完全感觉不到
    sleep 3
done
