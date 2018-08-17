require 'dry-configurable'
require 'net/http'
require 'nori'

module Safetypay
  class Client
    extend Dry::Configurable

    setting :api_key, reader: true
    setting :signature_key, reader: true
    setting :environment, reader: true

    def self.create_express_token(request: nil)
      self.validate_credentials
      response = Safetypay::Communicator.make_request(request)
    end

    def self.validate_credentials
      if !self.api_key || !self.signature_key
        raise Safetypay::FailedInitialization
      end
    end
  end

  class Communicator
    URL = URI.parse('https://sandbox-mws2.safetypay.com/express/ws/v.3.0')

    def self.make_request(payload, &block)
      Net::HTTP.start(URL.host, 443, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(URL.request_uri)
        request.content_type = 'text/xml'
        request['SoapAction'] = payload.soap_action
        request.body = RequestFormatter.format(payload: payload)
        response = http.request request
        if response.code == "200"
          parser = Nori.new(convert_tags_to: lambda {|tag| tag.gsub('s:', '').snakecase.to_sym })
          parser.parse(response.body)
        else
          puts "Failed"
          puts response.body
        end
      end
    end
  end
end