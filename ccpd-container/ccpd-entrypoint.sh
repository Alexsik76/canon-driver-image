#!/bin/bash

# Чекаємо, поки CUPS буде доступний
echo "Waiting for CUPS to be available..."
until nc -z cups 631; do
  echo "CUPS not yet available, waiting..."
  sleep 2
done
echo "CUPS is available."

# Реєстрація принтера в CUPS та CCPD
# ccpdadmin -p LBP6000 -o /dev/usb/lp0
# Примітка: команда lpadmin буде виконана CUPS-контейнером, тут тільки для ccpdadmin
# Для CUPS ми просто копіюємо PPD файл, а він автоматично його підхопить
# Якщо CUPS-контейнер не бачить принтер автоматично, можливо, доведеться
# вручну додати його через веб-інтерфейс CUPS (http://<your_host_ip>:631/admin)
# і обрати PPD файл, або налаштувати lpadmin в CUPS-контейнері.
# Однак, зазвичай, якщо PPD файл є, CUPS його знайде.

# Для CCPD:
# Тут ми повинні переконатися, що /dev/usb/lp0 існує
# (це буде прокинуто з хоста)
if [ ! -c /dev/usb/lp0 ]; then
  echo "Error: /dev/usb/lp0 not found. Make sure USB device is correctly mounted."
  exit 1
fi

# Намагаємося зареєструвати принтер в CCPD.
# Це має бути зроблено після того, як CUPS повністю працює
# і принтер доступний через /dev/usb/lp0.
# Важливо: ccpdadmin може вимагати, щоб ccpd був запущений,
# а ccpd не запускається, поки принтер не зареєстрований.
# Може знадобитися перезапуск ccpd після реєстрації.
# Простіший підхід - запускати ccpd і сподіватися, що він підхопить.

# Запустити демон ccpd
# OLD_CCPD_SCRIPT=/etc/rc.d/init.d/ccpd
# Замість старого скрипта, запускаємо ccpd безпосередньо.
# ccpsd - це фактичний демон CAPT
echo "Starting ccpd (Canon CAPT Printer Daemon)..."
/usr/sbin/ccpd > /var/log/ccpd.log 2>&1 &
CCPD_PID=$!
echo "ccpd started with PID $CCPD_PID"

# Пробуємо зареєструвати принтер в CCPD після запуску демона
echo "Registering printer LBP6000 with CCPD..."
ccpdadmin -p LBP6000 -o /dev/usb/lp0
if [ $? -eq 0 ]; then
    echo "Printer LBP6000 registered successfully with CCPD."
else
    echo "Failed to register printer LBP6000 with CCPD. Check logs."
fi

# Тримаємо контейнер запущеним, щоб ccpd працював
wait $CCPD_PID