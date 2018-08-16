require "safetypay/version"
require "safetypay/client"
require "safetypay/express_token_request"
require "safetypay/request_formatter"

module Safetypay
  class FailedInitialization < StandardError; end
  class InvalidRequest < StandardError; end
end
