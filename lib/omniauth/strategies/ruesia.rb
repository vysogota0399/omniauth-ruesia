# frozen_string_literal: true

module OmniAuth
  module Strategies
    class Ruesia < OmniAuth::Strategies::OAuth2
      option :name, 'esia'
      option :client_options, {
        site:          'https://esia.gosuslugi.ru',
        authorize_url: 'aas/oauth2/v2/ac',
        token_url:     'aas/oauth2/v3/te',
      }
      uid { JWT.decode(access_token.token, nil, false).first['urn:esia:sbj_id'] }

      info do
        {
          first_name:   raw_info['firstName'],
          last_name:    raw_info['lastName'],
          middle_name:  raw_info['middleName'],
          truster:      raw_info['trusted'],
          verifying:    raw_info['verifying'],
          r_id_doc:     raw_info['r_id_doc'],
        }
      end

      extra do
        scopes = options.scope.split
        extra_ = {}
        extra_ = extra_.merge(get_email) if scopes.include?('email')
        extra_ = extra_.merge(get_passport) if scopes.include?('id_doc')
        extra_ = extra_.merge(get_mobile) if scopes.include?('mobile')
        extra_
      end

      def raw_info
        @raw_info ||= access_token.get("/rs/prns/#{uid}")&.parsed
      end

      private

      def state
        @state ||= SecureRandom.uuid
      end

      def authorize_params # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        options.authorize_params[:state] = state

        if OmniAuth.config.test_mode
          @env ||= {}
          @env["rack.session"] ||= {}
        end

        params = options.authorize_params
                        .merge(options_for("authorize"))
                        .merge(pkce_authorize_params)

        session["omniauth.pkce.verifier"] = options.pkce_verifier if options.pkce
        session["omniauth.state"] = params[:state]

        params
      end

      def request_phase
        redirect client.auth_code.authorize_url(
          authorize_params.merge(
            redirect_uri: callback_url,
            timestamp: timestamp,
            client_certificate_hash: fingerprint,
            client_secret: sign(client_secret_base)
            # permissions: permissions
          )
        )
      end

      def client
        ::OAuth2::EsiaClient.new(
          options.client_id,
          '',
          deep_symbolize(options.client_options)
        )
      end

      def client_secret_base
        base_secret = [options.client_id, options.scope, timestamp, state, callback_url]
        yield base_secret if block_given?

        base_secret.join
      end

      def timestamp
        @timestamp ||= Time.current.strftime('%Y.%m.%d %H:%M:%S %z')
      end

      def fingerprint
        options.cert_fingerprint
      end

      def sign(secret)
        secret_base64 = Base64.urlsafe_encode64(secret)
        response = Faraday.post(options.csp_server_url, { text: secret_base64 })
        JSON.parse(response.body)['signature']
      end

      def build_access_token
        code = request.params['code']
        client.auth_code.get_token(code,
          {
            state: state,
            scope: options.scope,
            timestamp: timestamp,
            redirect_uri: callback_url,
            token_type: 'Bearer',
            client_secret: sign(client_secret_base { |secret| secret << code }),
            client_id: options.client_id,
            client_certificate_hash: fingerprint
          }
        )
      end
    
      def get_email
        {
          email: ctts.find { |e| e['type'] == 'EML' }.fetch('value')
        }
      end

      def get_passport
        {
          passport: access_token
                      .get("/rs/prns/#{uid}/docs?embed=(elements)")
                      .parsed.fetch('elements', {})
                      .find { |e| e['type'] == 'RF_PASSPORT' }
                      .to_h
        }
      end

      def get_mobile
        {
          mobile: ctts
                  .find { |e| e['type'] == 'MBT' }
                  .fetch('value')
        }
      end

      def ctts
        @ctts ||= access_token
          .get("/rs/prns/#{uid}/ctts?embed=(elements)")
          .parsed.fetch('elements', {})
      end
    end
  end
end
