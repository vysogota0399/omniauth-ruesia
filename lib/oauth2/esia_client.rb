# frozen_string_literal: true

module OAuth2
  class EsiaClient < OAuth2::Client
    def authorize_url(params = {})
      connection.build_url(
        options[:authorize_url],
        url_params(params)
      ).to_s
    end

    private

    def url_params(params)
      { client_secret: sign(signature_params.merge(params)) }
    end

    def sign(params)
      connection.post(options[:cms_server_url], params.values.join)
    end

    def signature_params
      {
        'client_id' => '',
        'scope' => '',
        'timestamp' => Time.current.strftime('%Y.%m.%d %H:%M:%S %z'),
        'state' => '',
        'redirect_uri' => ''
      }
    end
  end
end
