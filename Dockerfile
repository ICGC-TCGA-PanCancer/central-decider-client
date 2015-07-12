############################################################
# Dockerfile to build DELLY workflow container
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu

# File Author / Maintainer
MAINTAINER Brian O'Connor <boconnor@oicr.on.ca>

USER root
RUN apt-get -m update

RUN apt-get install -y make git libipc-system-simple-perl libgetopt-euclid-perl libjson-perl libwww-perl libdata-dumper-simple-perl libtemplate-perl

COPY central-decider-client /opt/central-decider-client

