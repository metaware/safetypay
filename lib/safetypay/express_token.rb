require 'dry-types'
require 'dry-struct'

module Safetypay
  class ExpressToken < Dry::Struct

    constructor :symbolized

    attribute :shopper_redirect_url, Dry::Types['string'].meta(omittable: true)
    attribute :error_manager, Dry::Types['hash'].meta(omittable: true).schema(
      error_number: Dry::Types['coercible.integer'].optional,
      description: Dry::Types['strict.string'].optional,
    )

    def invalid?
      return false if valid?
      return true
    end

    def valid?
      return false if shopper_redirect_url.blank?
      uri = URI.parse(shopper_redirect_url)
      return true if uri.host =~ /safetypay.com/
    end

  end
end