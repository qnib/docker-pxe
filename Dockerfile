FROM ubuntu:14.04
MAINTAINER "Christian Kniep <christian@qnib.org>"

RUN echo "2014-10-02.1";apt-get update

# SOURCE: https://github.com/jpetazzo/pxe/blob/master/Dockerfile
ENV ARCH amd64
ENV DIST wheezy
ENV MIRROR http://ftp.nl.debian.org
ENV BASEDIR /tftp

RUN apt-get -q update
RUN apt-get install -y supervisor

RUN apt-get -qy install dnsmasq wget iptables vim dnsutils
WORKDIR /usr/local/bin/
RUN wget -q --no-check-certificate https://raw.github.com/jpetazzo/pipework/master/pipework
RUN chmod +x pipework

WORKDIR ${BASEDIR}
ADD ks ${BASEDIR}/ks
WORKDIR ${BASEDIR}/tftp/images/debian/$DIST
RUN wget -q $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/linux
RUN wget -q $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/initrd.gz
RUN wget -q $MIRROR/debian/dists/$DIST/main/installer-$ARCH/current/images/netboot/debian-installer/$ARCH/pxelinux.0
RUN mkdir ${BASEDIR}/tftp/pxelinux.cfg

## nginx
RUN apt-get install -y nginx
#ADD etc/nginx/sites-available/default /etc/nginx/sites-available/default

## Mirror
RUN apt-get install -y apt-mirror
## pip
RUN apt-get install -qy python-pip python-dev
RUN pip install docopt jinja2 envoy

WORKDIR /opt/consul/
RUN apt-get install -y unzip
RUN wget -q https://dl.bintray.com/mitchellh/consul/0.4.1_linux_amd64.zip
RUN unzip 0.4.1_linux_amd64.zip
RUN wget -q https://dl.bintray.com/mitchellh/consul/0.4.1_web_ui.zip
RUN unzip 0.4.1_web_ui.zip
RUN rm -f 0.4.1_linux_amd64.zip 0.4.1_web_ui.zip


## Config
### consul
ADD etc/supervisor/conf.d/consul.conf /etc/supervisor/conf.d/consul.conf
ADD opt/qnib/bin/start_consul.sh /opt/qnib/bin/start_consul.sh
ADD etc/consul.d/ /etc/consul.d/

### dnsmasq
ADD etc/dnsmasq.conf /etc/dnsmasq.conf
ADD opt/qnib/bin/start_dnsmasq.sh /opt/qnib/bin/start_dnsmasq.sh
ADD etc/supervisor/conf.d/dnsmasq.conf /etc/supervisor/conf.d/dnsmasq.conf
##### Template
ADD templates/ /opt/templates/
ENV HTTP_HOST 192.168.1.2
ENV NFS_HOST 192.168.1.22
RUN /opt/templates/create_j2.py /opt/templates/pxelinux.cfg/default.j2 ${BASEDIR}/tftp/pxelinux.cfg/default
# nginx-config
RUN /opt/templates/create_j2.py /opt/templates/nginx.j2 /etc/nginx/sites-available/default

ADD etc/apt/mirror.list /etc/apt/mirror.list

## Create alias to disable foreground supervisord
RUN echo "alias daemonize_supervisord=\"sed -i -e 's/daemon=.*/daemon=false/' /etc/supervisor/supervisord.conf\"" >> /root/.bashrc
RUN echo "alias start_daemonized=\"daemonize_supervisord; supervisord -c /etc/supervisor/supervisord.conf\"" >> /root/.bashrc
WORKDIR /root/
CMD ["supervisord", "-c", "/etc/supervisor/supervisord.conf"]

ADD opt/qnib/bin/check_dnsmasq.py /opt/qnib/bin/check_dnsmasq.py
