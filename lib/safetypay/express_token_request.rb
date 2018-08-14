require 'dry-types'
require 'dry-struct'
require 'digest'
require 'symbolized'

module Safetypay
  class ExpressTokenRequest < Dry::Struct

    # Product ID Codes: Thank you Safetypay for Magic Numbers!
    # 1: SafetyPay Express
    # 2: SafetyPay Cash
    # 3: Direct
    # 4: CallCenter
    # 5: Gateway - MWS/Api
    # 6: Payout
    # 7: EBiller
    # 8: SafetyPay Dual Button
    # 9: Domestic Credit Card
    # 10: International Credit Card
    # 11: International Payment
    ProductIDS = Dry::Types['strict.integer'].default(2).enum(*(1..11).to_a)
    Currencies = Dry::Types['strict.string'].default('BRL').enum('BRL', 'USD')
    Languages = Dry::Types['strict.string'].default('PT').enum('EN', 'PT')

    attribute :CurrencyID, Currencies
    attribute :Language, Languages
    attribute :ProductID, ProductIDS
    attribute :MerchantSalesID, Dry::Types['strict.string'].constrained(max_size: 20)
    attribute :ExpirationTime, Dry::Types['strict.integer'].constrained(lteq: 24*60)
    attribute :ShopperEmail, Dry::Types['strict.string']
    attribute :Amount, Dry::Types['strict.float']
    attribute :TransactionOkUrl, Dry::Types['strict.string']
    attribute :TransactionErrorUrl, Dry::Types['strict.string']

    def to_h
      hash = {
        CurrencyID: self.CurrencyID,
        Language: self.Language,
        ProductID: self.ProductID,
        MerchantSalesID: self.MerchantSalesID,
        ExpirationTime: self.expiration_time,
        ShopperEmail: self.ShopperEmail,
        Amount: self.amount,
        TransactionOkUrl: self.TransactionOkUrl,
        TransactionErrorUrl: self.TransactionErrorUrl,
        Signature: self.signature
      }
      SymbolizedHash.new(hash)
    end

    def expiration_time
      self.ExpirationTime.to_s
    end

    def amount
      # Amount should always have 
      # 2 decimal place precision
      '%.2f' % self.Amount
    end

    def signature
      data = self.CurrencyID + self.amount + self.MerchantSalesID + self.Language + self.expiration_time + self.TransactionOkUrl + self.TransactionErrorUrl
      Digest::SHA256.hexdigest(data + Safetypay::Client.signature_key)
    end

    def soap_action
      "urn:safetypay:contract:mws:api:CreateExpressToken"
    end

    def operation_name
      :ExpressTokenRequest
    end
  end
end