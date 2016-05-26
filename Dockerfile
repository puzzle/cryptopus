FROM openshift/ruby-22-centos7

USER root

ENV RAILS_ENV=production \
    RAILS_ROOT=/opt/app-root/src

LABEL io.k8s.description="Platform for building and running Rails Application within Apache Passenger" \
      io.k8s.display-name="Apache 2.4 with Ruby 2.2" \
      io.openshift.expose-services="8080:http" \
      io.openshift.tags="builder,ruby,ruby22,httpd"

# Install Apache httpd24
RUN yum update -y && \
    INSTALL_PKGS="httpd httpd-devel apr-devel apr-util-devel sqlite3" && \
    yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS && \
    yum clean all -y

RUN /bin/bash -c "gem install passenger --no-ri --no-rdoc && \
    export PATH=$PATH:/opt/rh/rh-ruby22/root/usr/local/bin && \
    passenger-install-apache2-module --auto --languages ruby && \
    passenger-config validate-install " # bogus comment to invalidate cache

ADD config/docker/bin $STI_SCRIPTS_PATH

ADD . /tmp/src
ADD config/docker/httpd /etc/httpd
ADD config/docker/lib /usr/local/lib

# disable digest_module
RUN sed -i "s/LoadModule auth_digest_module/#LoadModule auth_digest_module/" /etc/httpd/conf.modules.d/00-base.conf

RUN mkdir -p /opt/app-root/httpd/pid

RUN chgrp -R 0 ./ && \
    chmod -R g+rw ./ && \
    find ./ -type d -exec chmod g+x {} + && \
    chown -R 1001:0 ./

RUN chmod -R a+rwX /opt/app-root/httpd/pid && \
    chmod +x $STI_SCRIPTS_PATH/run-httpd.sh

USER 1001

RUN $STI_SCRIPTS_PATH/assemble

ENV APACHE_RUN_USER 1001
ENV APACHE_PID_FILE /opt/app-root/httpd.pid

CMD $STI_SCRIPTS_PATH/run-httpd.sh
