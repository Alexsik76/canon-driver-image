FROM fedora:40

LABEL maintainer="alexsik76"
LABEL description="Fedora 40 with Canon CAPT v2.71 driver (LBP6000) and CUPS."


RUN dnf update -y && \
    dnf install -y \
    cups \
    ghostscript \
    libjpeg-turbo.i686 \
    libgcrypt.i686 \
    gtk3.i686 \
    jbigkit-libs.i686 \
    glibc.i686 \
    libstdc++.i686 \
    popt.i686 \
    psmisc && \
    dnf clean all

COPY driver-files/ /tmp/driver-files/
RUN dnf localinstall -y /tmp/driver-files/*.rpm && \
    rm -rf /tmp/driver-files

COPY cupsd.conf /etc/cups/
COPY 99-canon.rules /etc/udev/rules.d/
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

EXPOSE 631
ENTRYPOINT ["/entrypoint.sh"]