require 'ox'

module Safetypay
  class RequestFormatter

    def self.format(payload: nil)
      validate_payload(payload)
      xml = build_xml(payload)
      xml
    end

    def self.build_xml(payload)
      doc = Ox::Document.new
      top = Ox::Element.new('soapenv:Envelope')
      top['xmlns:soapenv'] = 'http://schemas.xmlsoap.org/soap/envelope/'
      top['xmlns:urn'] = 'urn:safetypay:messages:mws:api'
      
      header = Ox::Element.new('soapenv:Header')
      body = Ox::Element.new('soapenv:Body')
      request = Ox::Element.new("urn:#{payload.operation_name}")

      hash = payload.to_h.merge(ApiKey: Client.api_key)

      build_node(hash) do |node|
        request << node
      end

      body << request
      top << header
      top << body
      doc << top
      Ox.dump(doc)
    end

    def self.build_node(value)
      if value.is_a?(Hash)
        value.each do |key, val|
          node = Ox::Element.new("urn:#{key}")
          build_node(val) do |inner_node|
            node << inner_node
          end
          yield(node)
        end
      end
      if value.is_a?(String) || value.is_a?(Numeric)
        node = value.to_s
        yield(node)
      end
      if value.is_a?(Array)
        value.each_with_index do |elem, index|
          key = elem.keys.first
          node = Ox::Element.new("urn:#{key}")
          build_node(elem[key]) do |inner_node|
            node << inner_node
          end
          yield(node)
        end
      end
    end

    private
    def self.validate_payload(payload)
      if payload.nil?
        raise Safetypay::InvalidRequest, 'Payload is empty. Nothing to format'
      end
      hash = {
        to_h: payload.respond_to?(:to_h),
        soap_action: payload.respond_to?(:soap_action),
        operation_name: payload.respond_to?(:operation_name)
      }
      invalid = hash.any? {|key, value| value == false}
      keys = hash.select {|key, value| value == false}.keys
      if invalid
        raise Safetypay::InvalidRequest, "Payload does not implement #{keys.join(', ')}"
      end
    end
    
  end
end