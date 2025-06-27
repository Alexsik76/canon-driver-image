#!/bin/bash
set -e

# Видаляємо старий PID файл CUPS, якщо він залишився
rm -f /var/run/cups/cupsd.pid

# Запускаємо CUPS та ccpd
echo "Starting CUPS daemon..."
/usr/sbin/cupsd -f &
CUPS_PID=$!

echo "Starting Canon ccpd daemon..."
/etc/init.d/ccpd start

echo "Waiting for services and printer device..."
sleep 3

# Цикл, що чекає на створення /dev/usb/lp0
while [ ! -e /dev/usb/lp0 ]; do
  echo "Waiting for device /dev/usb/lp0 to appear..."
  sleep 5
done

echo "Device /dev/usb/lp0 found!"

# Крок 4 з вашої інструкції: автоматична реєстрація
echo "Registering printer LBP6000..."
lpadmin -p LBP6000 -m CNCUPSLBP6018CAPTK.ppd -v ccp://localhost:59687 -E
ccpdadmin -p LBP6000 -o /dev/usb/lp0

echo "Printer is fully configured. Container is running."

# Чекаємо на завершення головного процесу CUPS
wait $CUPS_PID