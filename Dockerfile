# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.2.7

# Base stage - common setup
FROM docker.io/library/ruby:$RUBY_VERSION-slim AS base

# Rails app lives here
WORKDIR /rails

# Add this earlier in your Dockerfile
RUN if [ "$RAILS_ENV" = "production" ]; then \
      SECRET_KEY_BASE=$(ruby -rsecurerandom -e 'puts SecureRandom.hex(32)') \
      RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
      ./bin/rails assets:precompile; \
    fi
# Install base packages
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
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development"

ENV RAILS_ENV=${RAILS_ENV:-production}

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        libjemalloc2 \
        libvips \
        sqlite3 \
        libyaml-dev \
        postgresql-client \
        libpq-dev \
        nodejs \
        build-essential \
        git \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

COPY Gemfile Gemfile.lock ./
# Install specific gem from source
ARG COMPONENTS_BRANCH="develop"  # Default branch

RUN apt-get update && apt-get install -y git && \
    git clone -b ${COMPONENTS_BRANCH} --depth 1 \
    https://github.com/EduchainTeam/educhain_view_components.git \
    /tmp/educhain_view_components && \
    cd /tmp/educhain_view_components && \
    gem build educhain_view_components.gemspec && \
    gem install educhain_view_components-*.gem && \
    rm -rf /tmp/educhain_view_components

RUN bundle config set --local frozen 'true' && \
    bundle config set --local deployment 'true' && \
    bundle install --jobs=4 --retry=3 && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache && \
    bundle exec bootsnap precompile --gemfile
    
# Add this after bundle install to fix gem paths
RUN if [ -d "${BUNDLE_PATH}/bundler/gems" ]; then \
    ln -s "${BUNDLE_PATH}/bundler/gems" /gems; \
    fi

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

RUN if [ "$RAILS_ENV" = "production" ]; then \
      SECRET_KEY_BASE=$(openssl rand -hex 32) \
      RAILS_MASTER_KEY=${RAILS_MASTER_KEY} \
      ./bin/rails assets:precompile; \
    fi
# Final stage for app image
FROM base

# Copy built artifacts from build stage
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Set PATH to include binstubs
ENV PATH="/usr/local/bundle/bin:/rails/bin:${PATH}"

# Run as non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Start server
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]