# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.2.7

# Single stage build to avoid issues
FROM docker.io/library/ruby:$RUBY_VERSION-slim

WORKDIR /rails

# Install all dependencies (both build and runtime)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        libjemalloc2 \
        libvips \
        libyaml-dev \
        postgresql-client \
        libpq-dev \
        nodejs \
        build-essential \
        git \
        sqlite3 \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

# Install specific gem from source
ARG COMPONENTS_BRANCH="develop"

RUN git clone -b ${COMPONENTS_BRANCH} --depth 1 \
    https://github.com/EduchainTeam/educhain_view_components.git \
    /tmp/educhain_view_components && \
    cd /tmp/educhain_view_components && \
    gem build educhain_view_components.gemspec && \
    gem install educhain_view_components-*.gem && \
    rm -rf /tmp/educhain_view_components

COPY Gemfile Gemfile.lock ./

RUN bundle config set --local frozen 'true' && \
    bundle config set --local deployment 'true' && \
    bundle install --jobs=4 --retry=3 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache

# Verify gem installation
RUN bundle list | grep educhain_view_components && \
    gem contents educhain_view_components | head -5 && \
    echo "Gem verified"

# Copy application code
COPY . .

# Generate binstubs and make executable
RUN bundle binstubs railties --path ./bin && \
    chmod +x bin/*

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets
RUN SECRET_KEY_BASE=dummy RAILS_MASTER_KEY=${RAILS_MASTER_KEY} ./bin/rails assets:precompile

# Set PATH to include binstubs and bundle
ENV PATH="/rails/bin:/usr/local/bundle/bin:${PATH}"

# Run as non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Start server
EXPOSE 3000
CMD ["sh", "-c", "echo 'Starting Rails application...' && bundle exec rails server -b 0.0.0.0"]