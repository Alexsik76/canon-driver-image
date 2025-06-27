#!/bin/bash
set -e

# Ця функція буде викликана, коли Docker зупиняє контейнер
shutdown() {
    echo "Shutting down..."
    # Намагаємось коректно дереєструвати принтер
    ccpdadmin -x LBP6000 &>/dev/null || true
    # Зупиняємо демона ccpd
    /etc/init.d/ccpd stop
    # Зупиняємо CUPS
    kill -TERM $CUPS_PID
    wait $CUPS_PID
}

# Видаляємо старий PID файл CUPS, якщо він залишився від попереднього збою
rm -f /var/run/cups/cupsd.pid

# Запускаємо обидві служби У ФОНОВОМУ РЕЖИМІ і запам'ятовуємо їхні PID
echo "Starting CUPS daemon in background..."
/usr/sbin/cupsd -f &
CUPS_PID=$!

echo "Starting Canon ccpd daemon..."
/etc/init.d/ccpd start

# Налаштовуємо перехоплення сигналу зупинки від Docker
trap shutdown SIGTERM SIGINT

# Даємо службам кілька секунд, щоб стабілізуватися
echo "Waiting for services to initialize..."
sleep 5

# Перевіряємо, чи була передана змінна з шляхом до пристрою. Якщо ні - виходимо з помилкою.
if [ -z "${DEVICE_PATH}" ]; then
    echo "FATAL ERROR: The DEVICE_PATH environment variable is not set."
    echo "Please configure it in your Portainer stack editor under 'Environment variables'."
    exit 1
fi

# Створюємо чергу друку в CUPS, якщо її немає
if ! lpstat -p LBP6000 &>/dev/null; then
  echo "CUPS queue 'LBP6000' not found. Creating..."
  lpadmin -p LBP6000 -m CNCUPSLBP6018CAPTK.ppd -v ccp://localhost:59687 -E
fi

# Реєструємо фізичний пристрій в драйвері
echo "Registering physical device ${DEVICE_PATH} with ccpd..."
ccpdadmin -p LBP6000 -o "${DEVICE_PATH}"

echo "Printer is fully configured and ready."
echo "Container is running. Tailing logs is no longer needed to keep it alive."

# Головний цикл роботи контейнера. Він просто чекає на завершення процесу CUPS.
# Це надійний спосіб тримати контейнер "живим".
wait $CUPS_PID