# frozen_string_literal: true

# K-line point is represented as array of 5 numbers:
# [timestamp, open_price, max_price, min_price, last_price, period_volume]

module Workers
  module Daemons
    class CronJob < Base
      JOBS = [Jobs::Cron::KLine, Jobs::Cron::Ticker, Jobs::Cron::StatsMemberPnl, Jobs::Cron::AML, Jobs::Cron::Refund, Jobs::Cron::WalletBalances].freeze

      # CRON_JOBS: comma-separated job names to run, as in JOBS without the
      # Jobs::Cron prefix (e.g. "KLine,Ticker"). Unset or empty runs every job.
      def self.selected_jobs(value = ENV['CRON_JOBS'])
        return JOBS if value.blank?

        known = JOBS.index_by { |job| job.name.demodulize }
        names = value.split(',').map(&:strip).reject(&:empty?).uniq
        raise ArgumentError, 'CRON_JOBS: no job names given' if names.empty?

        unknown = names - known.keys
        if unknown.any?
          raise ArgumentError, "CRON_JOBS: unknown job(s): #{unknown.join(', ')} (known: #{known.keys.join(', ')})"
        end

        known.values_at(*names)
      end

      attr_reader :jobs

      def initialize
        super
        @jobs = self.class.selected_jobs
      end

      def run
        logger.info { "Cron jobs: #{jobs.map { |job| job.name.demodulize }.join(', ')}" }
        jobs.map { |j| Thread.new { process(j) } }.map(&:join)
      end

      def process(service)
        service.process while running
      end
    end
  end
end
