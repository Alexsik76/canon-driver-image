# cups-container/Dockerfile
FROM fedora:40

# Install CUPS and necessary dependencies
RUN dnf update -y && \
    dnf install -y cups ghostscript libjpeg-turbo.i686 libgcrypt.i686 gtk3.i686 jbigkit-libs.i686 glibc.i686 libstdc++.i686 popt.i686 && \
    dnf clean all

# Configuration of CUPS for remote access
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

# Create directory for Canon PPD files
RUN mkdir -p /usr/share/cups/model/canon

# Important: If CNCUPSLBP6018CAPTK.ppd is NOT installed by a package in this image,
# you must copy it here from your host.
# Assuming you have it in cups-container directory, then:
COPY CNCUPSLBP6018CAPTK.ppd /usr/share/cups/model/canon/

# Copy the CUPS entrypoint script
COPY cups-entrypoint.sh /usr/local/bin/cups-entrypoint.sh
RUN chmod +x /usr/local/bin/cups-entrypoint.sh

# Expose the CUPS port
EXPOSE 631

# Set the entrypoint script to run when the container starts
CMD ["/usr/local/bin/cups-entrypoint.sh"]