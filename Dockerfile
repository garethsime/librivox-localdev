# Largely inspired by the instructions here:
# https://github.com/LibriVox/librivox-ansible/blob/master/doc/localdev.md
#
# WARNING: I've used more recent versions of everything because installing old
# stuff was really hard and I'm not very smart, so your mileage may vary.

FROM ubuntu:focal

RUN echo 'net.ipv6.conf.all.disable_ipv6 = 1' > /etc/sysctl.d/01-disable-ipv6.conf

RUN apt-get update && apt-get upgrade -y 
RUN apt-get install git gcc make perl ansible gnupg python3-apt -y

ADD librivox-ansible /librivox-ansible
WORKDIR /librivox-ansible
RUN ansible-playbook deploy.yml -i hosts/localdev/hosts --verbose
