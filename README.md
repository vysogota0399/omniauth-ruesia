# Ruesia
`OmniAuth::Strategies::Ruesia` is a simple Rack middleware for authorization in the russian Unified identification and authentication system(ЕСИА). Read the OmniAuth docs for detailed instructions: https://github.com/intridea/omniauth. The `…/v2/ac` resource is used as a technical solution for gathering authentication code and `…/v3/te` for JWT. In order to write `client_secret`, you need to send an http post request to any system that can work with data-hash signing algorithms using mechanisms of certified Russian
cryptographic means of information protection and a certificate
of the information system and return json response with signature
```
Request:
POST /api/sign { test: 'any string' }

Response:
{ signature: 'base64urlsafe signature' }
```

## Installation
Add this line to your application's Gemfile:

```ruby
gem "ruesia"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install ruesia
```
## Usage
Here's a quick example, adding the middleware to a Rails app in config/initializers/ruesia.rb:
```
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :ruesia, 'MY_SYSTEM',
    scope: 'fullname email mobile id_doc'
    cert_fingerprint: 'cert hex fingerprint'
    csp_server_url: 'http://192.168.1.195:8080/api/sign'
    client_options:
      site: 'https://esia-portal1.test.gosuslugi.ru'
end
```

## Configuration
Guidelines for the use of the Unified Identification and Authentication System:
https://digital.gov.ru/ru/documents/6186/
|option  |comment  | 
|---|---|
|scope   |requested access rights - paragraph B4 Table 95  |
|cert_fingerprint| parameter containing the hash of the certificate (`fingerprint`) of the client system in hex format. To generate it, use http://esia.gosuslugi.ru/public/calc_cert_hash_unix.zip|
|csp_server_url| url for cms server. We use Faradat to `post` request for `/api/sign`|

Add callback request to routes
```
get 'auth/:provider/callback', to: 'api/client/esia#create'
```
## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
