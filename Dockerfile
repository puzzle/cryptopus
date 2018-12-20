FROM puzzle/ose3-rails
USER root
COPY . /tmp/src
RUN $STI_SCRIPTS_PATH/assemble
USER 1001
CMD $STI_SCRIPTS_PATH/run
