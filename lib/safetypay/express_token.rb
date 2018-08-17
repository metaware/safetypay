require 'dry-types'
require 'dry-struct'

module Safetypay
  class ExpressToken < Dry::Struct

    # # Product ID Codes: Thank you Safetypay for Magic Numbers!
    # # 1: SafetyPay Express
    # # 2: SafetyPay Cash
    # # 3: Direct
    # # 4: CallCenter
    # # 5: Gateway - MWS/Api
    # # 6: Payout
    # # 7: EBiller
    # # 8: SafetyPay Dual Button
    # # 9: Domestic Credit Card
    # # 10: International Credit Card
    # # 11: International Payment
    # ProductIDS = Dry::Types['strict.integer'].default(2).enum(*(1..11).to_a)
    # Currencies = Dry::Types['strict.string'].default('BRL').enum('BRL', 'USD')
    # Languages = Dry::Types['strict.string'].default('PT').enum('EN', 'PT')

    attribute :CurrencyID, Currencies
    attribute :Language, Languages
    attribute :ProductID, ProductIDS
    attribute :MerchantSalesID, Dry::Types['strict.string'].constrained(max_size: 20)
    attribute :ExpirationTime, Dry::Types['strict.integer'].constrained(lteq: 24*60)
    attribute :ShopperEmail, Dry::Types['strict.string']
    attribute :Amount, Dry::Types['strict.float']
    attribute :TransactionOkURL, Dry::Types['strict.string']
    attribute :TransactionErrorURL, Dry::Types['strict.string']

  end
end