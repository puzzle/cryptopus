FROM ruby:2.7

USER root

ENV RAILS_ENV=development
ENV BUNDLE_PATH=/opt/bundle

WORKDIR /myapp

COPY ./rails-entrypoint /usr/local/bin
#COPY ./docker/webpack-entrypoint /usr/local/bin

RUN apt-get update
RUN apt-get install nodejs yarnpkg -y && ln -s /usr/bin/yarnpkg /usr/bin/yarn
RUN apt-get install direnv -y

RUN mkdir /opt/bundle && chmod 777 /opt/bundle
RUN mkdir /seed && chmod 777 /seed
RUN mkdir /home/developer && chmod 777 /home/developer
ENV HOME=/home/developer

ENTRYPOINT ["rails-entrypoint"]
CMD [ "rails", "server", "-b", "0.0.0.0" ]
