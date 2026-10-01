# frozen_string_literal: true

describe Workers::Daemons::CronJob do
  around do |example|
    saved = ENV['CRON_JOBS']
    example.run
  ensure
    saved.nil? ? ENV.delete('CRON_JOBS') : ENV['CRON_JOBS'] = saved
  end

  describe '.selected_jobs' do
    it 'runs every job when CRON_JOBS is unset or empty' do
      expect(described_class::JOBS.size).to eq 6
      expect(described_class.selected_jobs(nil)).to eq described_class::JOBS
      expect(described_class.selected_jobs('')).to eq described_class::JOBS
    end

    it 'selects the listed jobs in the given order' do
      expect(described_class.selected_jobs('KLine,Ticker,StatsMemberPnl,AML,Refund'))
        .to eq [Jobs::Cron::KLine, Jobs::Cron::Ticker, Jobs::Cron::StatsMemberPnl, Jobs::Cron::AML, Jobs::Cron::Refund]
      expect(described_class.selected_jobs(' Ticker , KLine,Ticker ')).to eq [Jobs::Cron::Ticker, Jobs::Cron::KLine]
    end

    it 'raises on an unknown job name' do
      expect { described_class.selected_jobs('KLine,Kline') }
        .to raise_error(ArgumentError, /unknown job\(s\): Kline \(known: KLine, Ticker/)
    end

    it 'raises when the list has no names' do
      expect { described_class.selected_jobs(' , ') }.to raise_error(ArgumentError, /no job names/)
    end
  end

  describe 'start-up' do
    it 'reads CRON_JOBS when the daemon is created and fails fast on a bad name' do
      ENV['CRON_JOBS'] = 'WalletBalance'
      expect { described_class.new }.to raise_error(ArgumentError, /unknown job\(s\): WalletBalance \(/)
    end

    it 'starts only the selected jobs' do
      ENV['CRON_JOBS'] = 'KLine,Ticker'
      worker = described_class.new
      expect(worker.jobs).to eq [Jobs::Cron::KLine, Jobs::Cron::Ticker]
      worker.expects(:process).with(Jobs::Cron::KLine).once
      worker.expects(:process).with(Jobs::Cron::Ticker).once
      worker.run
    end
  end
end
