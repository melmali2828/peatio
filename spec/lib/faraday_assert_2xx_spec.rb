# frozen_string_literal: true

RSpec.describe 'Faraday::Response#assert_2xx!' do
  def response_with(status)
    stubs = Faraday::Adapter::Test::Stubs.new { |s| s.get('/x') { [status, {}, 'body'] } }
    Faraday.new(url: 'http://user:secret@node.example') { |f| f.adapter :test, stubs }.get('/x')
  end

  it 'returns the response on 2xx' do
    response = response_with(200)
    expect(response.assert_2xx!).to be(response)
  end

  it 'raises Faraday::ClientError on 4xx' do
    expect { response_with(422).assert_2xx! }.to raise_error(Faraday::ClientError, /422/)
  end

  it 'raises Faraday::ServerError on 5xx' do
    expect { response_with(503).assert_2xx! }.to raise_error(Faraday::ServerError, /503/)
  end

  it 'raises Faraday::Error on other non-2xx statuses' do
    expect { response_with(302).assert_2xx! }.to raise_error(Faraday::Error, /302/)
  end

  it 'does not put credentials in the error message' do
    expect { response_with(500).assert_2xx! }
      .to raise_error { |e| expect(e.message).not_to include('secret') }
  end
end
