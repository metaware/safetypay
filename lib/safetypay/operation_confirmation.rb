require 'dry-types'
require 'dry-struct'

module Safetypay
  class OperationConfirmation < Dry::Struct

    constructor :symbolized

    attribute :response_date_time, Dry::Types['strict.date_time'].meta(omittable: true)
    attribute :error_manager, Dry::Types['hash'].meta(omittable: true).schema(
      error_number: Dry::Types['coercible.integer'].optional,
      description: Dry::Types['strict.string'].optional,
      severity: Dry::Types['strict.string'].optional,
    )

    def confirmed?
      error_manager[:error_number] == 0
    end
  end
end