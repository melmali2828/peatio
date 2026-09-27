# frozen_string_literal: true

RSpec.describe JSONLogFormatter do
  let(:time) { Time.utc(2026, 9, 27, 12, 0, 0) }

  def format(msg)
    JSON.parse(subject.call('INFO', time, nil, msg))
  end

  it 'wraps a plain message' do
    expect(format('order processed')).to eq('level' => 'INFO', 'time' => time.to_s, 'message' => 'order processed')
  end

  it 'merges a JSON object message' do
    expect(format({ app: 'peatio' }.to_json)).to eq('app' => 'peatio', 'level' => 'INFO', 'time' => time.to_s)
  end

  it 'merges a symbol-keyed hash message (TaggedLogger)' do
    expect(format({ worker: 'w', message: 'm' })).to eq('worker' => 'w', 'message' => 'm', 'level' => 'INFO', 'time' => time.to_s)
  end

  it 'emits a single level/time key when the message already has them' do
    line = subject.call('WARN', time, nil, { 'time' => 1, 'level' => 'x', 'msg' => 'm' }.to_json)
    expect(line.scan('"time"').size).to eq 1
    expect(line.scan('"level"').size).to eq 1
    expect(JSON.parse(line)).to eq('time' => time.to_s, 'level' => 'WARN', 'msg' => 'm')
  end
end
