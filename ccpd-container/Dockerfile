# ccpd-container/Dockerfile
FROM fedora:40

# Встановлення tini (легкого ініціалізатора)
# tiny потрібен для коректної обробки сигналів PID 1 у контейнері
RUN dnf update -y && \
    dnf install -y tini && \
    dnf clean all

# Копіювання RPM файлів драйвера Canon
COPY cndrvcups-common-*.x86_64.rpm /tmp/
COPY cndrvcups-capt-*.x86_64.rpm /tmp/

# Встановлення драйверів Canon
# Використання --nogpgcheck, оскільки це локальні пакети
RUN dnf install -y /tmp/cndrvcups-common-*.x86_64.rpm /tmp/cndrvcups-capt-*.x86_64.rpm && \
    dnf clean all && \
    rm -f /tmp/cndrvcups-common-*.x86_64.rpm /tmp/cndrvcups-capt-*.x86_64.rpm

# Копіювання скрипта ccpd запуску
# Переносимо логіку запуску ccpd, яка раніше була в systemd service
COPY ccpd-entrypoint.sh /usr/local/bin/ccpd-entrypoint.sh
RUN chmod +x /usr/local/bin/ccpd-entrypoint.sh

# Використання tini як ENTRYPOINT
ENTRYPOINT ["/usr/bin/tini", "--"]
# Запуск нашого скрипта
CMD ["/usr/local/bin/ccpd-entrypoint.sh"]