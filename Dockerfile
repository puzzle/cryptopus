FROM centos/ruby-27-centos7
ENV RACK_ENV=production
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=cannot-be-blank-for-production-env-when-building
ENV DISABLE_ASSET_COMPILATION=true

USER root

# Install yarn
RUN yum -y install ca-certificates && \
    wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo && \
    rpm -Uvh --nodeps $(repoquery --location yarn)
# reduce image size
RUN yum clean all -y && rm -rf /var/cache/yum

# copy files needed for assembly into container
ADD ./config/docker/s2i/root /
RUN echo -e "\n\$STI_SCRIPTS_PATH/post-assemble" >> $STI_SCRIPTS_PATH/assemble

COPY . /tmp/src

RUN $STI_SCRIPTS_PATH/assemble

USER 1001

# make sure unique secret key is set by operator
ENV NODE_ENV=production
ENV SECRET_KEY_BASE=
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_LOG_TO_STDOUT=1

CMD bundle exec rake geo:fetch && bundle exec puma -t 8
