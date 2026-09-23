# encoding: UTF-8
# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 3.4.0'

gem 'ransack', '~> 2.5.0'
gem 'rails', '~> 7.0.0'
gem 'concurrent-ruby', '1.3.4'
gem 'puma', '~> 3.12.2'
gem 'mysql2', '~> 0.5.2'
gem 'redis', '~> 4.1.2', require: ['redis', 'redis/connection/hiredis']
gem 'hiredis', '~> 0.6.0'
gem 'figaro', '~> 1.3.0'
gem 'hashie', '~> 3.6.0'
gem 'aasm', '~> 5.0.8'
gem 'bunny', '~> 2.14.1'
gem 'cancancan', '~> 3.1.0'
gem 'enumerize', '~> 2.8'
gem 'kaminari', '~> 1.2.1'
gem 'rbtree', '~> 0.4.2'
gem 'grape', '~> 1.8'
gem 'grape-entity', '~> 0.7.1'
gem 'grape-swagger', '~> 0.30.1'
gem 'grape-swagger-ui', '~> 2.2.8'
gem 'grape-swagger-entity', '~> 0.2.5'
gem 'grape_logging', '~> 1.8.0'
gem 'rack-attack', '~> 5.4.2'
gem 'faraday', '~> 1.10'
gem 'faraday_middleware', '~> 1.2.1'
gem 'faye', '~> 1.4'
gem 'eventmachine', '~> 1.2'
gem 'em-synchrony', '~> 1.0'
gem 'jwt', '~> 2.2.0'
gem 'email_validator', '~> 1.6.0'
gem 'validate_url', '~> 1.0.4'
gem 'god', '~> 0.13.7', require: false
gem 'sentry-ruby', '~> 4.9', require: false
gem 'sentry-rails', '~> 4.9', require: false
gem 'memoist', '~> 0.16.0'
gem 'method-not-implemented', '~> 1.0.1'
gem 'validates_lengths_from_database', '~> 0.7.0'
gem 'jwt-multisig', '~> 1.0.0'
gem 'cash-addr', '~> 0.2.0', require: 'cash_addr'
gem 'keccak', '~> 1.3', require: 'digest/keccak'
gem 'scout_apm', '~> 2.4', require: false
gem 'peatio', '~> 3.1.0'
gem 'rack-cors', '~> 1.0.6', require: false
gem 'jwt-rack', '~> 0.1.0', require: false
gem 'vault', '~> 0.12', require: false
gem 'vault-rails', git: 'http://github.com/rubykube/vault-rails'
gem 'bootsnap', '>= 1.1.0', require: false
gem 'net-http-persistent', '>= 3.0.1'
gem 'influxdb', '~> 0.7.0'
gem 'safe_yaml', '~> 1.0.5', require: 'safe_yaml/load'
gem 'composite_primary_keys', '~> 14.0.1'

group :development, :test do
  gem 'irb'
  gem 'bump',         '~> 0.7'
  gem 'faker',        '~> 2.23'
  gem 'pry-byebug',   '~> 3.7'
  gem 'bullet',       '~> 7.1'
  gem 'grape_on_rails_routes', '~> 0.3.2'
end

group :development do
  gem 'annotate',   '~> 3.2.0'
  gem 'ruby-prof', '~> 1.7', require: false
  gem 'listen',     '>= 3.0.5', '< 3.2'
end

group :test do
  gem 'rspec-rails', '3.9.0'
  gem 'rspec-retry',         '~> 0.6'
  gem 'webmock', '3.18.1'
  gem 'database_cleaner',    '~> 1.7'
  gem 'mocha', '1.16.1', require: false
  gem 'factory_bot_rails', '~> 5.0', '>= 5.0.2'
  gem 'timecop',             '~> 0.9'
  gem 'rubocop-rspec',       '~> 1.32', require: false
end

# Load gems from Gemfile.plugin.
Dir.glob File.expand_path('../Gemfile.plugin', __FILE__) do |file|
  eval_gemfile file
end

gem "pg", "~> 1.2"
gem 'psych', '~> 3.3.2'

# Pin the whole rspec/mocha family to their originally-locked versions.
# Newer patch releases in this family broke the mocha `.stubs` integration
# used throughout spec_helper.rb ("outside of the per-test lifecycle" error).
gem 'rspec-core', '3.9.0'
gem 'rspec-expectations', '3.9.0'
gem 'rspec-mocks', '3.9.0'
gem 'rspec-support', '3.9.4'

gem 'mutex_m'
gem 'observer'
gem 'csv'
gem 'drb'
