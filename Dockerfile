FROM ubuntu:18.04


RUN mkdir /docker
COPY . /docker/
RUN  cd /docker && chmod u+x DockerBuild.sh && ./DockerBuild.sh


WORKDIR /root/