module Safetypay
  class GetNewOperationsActivityRequest
    attr_accessor :request_date_time
    def initialize
      self.request_date_time = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S')
    end

    def to_h
      {
        RequestDateTime: self.request_date_time,
        Signature: self.signature
      }
    end

    def signature_data
      self.request_date_time
    end

    def signature
      Digest::SHA256.hexdigest(self.signature_data + Safetypay::Client.signature_key)
    end

    def operation_name
      :OperationActivityRequest
    end

    def soap_action
      "urn:safetypay:contract:mws:api:GetNewOperationActivity"
    end
  end
end