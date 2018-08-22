require 'dry-types'
require 'dry-struct'
require 'digest'
require 'symbolized'

module Safetypay
  class ExpressTokenRequest < Dry::Struct

    constructor :symbolized

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
    Languages = Dry::Types['strict.string'].default('EN').enum('EN', 'PT')

    attribute :CurrencyID, Currencies
    attribute :Language, Languages
    attribute :ProductID, ProductIDS
    attribute :RequestDateTime, Dry::Types['strict.string'].default(Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S'))
    attribute :MerchantSalesID, Dry::Types['strict.string'].constrained(max_size: 20)
    attribute :MerchantOrderID, Dry::Types['strict.string'].constrained(max_size: 20)
    attribute :ExpirationTime, Dry::Types['strict.integer'].constrained(lteq: 24*60)
    attribute :ShopperEmail, Dry::Types['strict.string']
    attribute :Amount, Dry::Types['strict.float']
    attribute :TransactionOkURL, Dry::Types['strict.string']
    attribute :TransactionErrorURL, Dry::Types['strict.string']

    def to_h
      hash = {
        RequestDateTime: self.RequestDateTime,
        CurrencyID: self.CurrencyID,
        Language: self.Language,
        ProductID: self.ProductID,
        MerchantSalesID: self.MerchantSalesID,
        MerchantOrderID: self.MerchantOrderID,
        ExpirationTime: self.expiration_time,
        ShopperEmail: self.ShopperEmail,
        Amount: self.amount,
        TransactionOkURL: self.TransactionOkURL,
        TransactionErrorURL: self.TransactionErrorURL,
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

    def signature_data
      self.RequestDateTime + self.CurrencyID + self.amount + self.MerchantSalesID + self.Language + self.expiration_time + self.TransactionOkURL + self.TransactionErrorURL
    end

    def signature
      Digest::SHA256.hexdigest(self.signature_data + Safetypay::Client.signature_key)
    end

    def soap_action
      "urn:safetypay:contract:mws:api:CreateExpressToken"
    end

    def operation_name
      :ExpressTokenRequest
    end
  end
end