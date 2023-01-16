# Largely inspired by the instructions here:
# https://github.com/LibriVox/librivox-ansible/blob/master/doc/localdev.md
#
# WARNING: I've used more recent versions of everything because installing old
# stuff was really hard and I'm not very smart, so your mileage may vary.

FROM ubuntu:jammy

RUN echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/01-disable-ipv6.conf

# Most of these aren't strictly necessary, but they speed
# up Dockerfile dev by allowing us to cache the results as
# layers
RUN apt-get update && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install git gcc make perl ansible gnupg python3-apt -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install cron -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git apache2 mariadb-server \
    php8.1-fpm php8.1-mysql php8.1-curl php8.1-memcache php8.1-memcached php8.1-intl php8.1-mbstring php8.1-xml php8.1-zip php8.1-apcu \
    python3-certbot-apache python3-mysqldb \
    sphinxsearch mp3gain unzip memcached imagemagick
RUN DEBIAN_FRONTEND=noninteractive apt-get install openssh-server -y

ADD librivox-ansible /librivox-ansible
WORKDIR /librivox-ansible
RUN service mariadb start && ansible-playbook librivox.yaml \
    --limit localdev \
    --inventory inventory.yaml \
    --verbose \
    --connection=local

# TODO load the catalog database
# https://github.com/LibriVox/librivox-ansible/blob/master/doc/localdev.md#initialize-the-catalog-database

ENTRYPOINT service apache2 restart && \
    service php8.1-fpm restart && \
    service sphinxsearch restart && \
    service mariadb restart && \
    bash
