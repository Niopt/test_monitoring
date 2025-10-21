#!/bin/bash

PROCESS_NAME="test"
MONITOR_URL="https://test.com/monitoring/test/api"
LOGFILE="/var/log/test.log"
DIR="/tmp/pid"
PIDFILE="/tmp/pid/${PROCESS_NAME}.pid"

# Проверяем, есть ли папка
if [ ! -d "$DIR" ]; then
  mkdir -p "$DIR"
fi
# Проверяем, есть ли файл 
if [ ! -f "$LOGFILE" ]; then
  touch "$LOGFILE"
fi

# Проверяем, запущен ли процесс 
PID=$(pgrep -x "$PROCESS_NAME")

# Если процесса нет — просто выходим и записываем это в логи
[ -z "$PID" ] && echo "$(date '+%F %T') Процесс не запущен: $PROCESS_NAME" >> "$LOGFILE" && exit 0

# Проверяем, не поменялся ли PID (т.е. процесс перезапускался)
if [ -f "$PIDFILE" ]; then
    OLD_PID=$(cat "$PIDFILE")
    if [ "$OLD_PID" != "$PID" ]; then
        echo "$(date '+%F %T') Процесс $PROCESS_NAME перезапущен (старый PID=$OLD_PID, новый PID=$PID)" >> "$LOGFILE"
    fi
fi
# Записываем pid
echo "$PID" > "$PIDFILE" 

# Проверяем доступность сервера мониторинга
curl -fsS --max-time 10 "$MONITOR_URL" > /dev/null
if [ $? -ne 0 ]; then
    echo "$(date '+%F %T') Сервер мониторинга недоступен: $MONITOR_URL" >> "$LOGFILE"
fi