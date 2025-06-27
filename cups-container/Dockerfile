FROM fedora:40

# Встановлення CUPS та необхідних залежностей
RUN dnf update -y && \
    dnf install -y cups ghostscript libjpeg-turbo.i686 libgcrypt.i686 gtk3.i686 jbigkit-libs.i686 glibc.i686 libstdc++.i686 popt.i686 && \
    dnf clean all

# Конфігурація CUPS
# Дозволити віддалений доступ (для зв'язку з ccpd та з мережі)
RUN sed -i 's/Listen localhost:631/Port 631/' /etc/cups/cupsd.conf && \
    echo 'Listen 0.0.0.0:631' >> /etc/cups/cupsd.conf && \
    echo '<Location />' >> /etc/cups/cupsd.conf && \
    echo '  Order allow,deny' >> /etc/cups/cupsd.conf && \
    echo '  Allow all' >> /etc/cups/cupsd.conf && \
    echo '</Location>' >> /etc/cups/cupsd.conf && \
    echo '<Location /admin>' >> /etc/cups/cupsd.conf && \
    echo '  Order allow,deny' >> /etc/cups/cupsd.conf && \
    echo '  Allow all' >> /etc/cups/cupsd.conf && \
    echo '</Location>' >> /etc/cups/cupsd.conf && \
    echo '<Location /admin/conf>' >> /etc/cups/cupsd.conf && \
    echo '  AuthType Default' >> /etc/cups/cupsd.conf && \
    echo '  Require user @SYSTEM' >> /etc/cups/cupsd.conf && \
    echo '  Order allow,deny' >> /etc/cups/cupsd.conf && \
    echo '  Allow all' >> /etc/cups/cupsd.conf && \
    echo '</Location>' >> /etc/cups/cupsd.conf

# Створення символічного посилання для PPD файлу (його буде додано окремо)
# Це шлях, де CUPS шукатиме PPD файли
RUN mkdir -p /usr/share/cups/model/canon
RUN lpadmin -p LBP6000 -m CNCUPSLBP6018CAPTK.ppd -v ccp://ccpd:59687 -E
# Відкриття порту CUPS
EXPOSE 631

# Виконавчий файл CUPS
CMD ["/usr/sbin/cupsd", "-f"]