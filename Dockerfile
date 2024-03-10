FROM ubuntu:jammy

# Disables IPV6 because the README said to?
RUN echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/01-disable-ipv6.conf

# The Ansible playbooks will install their own dependencies, but preinstalling
# the dependencies means that, if the playbook step fails, then we don't need to
# redownload everything because the layer will be cached.
RUN apt-get update && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git gcc make perl ansible gnupg python3-apt \
    cron git apache2 mariadb-server \
    php8.1-fpm php8.1-mysql php8.1-curl php8.1-memcache php8.1-memcached php8.1-intl php8.1-mbstring php8.1-xml php8.1-zip php8.1-apcu php8.1-gd php8.1-imagick\
    python3-certbot-apache python3-mysqldb \
    sphinxsearch mp3gain unzip memcached imagemagick \
    openssh-server

# Just dev stuff - these are not required for Librivox, I just fin them handy
# for debugging things in the container
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tree vim silversearcher-ag php8.1-xdebug

# Adds the librivox-ansible files and sets up this image
ADD librivox-ansible /librivox-ansible
WORKDIR /librivox-ansible
ADD localdev-docker.yaml .
ADD inventory-docker.yaml .
RUN service mariadb start && ansible-playbook localdev-docker.yaml \
    --limit localdev \
    --inventory inventory-docker.yaml \
    --verbose \
    --connection=local

WORKDIR /librivox/www/librivox.org/catalog
RUN php composer.phar install

# There are config files that the Ansible playbooks set up that are not checked
# in to librivox-catalog and are needed for it to run right. This lets Ansible
# do it's thing, then copies _everything_ into `catalog.bak`.

# When we set up the first time, we mount a new directory from the host over the
# top of `/librivox/www/librivox.org/catalog`, which will then be empty, then we
# copy the files from `catalog.bak` to `catalog` so that we have a copy on the
# host. (This is where you'll point your editor.) This is a one-time setup the
# very first time you run the container.

RUN cp -r . ../catalog.bak

# Starts up all the services that we need and drops us into a bash prompt
# (the prompt is handy for debugging, but not really needed)
ENTRYPOINT service apache2 start && \
    service php8.1-fpm start && \
    service sphinxsearch start && \
    service mariadb start && \
    bash
