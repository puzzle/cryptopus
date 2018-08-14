FROM ruby:2.2.10-jessie
RUN apt-get update -qq && apt-get install -y sqlite3 mysql-client libmysqlclient-dev libqtwebkit-dev
RUN mkdir /cryptopus
WORKDIR /cryptopus
COPY Gemfile /cryptopus/Gemfile
COPY Gemfile.lock /cryptopus/Gemfile.lock
RUN bundle install
COPY . /cryptopus
