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
          config.environment = :sandbox
        end
      end
      let(:api_key) { 'd5fcfaa9bb44f48bc6e95c2940666048' }
      let(:signature_key) { '674cbb669d441b18ba5eb27739a15403' }
      let(:token_request) do
        Safetypay::ExpressTokenRequest.new({
          MerchantSalesID: 'Order12345',
          ExpirationTime: 100,
          ShopperEmail: 'shopper@email.com',
          Amount: 113.13,
          TransactionOkURL: 'http://vai.car/ok',
          TransactionErrorURL: 'http://vai.car/fail'
        })
      end

      it 'returns an instance of client' do
        subject
        expect { Safetypay::Client.create_express_token(request: token_request) }.not_to raise_error
      end
    end
  end

  context '.create_express_token' do
  end
end
