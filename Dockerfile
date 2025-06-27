# Використовуємо стабільну, довготривало підтримувану базу Ubuntu 20.04
FROM ubuntu:20.04

# Встановлюємо мітку та опис
LABEL maintainer="alexsik76"
LABEL description="Ubuntu 20.04 with Canon CAPT v2.71 driver (LBP6000) and CUPS."

# Встановлюємо змінну, щоб уникнути інтерактивних запитів під час інсталяції
ENV DEBIAN_FRONTEND=noninteractive

# Вмикаємо 32-бітну архітектуру та встановлюємо всі необхідні пакети
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    cups \
    libc6:i386 \
    libstdc++6:i386 \
    libgcc-s1:i386 \
    libpopt0:i386 \
    libxml2:i386 && \
    rm -rf /var/lib/apt/lists/*

# Копіюємо наш власний, гарантовано робочий конфігураційний файл
COPY cupsd.conf /etc/cups/

# Створюємо користувача-адміністратора та встановлюємо йому пароль
RUN groupadd -f -r lpadmin && \
    useradd -m -r -G lpadmin admin && \
    echo "admin:admin" | chpasswd

# Копіюємо .deb файли драйверів
COPY driver-files/ /tmp/driver-files/

# Встановлюємо драйвери. || true в кінці, щоб ігнорувати можливі некритичні помилки
RUN dpkg -i /tmp/driver-files/*.deb || true && \
    # Автоматично виправляємо будь-які проблеми з залежностями, які могли виникнути
    apt-get -fy install && \
    rm -rf /tmp/driver-files

# Відкриваємо порт CUPS
EXPOSE 631

# Запускаємо CUPS у режимі "не-демона", щоб він був головним процесом контейнера
CMD ["/usr/sbin/cupsd", "-f"]