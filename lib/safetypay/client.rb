require 'dry-configurable'
require 'net/http'
require 'nori'
require 'safetypay/confirm_operation_request'
require 'safetypay/operation'
require 'safetypay/operation_request'
require 'safetypay/operation_confirmation'

module Safetypay
  class Client
    extend Dry::Configurable

    setting :request_callback, reader: true
    setting :response_callback, reader: true

    setting :api_key, reader: true
    setting :signature_key, reader: true
    setting(:environment, 'test') do |value|
      value.to_s
    end
  
    def self.endpoint
      if self.config.environment == "live"
        URI.parse("https://mws2.safetypay.com/express/ws/v.3.0")
      else
        URI.parse("https://sandbox-mws2.safetypay.com/express/ws/v.3.0")
      end
    end

    def self.create_express_token(request: nil)
      self.validate_credentials
      response = Safetypay::Communicator.make_request(request)
      response = response.fetch(:envelope, {}).fetch(:body, {}).fetch(:express_token_response)
      Safetypay::ExpressToken.new(response)
    end

    def self.get_new_operations_activity
      self.validate_credentials
      request = GetNewOperationsActivityRequest.new
      response = Communicator.make_request(request)
      response = response
                  .fetch(:envelope, {})
                  .fetch(:body, {})
                  .fetch(:operation_response, {})
                  .fetch(:list_of_operations, {})
                  .fetch(:operation, [])
      if response.is_a?(Hash)
        Array(Operation.new(response))
      else
        response.map { |operation| Operation.new(operation) }
      end
    end

    def self.confirm_new_operations_activity(operation: nil)
      self.validate_credentials
      request = ConfirmOperationRequest.new(operation: operation)
      response = Communicator.make_request(request)
      confirmation = response
        .fetch(:envelope, {})
        .fetch(:body, {})
        .fetch(:operation_activity_notified_response, {})
      OperationConfirmation.new(confirmation)
    end

    def self.get_operation(merchant_sales_id: nil)
      self.validate_credentials
      request = OperationRequest.new(merchant_sales_id: merchant_sales_id)
      response = Communicator.make_request(request)
      response = response
        .fetch(:envelope, {})
        .fetch(:body, {})
        .fetch(:operation_response)
        .fetch(:list_of_operations, {})
        .fetch(:operation, nil)
    end

    def self.validate_credentials
      if !self.api_key || !self.signature_key
        raise Safetypay::FailedInitialization
      end
    end
  end

  class Communicator
    def self.make_request(payload, &block)
      Net::HTTP.start(Client.endpoint.host, 443, use_ssl: true) do |http|
        request = Net::HTTP::Post.new(Client.endpoint.request_uri)
        request.content_type = 'text/xml'
        request['SoapAction'] = payload.soap_action
        request.body = RequestFormatter.format(payload: payload)
        
        Client.request_callback.call(request.body) unless Client.request_callback.blank?
        response = http.request request
        Client.response_callback.call(response.body) unless Client.response_callback.blank?

        parser = Nori.new(convert_tags_to: lambda {|tag| tag.gsub('s:', '').snakecase.to_sym })
        parser.parse(response.body)
      end
    end
  end
end