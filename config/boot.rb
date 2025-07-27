ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

# Fix for Rails 7.0.8.7 + concurrent-ruby 1.3.5 compatibility issue
# See: https://github.com/rails/rails/issues/54271
require 'logger'

require 'bundler/setup' # Set up gems listed in the Gemfile.
require 'bootsnap/setup' # Speed up boot time by caching expensive operations.
