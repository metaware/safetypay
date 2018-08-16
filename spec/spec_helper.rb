require "bundler/setup"
require "safetypay"
require "pry"
require "rspec-html-matchers"

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
      config.api_key = 'something_before'
      config.signature_key = 'something_before'
    end
  end
end
