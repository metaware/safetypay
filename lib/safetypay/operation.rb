require 'dry-types'
require 'dry-struct'
require 'safetypay/express_token_request'

module Safetypay
  class Operation < Dry::Struct
    constructor :symbolized

    attribute :operation_id, Dry::Types['strict.string']
    attribute :creation_date_time, Dry::Types['strict.date_time']
    attribute :merchant_sales_id, Dry::Types['strict.string']
    attribute :merchant_order_id, Dry::Types['coercible.string']
    attribute :amount, Dry::Types['coercible.float']
    attribute :currency_id, Safetypay::ExpressTokenRequest::Currencies
    attribute :shopper_amount, Dry::Types['coercible.float']
    attribute :shopper_currency_id, Dry::Types['strict.string']
    attribute :operation_activities, Dry::Types['hash']

    def id
      operation_id
    end

    def status
      status = operation_activities[:operation_activity][:status]
      status[:status_code]
    end

    def paid?
      status = operation_activities[:operation_activity][:status]
      status[:status_code] == "102" && status[:description] == "Paid"
    end

    def confirm!
      confirmation = Client.confirm_new_operations_activity(operation: self)
      confirmation.confirmed?
    end

  end
end