# frozen_string_literal: true

# Rails 7.0 dropped the classic autoloader; Peatio ran on it (no load_defaults).
# These settings make the existing file layout Zeitwerk-compatible without
# touching global ActiveSupport inflections (which also drive camelize,
# table and route names).
Rails.autoloaders.main.inflector.inflect(
  'aasm'                          => 'AASM',
  'csv_formatter'                 => 'CSVFormatter',
  'json_log_formatter'            => 'JSONLogFormatter',
  'jwt_authentication_middleware' => 'JWTAuthenticationMiddleware',
  'kline_db'                      => 'KlineDB',
  'rabbit_mq_http'                => 'RabbitMQHTTP',
  'totp'                          => 'TOTP',
  'wallet_bsc'                    => 'WalletBSC',
  'wallet_btc'                    => 'WalletBTC',
  'wallet_eth'                    => 'WalletETH',
  'wallet_heco'                   => 'WalletHECO'
)

# Loaded explicitly with `require` (they define Peatio::* / EventAPI, which
# does not match their path under the lib/peatio autoload root).
%w[
  airdrop aml app export import influxdb upstream/opendax amqp/event_api
].each { |f| Rails.autoloaders.main.ignore(Rails.root.join("lib/peatio/#{f}.rb")) }

# Defines Matching::*Error classes (no Matching::Constants); loaded via
# require_relative from the other app/trading/matching files.
Rails.autoloaders.main.ignore(Rails.root.join('app/trading/matching/constants.rb'))

# AMQP benchmarks (lib/tasks/bench.rake). Both inherit from an undefined
# Matching::AMQP (pre-existing dead code); left in, it would break
# eager loading in production.
%w[trade_execution/amqp order_processing/amqp].each { |f| Rails.autoloaders.main.ignore(Rails.root.join("lib/peatio/bench/#{f}.rb")) }
