# frozen_string_literal: true

module OAuth2
  class EsiaClient < OAuth2::Client
    def auth_code
      @auth_code ||= OAuth2::Strategy::EsiaAuthCode.new(self)
    end
  end
end
