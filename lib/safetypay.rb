require "safetypay/version"
require "safetypay/operation"
require "safetypay/express_token"
require "safetypay/express_token_request"
require "safetypay/request_formatter"
require "safetypay/get_new_operations_activity_request"
require "safetypay/client"

module Safetypay
  class FailedInitialization < StandardError; end
  class InvalidRequest < StandardError; end
end
