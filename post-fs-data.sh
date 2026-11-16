#!/system/bin/sh
MODDIR=${0%/*}
LOG="/data/local/tmp/pid_limit.log"
BIN="$MODDIR/bin/pid_wrap"

# 在 zygote 启动前无脑重置
if [ -x "$BIN" ]; then
    "$BIN"
    echo "$(date): [极早期] 系统刚挂载完，PID 已强制归零！(此时 zygote 还没启动)" >> $LOG
fi
