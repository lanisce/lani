FROM ruby:3.1.4

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  curl \
  git \
  && rm -rf /var/lib/apt/lists/*

# Install Yarn
RUN npm install -g yarn

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock if it exists
COPY Gemfile* ./

# Install gems
RUN bundle install

# Copy package.json if it exists
COPY package*.json ./
RUN if [ -f package.json ]; then yarn install; fi

# Copy the rest of the application
COPY . .

# Precompile assets
# RUN bundle exec rails assets:precompile

# Expose port
EXPOSE 3000

# Start the Rails server
CMD ["bash"]
