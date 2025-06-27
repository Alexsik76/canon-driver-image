#!/bin/bash
set -e

# Функція для коректної зупинки
shutdown() {
    echo "Shutting down CUPS and ccpd..."
    /etc/init.d/ccpd stop
    kill -TERM $(cat /var/run/cups/cupsd.pid)
    wait
}

echo "Starting udev daemon..."
/usr/lib/systemd/systemd-udevd &

echo "Starting Canon ccpd daemon..."
/etc/init.d/ccpd start

echo "Starting CUPS daemon..."
/usr/sbin/cupsd -f &

CUPS_PID=$!
trap "shutdown" SIGTERM SIGINT

# Створюємо чергу друку один раз (якщо її немає)
if ! lpstat -p LBP6000 &>/dev/null; then
  echo "Printer queue 'LBP6000' not found. Creating..."
  lpadmin -p LBP6000 -m CNCUPSLBP6018CAPTK.ppd -v ccp://localhost:59687 -E
fi

echo "Services started. Waiting for printer connection via udev..."
wait ${CUPS_PID}