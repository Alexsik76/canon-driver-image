FROM fedora:40

LABEL maintainer="alexsik76"
LABEL description="Fedora 40 with Canon CAPT v2.71 driver (LBP6000) and CUPS."

RUN dnf update -y && \
    dnf install -y \
    cups \
    glibc.i686 \
    libstdc++.i686 \
    libgcc.i686 \
    popt.i686 \
    libxml2.i686 \
    psmisc && \
    dnf clean all

COPY cupsd.conf /etc/cups/


COPY driver-files/ /tmp/driver-files/

RUN dnf localinstall -y /tmp/driver-files/*.rpm && \
    rm -rf /tmp/driver-files
COPY entrypoint.sh /

RUN chmod +x /entrypoint.sh
EXPOSE 631

CMD ["/usr/sbin/cupsd", "-f"]
ENTRYPOINT ["/entrypoint.sh"]