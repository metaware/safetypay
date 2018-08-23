require "bundler/setup"
require "safetypay"
require "pry"
require "rspec-html-matchers"

RSpec.shared_examples "a safetypay request" do
  let(:request) { described_class.new }

  context "mandatory methods" do
    it "#soap_action" do
      expect(request).to respond_to(:soap_action)
    end

    it "#operation_name" do
      expect(request).to respond_to(:operation_name)
    end

    it "#to_h" do
      expect(request).to respond_to(:to_h)
    end

    it "#signature" do
      expect(request).to respond_to(:signature)
    end

    it "#signature_data" do
      expect(request).to respond_to(:signature)
    end
  end
end

RSpec.configure do |config|
  config.include RSpecHtmlMatchers
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    Safetypay::Client.configure do |config|
      config.api_key = 'something'
      config.signature_key = 'something'
    end
  end
end
