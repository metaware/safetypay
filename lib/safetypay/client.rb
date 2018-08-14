module Safetypay
  class Client

    attr_reader :api_key, :signature_key

    def initialize(api_key: nil, signature_key: nil)
      if !api_key || !signature_key
        raise Safetypay::FailedInitialization
      end
      @api_key = api_key
      @signature_key = signature_key
    end

  end
end