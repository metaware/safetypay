require 'dry-configurable'

module Safetypay
  class Client
    extend Dry::Configurable

    setting :api_key, reader: true
    setting :signature_key, reader: true

    def self.create_express_token(express_request: nil)
      self.validate_credentials
    end

    def self.validate_credentials
      if !self.api_key || !self.signature_key
        raise Safetypay::FailedInitialization
      end
    end
  end
end