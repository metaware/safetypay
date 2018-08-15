RSpec.describe Safetypay::Client do
  context 'initialization' do
    context 'fails' do
      subject do
        Safetypay::Client.configure do |config|
          config.api_key = api_key
          config.signature_key = signature_key
        end
      end
      let(:api_key) { nil }
      let(:signature_key) { nil }

      it 'fails initialization when api key or signature key are not assigned' do
        subject
        expect { Safetypay::Client.create_express_token }.to raise_error(Safetypay::FailedInitialization)
      end
    end

    context 'succeeds' do
      subject do
        Safetypay::Client.configure do |config|
          config.api_key = api_key
          config.signature_key = signature_key
        end
      end
      let(:api_key) { 'something' }
      let(:signature_key) { 'something' }

      it 'returns an instance of client' do
        subject
        expect { Safetypay::Client.create_express_token }.not_to raise_error
      end
    end
  end

  context '.create_express_token' do
  end
end
