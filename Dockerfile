FROM centos/ruby-25-centos7
ENV RACK_ENV=production
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=cannot-be-blank-for-production-env-when-building
USER root
COPY . /tmp/src
RUN $STI_SCRIPTS_PATH/assemble
RUN bash -c bundle exec rake geo:fetch

USER 1001

# make sure unique secret key is set by operator
ENV SECRET_KEY_BASE=
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_LOG_TO_STDOUT: 1

CMD bundle exec puma -t 8
