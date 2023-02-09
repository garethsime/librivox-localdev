# Largely inspired by the instructions here:
# https://github.com/LibriVox/librivox-ansible/blob/master/doc/localdev.md
#
# WARNING: I've used more recent versions of everything because installing old
# stuff was really hard and I'm not very smart, so your mileage may vary.

FROM ubuntu:jammy

# Disables IPV6 because the README said to?
RUN echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/01-disable-ipv6.conf

# Most of these aren't strictly necessary, but they speed
# up Dockerfile dev by allowing us to cache the results as
# layers
# These should all be smushed into one command, but I didn't
# want to rebuild my cache just now haha
RUN apt-get update && apt-get upgrade -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install git gcc make perl ansible gnupg python3-apt -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install cron -y
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
    git apache2 mariadb-server \
    php8.1-fpm php8.1-mysql php8.1-curl php8.1-memcache php8.1-memcached php8.1-intl php8.1-mbstring php8.1-xml php8.1-zip php8.1-apcu \
    python3-certbot-apache python3-mysqldb \
    sphinxsearch mp3gain unzip memcached imagemagick
RUN DEBIAN_FRONTEND=noninteractive apt-get install openssh-server -y

# Adds the librivox-ansible files and sets up this image
ADD librivox-ansible /librivox-ansible
WORKDIR /librivox-ansible
RUN service mariadb start && ansible-playbook librivox.yaml \
    --limit localdev \
    --inventory inventory.yaml \
    --verbose \
    --connection=local

# Now that the databases are configured, we can load the scrubbed data
RUN bunzip2 resources/librivox_catalog_scrubbed.sql.bz2
RUN service mariadb start && \
    mysql librivox_catalog < resources/librivox_catalog_scrubbed.sql

# Just dev stuff
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tree vim
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y silversearcher-ag

# Starts up all the services that we need and drops us into a bash prompt
# (the prompt is handy for debugging, but not really needed)
ENTRYPOINT service apache2 restart && \
    service php8.1-fpm restart && \
    service sphinxsearch restart && \
    service mariadb restart && \
    bash
