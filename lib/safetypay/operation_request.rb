module Safetypay
  class OperationRequest
    attr_accessor :merchant_sales_id, :request_date_time

    def initialize(merchant_sales_id: nil)
      self.merchant_sales_id = merchant_sales_id
      self.request_date_time = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S')
    end

    def to_h
      {
        MerchantSalesID: self.merchant_sales_id,
        RequestDateTime: self.request_date_time,
        Signature: self.signature
      }
    end

    def signature_data
      self.request_date_time + self.merchant_sales_id
    end

    def signature
      Digest::SHA256.hexdigest(self.signature_data + Safetypay::Client.signature_key)
    end

    def soap_action
      "urn:safetypay:contract:mws:api:GetOperation"
    end

    def operation_name
      :OperationRequest
    end
  end
end