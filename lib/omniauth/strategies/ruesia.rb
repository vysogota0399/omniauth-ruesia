# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Ruesia < OmniAuth::Strategies::OAuth2
      option :name,  'esia'
      option :scope, 'fullname'

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
        redirect client.auth_code.authorize_url({:redirect_uri => callback_url}.merge(authorize_params))
      end

      def client
        ::OAuth2::EsiaClient.new(
          options.client_id,
          options.client_secret,
          deep_symbolize(options.client_options)
        )
      end
    end
  end
end
