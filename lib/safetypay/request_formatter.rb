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

      payload.to_h.each do |key, value|
        elem = Ox::Element.new("urn:#{key}")
        elem << value.to_s
        request << elem
      end

      body << request
      top << header
      top << body
      doc << top
      Ox.dump(doc)
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