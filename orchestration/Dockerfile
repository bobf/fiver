FROM ruby:2.7.1
ARG BUNDLE_BITBUCKET__ORG
ARG BUNDLE_GITHUB__COM
ARG GIT_COMMIT
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
 && apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y \
      nodejs \
      gosu \
      sendmail \
 && rm -rf /var/lib/apt/lists/* \
 && gem install bundler \
 && mkdir /app \
 && curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
 && . /root/.bashrc \
 && nvm install 10.13.0 \
 && npm config set user 0 \
 && npm config set unsafe-perm true \
 && npm install -g yarn
WORKDIR /app
COPY .build/Gemfile .build/Gemfile.lock ./
RUN bundle install --without development test --deployment
COPY .build/package.json .build/yarn.lock ./
RUN . /root/.bashrc ; yarn install
ADD .build/context.tar .
RUN . /root/.bashrc ; NODE_ENV=production RAILS_ENV=production yarn install && NODE_ENV=production RAILS_ENV=production SECRET_KEY_BASE=abc123 bundle exec rake assets:precompile
RUN echo "${GIT_COMMIT}" > /app/GIT_COMMIT
HEALTHCHECK --interval=30s \
            --timeout=30s \
            --start-period=5s \
            --retries=3 \
            CMD ["bundle","exec","rake","orchestration:healthcheck"]
ENTRYPOINT ["/app/orchestration/entrypoint.sh"]
CMD ["bundle","exec","unicorn","-c","config/unicorn.rb"]
