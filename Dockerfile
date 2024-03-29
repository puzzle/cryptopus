FROM ruby:3.2
ENV RACK_ENV=production
ENV RAILS_ENV=production

SHELL ["/bin/bash", "-c"]

USER root

ARG BUNDLE_WITHOUT='development:test'
ARG BUNDLER_VERSION=2.4.10

# install nodejs
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs

# yarn sources
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# init apt
RUN apt-get update && apt-get upgrade -y
# Install dependencies
RUN apt-get install -y yarn rsync

# set up app-src directory
COPY . /app-src
WORKDIR /app-src

# Run deployment
RUN gem install bundler:${BUNDLER_VERSION} --no-document
RUN    bundle config set --local deployment 'true' \
    && bundle config set --local without ${BUNDLE_WITHOUT} \
    && bundle package \
    && bundle install \
    && bundle clean

RUN rm -rf vendor/cache/ .git tmp

# build frontend
RUN yarn global add ember-cli@4.8.0
RUN /app-src/bin/prepare-frontend.sh
RUN rm -rf /app-src/frontend

RUN apt-get remove -y --purge rsync yarn nodejs
RUN apt-get autoremove -y

RUN adduser --disabled-password --uid 1001 --gid 0 --gecos "" app

RUN mkdir /app-src/tmp && chown -R 1001 /app-src/tmp && chmod 775 /app-src/tmp
RUN chmod 775 /app-src/db

USER 1001

# make sure unique secret key is set by operator
ENV SECRET_KEY_BASE=
ENV RAILS_SERVE_STATIC_FILES=1
ENV RAILS_LOG_TO_STDOUT=1

CMD bundle exec rake geo:fetch && bundle exec puma -t 8
