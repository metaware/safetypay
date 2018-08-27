module Safetypay
  class ConfirmOperationRequest
    attr_accessor :request_date_time, :operation
    def initialize(operation: nil)
      self.request_date_time = Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S')
      self.operation = operation
    end

    def to_h
      {
        RequestDateTime: self.request_date_time,
        ListOfOperationsActivityNotified: [{
          ConfirmOperation: {
            OperationID: self.operation.operation_id,
            MerchantSalesID: self.operation.merchant_sales_id,
            MerchantOrderID: self.operation.merchant_order_id,
            OperationStatus: self.operation.status
          }
        }],
        Signature: self.signature
      }
    end

    def signature_data
      self.request_date_time +
        self.operation.operation_id +
        self.operation.merchant_sales_id +
        self.operation.merchant_order_id +
        self.operation.status
    end

    def signature
      Digest::SHA256.hexdigest(self.signature_data + Safetypay::Client.signature_key)
    end

    def operation_name
      :OperationActivityNotifiedRequest
    end

    def soap_action
      "urn:safetypay:contract:mws:api:ConfirmNewOperationActivity"
    end
  end
end