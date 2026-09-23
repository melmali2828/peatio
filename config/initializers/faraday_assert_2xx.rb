# frozen_string_literal: true

# Stand-in for the one method Peatio used from the `better-faraday` gem, which
# was removed because it pins activesupport < 7.0 and is unmaintained.
# Same contract the callers rely on: returns the response on 2xx, otherwise
# raises a Faraday::Error subclass, so the existing `rescue Faraday::Error`
# blocks in lib/peatio/*/client.rb keep turning it into ConnectionError.
# The message leaves out the URL and body on purpose: node RPC URLs can embed
# credentials (user:password@host).
module FaradayAssert2xx
  def assert_2xx!
    code = status.to_i
    return self if code.between?(200, 299)

    error_class =
      case code
      when 400..499 then Faraday::ClientError
      when 500..599 then Faraday::ServerError
      else Faraday::Error
      end
    raise error_class, "Unexpected HTTP status #{code} (#{env.method.to_s.upcase} #{env.url&.host})"
  end
end

Faraday::Response.include(FaradayAssert2xx)
