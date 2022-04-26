FROM ruby:3.1.2

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends jq

WORKDIR /usr/src/app
COPY rails7 .
COPY newrelic.yml ./config/
COPY --chmod=0755 entrypoint.sh /entrypoint.sh

RUN bundle install
RUN bundle exec rake db:setup
RUN bundle exec rake assets:precompile

ENTRYPOINT ["/entrypoint.sh"]
