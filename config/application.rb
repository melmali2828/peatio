# encoding: UTF-8
# frozen_string_literal: true

require_relative 'boot'

require 'rails'

%w( active_record action_controller action_view active_job ).each { |framework| require "#{framework}/railtie" }

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
require_relative 'env_tweaks'
# production.rb uses JSONLogFormatter before autoloading is set up; ignored by Zeitwerk.
require_relative '../lib/peatio/json_log_formatter'

module Peatio
  class Application < Rails::Application
    config.load_defaults 7.1
    
    # Deliberate reverts of load_defaults (pre-upgrade behaviour kept):
    # - belongs_to presence validation: 45 non-optional associations and no DB
    #   foreign keys; enabling it is a separate data-integrity decision.
    config.active_record.belongs_to_required_by_default = false
    # - readonly-attribute assignment raising (7.1): currency.rb rewrites id (code
    #   alias) on every validation and enumerize#reload rewrites enum attributes
    #   (Order#ord_type). Readonly columns stay out of UPDATEs either way.
    config.active_record.raise_on_assign_to_attr_readonly = false
    

    # Eager loading app dir.
    config.eager_load_paths += Dir[Rails.root.join('app')]

    config.autoload_paths += Dir["#{config.root}/db/migrate/concerns/**/"]

    # Eager load constants from lib/peatio
    # There is a lot of constants used over the whole application.
    #   lib/peatio/aasm/locking.rb => AASM::Locking
    config.eager_load_paths += Dir[Rails.root.join('lib/peatio')]

    # Configure Sentry as early as possible.
    if ENV['SENTRY_DSN_BACKEND'].present?
      require 'sentry-ruby'
      require 'sentry-rails'
      Sentry.init { |config| config.dsn = ENV['SENTRY_DSN_BACKEND'] }
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = ENV.fetch('TIMEZONE')

    # Rails 6.1 restricts YAML-serialized ActiveRecord columns (e.g. `serialize
    # :spread, Array`) to a safe class allowlist by default. Some serialized
    # data contains ActiveSupport::StringInquirer (from Rails.env), which
    # isn't in the default allowlist and raises Psych::DisallowedClass on
    # load. Extend the allowlist rather than disabling safe loading entirely.
    config.active_record.yaml_column_permitted_classes = [
      Symbol, Date, Time, BigDecimal,
      ActiveSupport::HashWithIndifferentAccess, ActiveSupport::StringInquirer
    ]

    # Configure relative url root by setting URL_ROOT_PATH environment variable.
    # Used by microkube with API Gateway.
    config.relative_url_root = ENV.fetch('URL_ROOT_PATH', '/')

    # Remove cookies and cookies session.
    config.middleware.delete ActionDispatch::Cookies
    config.middleware.delete ActionDispatch::Session::CookieStore

    # Disable CSRF.
    config.action_controller.allow_forgery_protection = false

    config.middleware.use ActionDispatch::Flash
  end
end
