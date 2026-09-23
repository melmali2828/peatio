# frozen_string_literal: true

describe 'ENV.true? / ENV.false? (config/env_tweaks.rb)' do
  let(:var) { 'ENV_TWEAKS_SPEC_VAR' }

  around do |example|
    original = ENV[var]
    example.run
  ensure
    original.nil? ? ENV.delete(var) : ENV[var] = original
  end

  it 'treats an unset variable as false' do
    ENV.delete(var)
    expect(ENV.false?(var)).to be true
    expect(ENV.true?(var)).to be false
  end

  ['', '  ', 'false', '0', 'nil', 'null'].each do |value|
    it "treats #{value.inspect} as false" do
      ENV[var] = value
      expect(ENV.false?(var)).to be true
      expect(ENV.true?(var)).to be false
    end
  end

  # Case-sensitive on purpose (identical to env-tweaks 1.0.1).
  %w[true 1 yes on FALSE False NULL no].each do |value|
    it "treats #{value.inspect} as true" do
      ENV[var] = value
      expect(ENV.true?(var)).to be true
      expect(ENV.false?(var)).to be false
    end
  end
end
