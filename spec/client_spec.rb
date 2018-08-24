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

    context 'default environment' do
      subject do
        Safetypay::Client.configure do |config|
          config.api_key = api_key
          config.signature_key = signature_key
        end
      end

      let(:api_key) { 'test-api-key' }
      let(:signature_key) { 'test-signature-key' }
      
      it 'environment gets set to test' do
        subject
        expect(Safetypay::Client.config.environment).to eq('test')
      end
    end

    context 'live environment' do
      subject do
        Safetypay::Client.configure do |config|
          config.api_key = api_key
          config.signature_key = signature_key
          config.environment = :live
        end
      end

      let(:api_key) { 'test-api-key' }
      let(:signature_key) { 'test-signature-key' }
      
      it 'environment gets set to live' do
        subject
        expect(Safetypay::Client.config.environment).to eq('live')
      end
    end
  end

  context '.create_express_token' do
    let(:api_key) { 'd5fcfaa9bb44f48bc6e95c2940666048' }
    let(:signature_key) { '674cbb669d441b18ba5eb27739a15403' }

    context 'succeeds' do
      subject do
        Safetypay::Client.configure do |config|
          config.api_key = api_key
          config.signature_key = signature_key
        end
      end

      let(:token_request) do
        Safetypay::ExpressTokenRequest.new({
          MerchantSalesID: 'Order12345',
          TrackingCode: '12345',
          ExpirationTime: 100,
          ShopperEmail: 'shopper@email.com',
          Amount: 113.13,
          TransactionOkURL: 'http://vai.car/ok',
          TransactionErrorURL: 'http://vai.car/fail'
        })
      end

      before(:each) do
        subject
      end

      let(:token) { Safetypay::Client.create_express_token(request: token_request) }

      it 'and does not crash' do
        expect { token }.not_to raise_error
      end

      it 'returns an express token' do
        expect(token).to be_a_kind_of(Safetypay::ExpressToken)
      end

      it 'should be a valid token' do
        expect(token.valid?).to be true
      end

      it 'should not be invalid' do
        expect(token.invalid?).to be false
      end
    end

    context 'fails' do
      subject do
        Safetypay::Client.configure do |config|
          config.api_key = api_key
          config.signature_key = signature_key
        end
      end

      let(:token_request) do
        Safetypay::ExpressTokenRequest.new({
          TrackingCode: merchant_order_id,
          MerchantSalesID: merchant_sales_id,
          ExpirationTime: 100,
          ShopperEmail: 'shopper@email.com',
          Amount: amount,
          TransactionOkURL: 'http://vai.car/ok',
          TransactionErrorURL: 'http://vai.car/fail'
        })
      end

      before(:each) do
        subject
      end

      let(:amount) { 113.13 }
      let(:merchant_sales_id) { 'Order 12345' }
      let(:merchant_order_id) { '12345' }
      let(:token) { Safetypay::Client.create_express_token(request: token_request) }

      context 'when amount is an Integer' do
        let(:amount) { 0 }

        it 'should crash' do
          expect { token }.to raise_error(Dry::Struct::Error)
        end
      end

      context 'when amount is invalid float' do
        let(:amount) { 0.0 }

        it 'should return an invalid token' do
          expect(token.valid?).to be false
          expect(token.invalid?).to be true
        end
      end

      context 'when MerchantSalesId is excessively long' do
        let(:merchant_sales_id) { 'A' * 257 }

        it 'causes an error' do
          expect { token }.to raise_error(Dry::Struct::Error)
        end
      end

      context 'when MerchantSalesId is nil' do
        let(:merchant_sales_id) { nil }

        it 'causes an error' do
          expect { token }.to raise_error(Dry::Struct::Error)
        end
      end
    end
  end
end
