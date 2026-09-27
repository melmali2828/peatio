# encoding: UTF-8
# frozen_string_literal: true

module API
  module V2
    module Management
      class Tools < Grape::API
        desc 'Returns server time in seconds since Unix epoch.'
        post '/timestamp', scope: :tools do
          body timestamp: Time.now.iso8601
          status 200
        end
      end
    end
  end
end
