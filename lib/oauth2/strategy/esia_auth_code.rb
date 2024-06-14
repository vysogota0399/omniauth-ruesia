# frozen_string_literal: true

module OAuth2
  module Strategy
    class EsiaAuthCode < AuthCode
      def assert_valid_params(_params); end
    end
  end
end