FROM python:2.7
MAINTAINER jasl8r@alum.wpi.edu

ENV COBBLER_VERSION=2.8.0 \
    DOCKERIZE_VERSION=0.3.0

WORKDIR /cobbler

RUN curl -LO https://github.com/jwilder/dockerize/releases/download/v${DOCKERIZE_VERSION}/dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz \
 && tar -C /usr/local/bin -xzvf dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz \
 && rm dockerize-linux-amd64-v${DOCKERIZE_VERSION}.tar.gz

RUN pip install docker pyyaml pycurl cheetah netaddr simplejson urlgrabber

COPY docker.patch /cobbler/

RUN curl -LO https://github.com/cobbler/cobbler/archive/v${COBBLER_VERSION}.tar.gz \
 && tar xvzf v${COBBLER_VERSION}.tar.gz \
 && cd cobbler-${COBBLER_VERSION} \
 && patch -p1 < /cobbler/docker.patch \
 && make install \
 && cd - \
 && mkdir -p /srv/tftp \
 && touch /etc/cobbler/dnsmasq.conf \
 && rm -rf cobbler-${COBBLER_VERSION} v${COBBLER_VERSION}.tar.gz

COPY sync_post_manage_docker.py /usr/local/lib/python2.7/site-packages/cobbler/modules/
COPY dnsmasq.tmpl modules.conf.tmpl settings.tmpl /cobbler/

VOLUME /etc/cobbler
VOLUME /srv/tftp
VOLUME /var/lib/cobbler
VOLUME /var/log/cobbler

EXPOSE 80

CMD ["dockerize", \
     "-template", "/cobbler/modules.conf.tmpl:/etc/cobbler/modules.conf", \
     "-template", "/cobbler/settings.tmpl:/etc/cobbler/settings", \
     "-template", "/cobbler/dnsmasq.tmpl:/etc/cobbler/dnsmasq.template", \
     "-stdout", "/var/log/cobbler/cobbler.log", \
     "cobblerd", "-F"]
