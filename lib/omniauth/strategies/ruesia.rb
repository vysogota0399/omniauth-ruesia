# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Ruesia < OmniAuth::Strategies::OAuth2
      option :name,  'esia'
      uid { raw_info['id'] }
      info do
        {
          first_name:  raw_info['firstName'],
          last_name:   raw_info['lastName'],
          middle_name: raw_info['middleName'],
          email:       raw_info['email']
        }
      end

      extra do
        {
          raw_info: raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get("/rs/prns/#{uid}")&.parsed.merge!(get_email)
      end

      private

      def state
        @state ||= SecureRandom.uuid
      end

      def request_phase
        redirect client.auth_code.authorize_url(
          authorize_params.merge(
            redirect_uri: callback_url,
            timestamp: timestamp,
            client_certificate_hash: fingerprint,
            client_secret: client_secret,
            state: state,
          )
        )
      end

      def client
        ::OAuth2::EsiaClient.new(
          options.client_id,
          client_secret,
          deep_symbolize(options.client_options)
        )
      end

      def client_secret 
        @client_secret ||= sign([options.client_id, options.scope, timestamp, state, callback_url].join)
      end

      def timestamp
        @timestamp ||= Time.current.strftime('%Y.%m.%d %H:%M:%S %z')
      end

      def fingerprint
        cert = OpenSSL::X509::Certificate.new(File.read(options[:cer_path]))
        OpenSSL::Digest::SHA1.new(cert.to_der).to_s
      end

      def sign(params)
        response = Faraday.post(options.csp_server_url, { text: params })
        JSON.parse(response.body)['result']
      end
    end
  end
end
