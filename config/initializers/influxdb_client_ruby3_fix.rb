# frozen_string_literal: true

# Ruby 3.0 stopped implicitly converting a trailing Hash argument into
# keyword arguments. influxdb-ruby 0.7.0 relies on that old behavior in
# multiple places when forwarding **opts hashes to other methods as a
# plain positional Hash, which breaks under Ruby 3.0+ with:
#   ArgumentError: wrong number of arguments (given N, expected N-1)
#
# Each fix below is a copy of the original method with only the
# offending call site changed from `foo(opts)` to `foo(**opts)`.
if RUBY_VERSION >= '3.0'
  # influxdb-0.7.0/lib/influxdb/client.rb:54
  module InfluxDBClientRuby3KwargsFix
    def initialize(database = nil, **opts)
      opts[:database] = database if database.is_a? String
      @config = InfluxDB::Config.new(**opts)
      @stopped = false
      @writer = find_writer

      at_exit { stop! }
    end
  end

  # influxdb-0.7.0/lib/influxdb/query/core.rb:19-37
  module InfluxDBQueryCoreRuby3KwargsFix
    def query(
      query,
      params:       nil,
      denormalize:  config.denormalize,
      chunk_size:   config.chunk_size,
      **opts
    )
      query = builder.build(query, params)

      url = full_url("/query".freeze, query_params(query, **opts))
      series = fetch_series(get(url, parse: true, json_streaming: !chunk_size.nil?))

      if block_given?
        series.each do |s|
          values = denormalize ? denormalize_series(s) : raw_values(s)
          yield s['name'.freeze], s['tags'.freeze], values
        end
      else
        denormalize ? denormalized_series_list(series) : series
      end
    end
  end

  InfluxDB::Client.prepend(InfluxDBClientRuby3KwargsFix)
  InfluxDB::Client.prepend(InfluxDBQueryCoreRuby3KwargsFix)
end

# Ruby 3.0 also broke the common `raise SomeException, key: value, ...` /
# `fail SomeException, key: value, ...` idiom for any exception class whose
# `initialize` takes only keyword arguments. That idiom calls
# `SomeException.exception(hash)` under the hood, passing the trailing
# key/value pairs as a single positional Hash — which `initialize(message:,
# **opt)`-style signatures can no longer accept implicitly.
#
# Rather than rewriting every call site, we patch `.exception` itself (once,
# at the class level) to double-splat a lone positional Hash argument.
if RUBY_VERSION >= '3.0'
  module ExceptionKwargsFix
    def exception(*args)
      if args.length == 1 && args.first.is_a?(::Hash) && !args.first.empty?
        new(**args.first)
      else
        super
      end
    end
  end

  [
    API::V2::Management::Exceptions::Base,
    Grape::Exceptions::Validation,
  ].each { |klass| klass.singleton_class.prepend(ExceptionKwargsFix) }
end
