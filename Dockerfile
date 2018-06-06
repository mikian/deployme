FROM ruby:2.5
MAINTAINER Mikko Kokkonen <mikko@mikian.com>

COPY . .

RUN bundle install

ENTRYPOINT ["exe/deployme", "-d", "/deploy"]
