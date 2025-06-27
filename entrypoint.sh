#!/bin/bash

# Видаляємо старий PID файл CUPS, якщо він залишився від попереднього збою
rm -f /var/run/cups/cupsd.pid

# 1. Запускаємо службу CUPS у фоновому режимі
echo "Starting CUPS daemon in background..."
/usr/sbin/cupsd -f &

# 2. Запускаємо службу драйвера Canon
echo "Starting Canon ccpd daemon..."
/etc/init.d/ccpd start

# 3. Даємо службам секунду на ініціалізацію
echo "Waiting for services to initialize..."
sleep 3

# 4. Створюємо чергу друку в CUPS (тепер cupsd точно працює)
echo "Registering printer queue with CUPS..."
lpadmin -p LBP6000 -m CNCUPSLBP6018CAPTK.ppd -v ccp://localhost:59687 -E

# 5. Реєструємо фізичний пристрій в драйвері
echo "Registering physical device with ccpd..."
# Шлях до пристрою береться зі змінної, яку ми передаємо в контейнер
ccpdadmin -p LBP6000 -o ${DEVICE_PATH}

echo "Setup complete. Tailing CUPS error log for monitoring."
echo "You can now send print jobs."
# Залишаємо контейнер працювати і виводимо логи CUPS для спостереження
tail -f /var/log/cups/error_log