FROM centos/ruby-25-centos7
ENV RACK_ENV=production
ENV RAILS_ENV=production
ENV NODE_ENV=production
ENV SECRET_KEY_BASE=cannot-be-blank-for-production-env-when-building
USER root
COPY . /tmp/src
RUN yum-config-manager --disable cbs.centos.org_repos_sclo7-rh-ruby25-rh-candidate_x86_64_os_ && \
    curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo && \
    curl --silent --location https://rpm.nodesource.com/setup_10.x | bash - && \
    yum  install yarn -y && \
    $STI_SCRIPTS_PATH/assemble

USER 1001

# make sure unique secret key is set by operator
ENV SECRET_KEY_BASE=
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_LOG_TO_STDOUT=1

CMD bundle exec rake geo:fetch && bundle exec puma -t 8
