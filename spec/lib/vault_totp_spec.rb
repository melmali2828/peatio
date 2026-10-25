# frozen_string_literal: true

describe Vault::TOTP do
  let(:uid) { 'uid' }
  let(:email) { 'email' }

  describe '.with_human_error' do
    it 'renders human error when vault is down' do
      expect do
        described_class.with_human_error do
          raise Vault::VaultError, 'Message connection refused message'
        end
      end.to raise_error(described_class::Error, '2FA server is under maintenance')
    end

    it 'renders human error when code was used twice' do
      expect do
        described_class.with_human_error do
          raise Vault::VaultError, 'Message code already used message'
        end
      end.to raise_error(described_class::Error,
                         'This code was already used. Wait until the next time period')
    end

    it 'renders error when called without block' do
      expect do
        described_class.with_human_error
      end.to raise_error(ArgumentError, 'Block is required')
    end
  end

  describe '.validate?' do
    before do
      described_class.stubs(:write_data).returns( OpenStruct.new({data: data}) )
      described_class.stubs(:read_data).returns( OpenStruct.new({data: data}) )
    end
    let(:data) { { valid: true } }

    subject { described_class.validate?(uid, 'code') }

    context 'when valid' do
      before { described_class.stubs(:exist?).returns( true ) }
      it { is_expected.to eq true }
    end

    context 'when invalid' do
      before { described_class.stubs(:exist?).returns( true ) }
      let(:data) { { valid: false } }
      it { is_expected.to eq false }
    end
  end

  describe '.totp_application' do
    around do |example|
      previous = ENV['VAULT_TOTP_APP_NAME']
      begin
        example.run
      ensure
        ENV['VAULT_TOTP_APP_NAME'] = previous
      end
    end

    it 'defaults to the Vault application name' do
      ENV['VAULT_TOTP_APP_NAME'] = nil
      expect(described_class.totp_application).to eq Vault.application
    end

    it 'ignores a blank VAULT_TOTP_APP_NAME' do
      ENV['VAULT_TOTP_APP_NAME'] = ''
      expect(described_class.totp_application).to eq Vault.application
    end

    it 'uses VAULT_TOTP_APP_NAME when set' do
      ENV['VAULT_TOTP_APP_NAME'] = 'barong'
      expect(described_class.totp_application).to eq 'barong'
    end

    it 'checks the code against the key of that application' do
      ENV['VAULT_TOTP_APP_NAME'] = 'barong'
      described_class.expects(:write_data)
                     .with { |key, params| key == "totp/code/barong_#{uid}" && params[:code] == '123456' }
                     .returns(OpenStruct.new({ data: { valid: true } }))
      expect(described_class.validate?(uid, '123456')).to eq true
    end
  end
end
