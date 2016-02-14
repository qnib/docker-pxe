FROM qnib/u-consul

RUN apt-get -qy install dnsmasq wget iptables vim dnsutils
WORKDIR /usr/local/bin/
RUN wget -q --no-check-certificate https://raw.github.com/jpetazzo/pipework/master/pipework
RUN chmod +x pipework

ENV BASEDIR=/tftp \
    ARCH=amd64 \
    DIST=jessie \
    MIRROR=http://ftp.nl.debian.org
ADD ks ${BASEDIR}/ks
WORKDIR ${BASEDIR}/images/debian/$DIST
RUN echo $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/linux
RUN wget -q $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/linux
RUN wget -q $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/initrd.gz
RUN wget -q $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/pxelinux.0
RUN mkdir ${BASEDIR}/pxelinux.cfg

## nginx
RUN apt-get install -y nginx
#ADD etc/nginx/sites-available/default /etc/nginx/sites-available/default

## Mirror
RUN apt-get install -y apt-mirror

RUN apt-get install -y python-pip 
RUN pip install docopt jinja2

### dnsmasq
ADD etc/dnsmasq.conf /etc/dnsmasq.conf
ADD opt/qnib/bin/start_dnsmasq.sh /opt/qnib/bin/start_dnsmasq.sh
ADD etc/supervisord.d/dnsmasq.ini /etc/supervisord.d/
##### Template
ADD templates/ /opt/templates/
ENV HTTP_HOST 192.168.1.2
ENV NFS_HOST 192.168.1.22
RUN mkdir -p ${BASEDIR}/tftp/pxelinux.cfg && \
    /opt/templates/create_j2.py /opt/templates/pxelinux.cfg/default.j2 ${BASEDIR}/tftp/pxelinux.cfg/default
# nginx-config
RUN /opt/templates/create_j2.py /opt/templates/nginx.j2 /etc/nginx/sites-available/default

ADD etc/apt/mirror.list /etc/apt/mirror.list
ADD opt/qnib/bin/check_dnsmasq.py /opt/qnib/bin/check_dnsmasq.py

# Share via volume
VOLUME /tftp
# NFS
#RUN apt-get install -y nfs-kernel-server runit inotify-tools -qq
#EXPOSE 111/udp 2049/tcp

