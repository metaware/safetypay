RSpec.describe Safetypay::ExpressTokenRequest do
  context 'initialization' do    
    subject { Safetypay::ExpressTokenRequest.new(payload) }
    let(:payload) { nil }

    context 'fails' do
      it 'cannot be created empty' do
        expect { subject }.to raise_error(Dry::Struct::Error)
      end
    end

    context 'succeeds' do
      let(:amount) { 100.00 }
      let(:expiration_time) { 120 }
      let(:merchant_sales_id) { 'Order #12345' }
      let(:merchant_order_id) { '12345' }
      let(:email) { 'shopper@domain.com' }
      let(:payload) do
        {
          MerchantOrderID: merchant_order_id,
          MerchantSalesID: merchant_sales_id,
          ExpirationTime: expiration_time,
          ShopperEmail: email,
          Amount: amount,
          TransactionOkURL: 'http://vai.car/ok',
          TransactionErrorURL: 'http://vai.car/fail'
        }
      end

      it 'can be created' do
        expect(subject).to be_a_kind_of(Safetypay::ExpressTokenRequest)
      end

      it 'sets the default language to EN' do
        expect(subject.Language).to eq('EN')
      end

      it 'sets the default currency to BRL' do
        expect(subject.CurrencyID).to eq('BRL')
      end

      it 'sets the amount properly' do
        expect(subject.Amount).to eq(100.00)
      end

      it 'sets the transactionokurl' do
        expect(subject.TransactionOkURL).to eq('http://vai.car/ok')
      end

      it 'sets the transactionerrorurl' do
        expect(subject.TransactionErrorURL).to eq('http://vai.car/fail')
      end

      it 'generates a signature' do
        expect(subject.signature).to_not be_empty
      end

      context '#operation_name' do
        it 'should be set' do
          expect(subject.operation_name).to eq(:ExpressTokenRequest)
        end
      end

      context '#soap_action' do
        it 'should be set' do
          expect(subject.soap_action).to eq('urn:safetypay:contract:mws:api:CreateExpressToken')
        end
      end

      context 'excessively long merchant sales id (beyond 256 chars)' do
        let(:merchant_sales_id) { 'A' * 257 }
        it 'is not acceptable' do
          expect { subject }.to raise_error(Dry::Struct::Error)
        end
      end

      context '#expiration_time' do
        it 'should return a string' do
          expect(subject.expiration_time).to be_a_kind_of(String)
        end

        context 'float value' do
          let(:expiration_time) { 300.00 }

          it 'is not acceptable' do
            expect { subject }.to raise_error(Dry::Struct::Error)
          end
        end

        context 'string value' do
          let(:expiration_time) { '300' }

          it 'is not acceptable' do
            expect { subject }.to raise_error(Dry::Struct::Error)
          end
        end

        context 'value above 24 hours' do
          let(:expiration_time) { 1440 + 1 }

          it 'is not acceptable' do
            expect { subject }.to raise_error(Dry::Struct::Error)
          end
        end
      end

      context '#amount' do
        it 'returns a string representation of amount' do
          expect(subject.amount).to eq('100.00')
        end

        context 'precision' do
          let(:amount) { 3.142 }
          it 'is always upto 2 decimal places' do
            expect(subject.amount).to eq('3.14')
          end
        end

        context 'int amounts' do
          let(:amount) { 300 }
          it 'are not acceptable' do
            expect { subject }.to raise_error(Dry::Struct::Error)
          end
        end
      end

      context '#to_h' do
        it 'can be converted to a hash' do
          hash = subject.to_h
          expect(hash['Language']).to eq('EN')
          expect(hash['MerchantSalesID']).to eq('Order #12345')
          expect(hash['Amount']).to eq('100.00')
          expect(hash['CurrencyID']).to eq('BRL')
          expect(hash['TransactionOkURL']).to eq('http://vai.car/ok')
          expect(hash['TransactionErrorURL']).to eq('http://vai.car/fail')
          expect(hash['ShopperEmail']).to eq('shopper@domain.com')
        end

        it 'is capable of returning a hash with indifferent access' do
          hash = subject.to_h
          expect(hash['Language']).to eq('EN')
          expect(hash['Language']).to eq(hash[:Language])

          expect(hash['MerchantSalesID']).to eq('Order #12345')
          expect(hash['MerchantSalesID']).to eq(hash[:MerchantSalesID])
        end
      end
    end
  end
end
