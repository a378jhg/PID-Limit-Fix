#!/system/bin/sh
MODDIR=${0%/*}
LOG="/data/local/tmp/pid_limit.log"
BIN="$MODDIR/bin/pid_wrap"

# 等系统完全启动
until [ "$(getprop sys.boot_completed)" = "1" ]; do
  sleep 2
done
sleep 5

# 开机完成后再保底压一次
if [ -x "$BIN" ]; then
    "$BIN"
    echo "$(date): [开机完成] 压底重置。当前 PID 基准: $(cat /proc/sys/kernel/ns_last_pid)" >> $LOG
fi

# 继续死守 5000 红线
while true; do
    CURRENT_PID=$(cat /proc/sys/kernel/ns_last_pid 2>/dev/null)
    case "$CURRENT_PID" in ''|*[!0-9]*) CURRENT_PID=0 ;; esac

    if [ "$CURRENT_PID" -gt 5000 ]; then
        "$BIN"
        NEW_PID=$(cat /proc/sys/kernel/ns_last_pid 2>/dev/null)
        echo "$(date): [监控] 拦截超限！原 PID: $CURRENT_PID -> 重置为: $NEW_PID" >> $LOG
        sleep 2
    fi
    sleep 3
done
