FROM ruby:3.4.5 AS base

LABEL maintainer="lbellet@heliostech.fr"

# By default image is built using RAILS_ENV=production.
# You may want to customize it:
#
#   --build-arg RAILS_ENV=development
#
# See https://docs.docker.com/engine/reference/commandline/build/#set-build-time-variables-build-arg
#
ARG RAILS_ENV=production
ENV RAILS_ENV=${RAILS_ENV} APP_HOME=/home/app

# Allow customization of user ID and group ID (it's useful when you use Docker bind mounts)
ARG UID=1000
ARG GID=1000

# Set the TZ variable to avoid perpetual system calls to stat(/etc/localtime)
ENV TZ=UTC

# Create group "app" and user "app".
RUN groupadd -r --gid ${GID} app \
  && useradd --system --create-home --home ${APP_HOME} --shell /sbin/nologin --no-log-init \
  --gid ${GID} --uid ${UID} app

# Install system dependencies.
RUN apt-get update && apt-get upgrade -y
RUN apt-get install default-libmysqlclient-dev -y

WORKDIR $APP_HOME

# Bundler settings (replace the removed --path/--without flags).
# BUNDLE_FROZEN fails the build if Gemfile and Gemfile.lock disagree.
ENV BUNDLE_PATH=/opt/vendor/bundle BUNDLE_WITHOUT=development:test BUNDLE_FROZEN=true

# Install dependencies defined in Gemfile.
COPY --chown=app:app Gemfile Gemfile.lock $APP_HOME/
RUN mkdir -p /opt/vendor/bundle \
  && gem install bundler -v 2.4.22 --no-document \
  && chown -R app:app /opt/vendor $APP_HOME \
  && su app -s /bin/bash -c "bundle install --jobs $(nproc)"

# Copy application sources.
COPY --chown=app:app . $APP_HOME

# Switch to application user.
USER app

# Initialize application configuration & assets.
# init_config also renders config/application.yml (Figaro development defaults);
# it is deleted so production only reads real environment variables.
RUN echo "# This file was overridden by default during docker image build." > Gemfile.plugin \
  && ./bin/init_config \
  && rm -f config/application.yml \
  && chmod +x ./bin/logger \
  && mkdir -p tmp/cache/assets tmp/sockets tmp/pids tmp/screenshots

# Expose port 3000 to the Docker host, so we can access it from the outside.
EXPOSE 3000

# The main command to run when the container starts.
CMD ["bundle", "exec", "puma", "--config", "config/puma.rb"]

# Extend base image with plugins.
FROM base

# Copy Gemfile.plugin for installing plugins.
COPY --chown=app:app Gemfile.plugin Gemfile.lock $APP_HOME/

# Install plugins.
RUN bundle install --jobs $(nproc)
