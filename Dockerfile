FROM ubuntu:jammy
ARG USERNAME=admin PASSWORD=pr1nt
ENV \
    PRINTER_ID=Paperless_Printer \
    PRINTER_NAME=Paperless\ Printer \
    HOSTNAME=127.0.0.1 \
    OUTPUT_SUBPATH=vprint \
    OUTPUT_USERNAME=$USERNAME

# Dependenicies
RUN apt-get update
RUN apt-get install -y --no-install-recommends cups printer-driver-cups-pdf gettext php nano

# Cups config/setup
RUN useradd -G lp,lpadmin -s /bin/bash -p "$(openssl passwd -1 $PASSWORD)" $USERNAME

# discoverability
RUN apt-get install -y avahi-daemon
RUN sed -i 's/.*enable\-dbus=.*/enable\-dbus\=no/' /etc/avahi/avahi-daemon.conf

git clone https://github.com/alexivkin/CUPS-PDF-to-PDF.git
cd CUPS-PDF-to-PDF
grep -rl '.setpdfwrite' * | xargs sed -i 's/.setpdfwrite//g'
gcc -O9 -s -o cups-pdf cups-pdf.c -lcups
sudo cp /usr/lib/cups/backend/cups-pdf /usr/lib/cups/backend/cups-pdf.bak
sudo cp cups-pdf /usr/lib/cups/backend/

# Copy configs
WORKDIR /opt/vp
COPY . .

CMD ["./entrypoint.sh"]
