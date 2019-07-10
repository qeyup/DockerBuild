
RUN mkdir /docker
COPY . /docker/
ADD https://raw.githubusercontent.com/qeyup/DockerBuild/master/DockerBuild.sh /docker/
RUN  cd /docker && chmod u+x DockerBuild.sh && ./DockerBuild.sh
