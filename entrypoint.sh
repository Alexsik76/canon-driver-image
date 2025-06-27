#!/bin/bash
set -e

# Ця функція коректно зупиняє служби при отриманні сигналу від Docker
shutdown() {
    echo "Shutting down CUPS and ccpd..."
    /etc/init.d/ccpd stop
    kill -TERM $(cat /var/run/cups/cupsd.pid)
    wait
}

echo "Starting Canon ccpd daemon..."
/etc/init.d/ccpd start

echo "Starting CUPS daemon..."
/usr/sbin/cupsd -f &

# Отримуємо PID щойно запущеного у фоні CUPS
CUPS_PID=$!

# Перехоплюємо сигнали зупинки від Docker (SIGTERM) і викликаємо нашу функцію
trap "shutdown" SIGTERM SIGINT

# Чекаємо, доки процес CUPS не завершиться
wait ${CUPS_PID}