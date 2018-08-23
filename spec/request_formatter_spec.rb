RSpec.describe Safetypay::RequestFormatter do
  context '.format' do
    subject { Safetypay::RequestFormatter.format(payload: payload) }
    
    context 'generic implementation' do
      context 'payload is nil' do
        let(:payload) { nil }
        it 'should raise error' do
          expect { subject }.to raise_error(Safetypay::InvalidRequest, 'Payload is empty. Nothing to format')
        end
      end

      context 'payload does not respond to any of the required methods' do
        let(:payload) { double() }
        it 'should raise error' do
          expect { subject }.to raise_error(Safetypay::InvalidRequest, 'Payload does not implement to_h, soap_action, operation_name')
        end
      end

      context 'payload responds to one of the methods: soap_action' do
        let(:payload) { double(soap_action: 'hey') }
        it 'should raise error' do
          expect { subject }.to raise_error(Safetypay::InvalidRequest, 'Payload does not implement to_h, operation_name')
        end
      end

      context 'payload responds to all of the required methods' do
        let(:payload) { double(soap_action: 'hey', operation_name: '', to_h: {}) }
        it 'should NOT raise error' do
          expect { subject }.to_not raise_error
        end
      end

      context 'simple payload' do
        let(:soap_action) { 'hellosoap:action' }
        let(:operation_name) { 'hellosoap' }
        let(:payload) do
          double(
            to_h: { Name: "Thanos", Dream: "Collect Infinity Stones" },
            soap_action: soap_action,
            operation_name: operation_name
          )
        end

        context "XML generation" do
          let(:doc) { Nokogiri::XML(subject) }

          it 'should always generate default parent nodes' do
            expect(doc.xpath("/soapenv:Envelope")).to_not be_empty
            expect(doc.xpath("/soapenv:Envelope/soapenv:Header")).to_not be_empty
          end

          it 'should generate child nodes as per payload' do
            expect(doc.xpath("//urn:hellosoap")).to_not be_empty

            expect(doc.xpath("//urn:hellosoap/urn:Name")).to_not be_empty
            expect(doc.xpath("//urn:hellosoap/urn:Name").text).to eq('Thanos')

            expect(doc.xpath("//urn:hellosoap/urn:Dream")).to_not be_empty
            expect(doc.xpath("//urn:hellosoap/urn:Dream").text).to eq('Collect Infinity Stones')
          end
        end
      end

      context 'nested formatting' do
        let(:soap_action) { 'hellosoap:action' }
        let(:operation_name) { 'hellosoap' }
        let(:payload) do
          double(
            to_h: { 
              Name: "Thanos", 
              Dream: "Collect Infinity Stones",
              Children: [{
                Daughter: {
                  Name: 'Gamora',
                  Color: 'Green'
                }
              }, {
                Daughter: {
                  Name: 'Nebula',
                  Color: 'Blue'
                }
              }]
            },
            soap_action: soap_action,
            operation_name: operation_name
          )
        end

        context "XML generation" do
          let(:doc) { Nokogiri::XML(subject) }

          it 'should always generate default parent nodes' do
            expect(doc.xpath("/soapenv:Envelope")).to_not be_empty
            expect(doc.xpath("/soapenv:Envelope/soapenv:Header")).to_not be_empty
          end

          it 'should generate child nodes as per payload' do
            expect(doc.xpath("//urn:hellosoap")).to_not be_empty

            expect(doc.xpath("//urn:hellosoap/urn:Name")).to_not be_empty
            expect(doc.xpath("//urn:hellosoap/urn:Name").text).to eq('Thanos')

            expect(doc.xpath("//urn:hellosoap/urn:Dream")).to_not be_empty
            expect(doc.xpath("//urn:hellosoap/urn:Dream").text).to eq('Collect Infinity Stones')
          end

          it 'should generate child of children nodes' do
            expect(doc.xpath("//urn:Children")).to_not be_empty

            expect(doc.xpath("//urn:Children/urn:Daughter/urn:Name").size).to eq(2)
            expect(doc.xpath("//urn:Children/urn:Daughter/urn:Color").size).to eq(2)

            expect(doc.xpath("//urn:Children/urn:Daughter[1]/urn:Name").text).to eq('Gamora')
            expect(doc.xpath("//urn:Children/urn:Daughter[2]/urn:Name").text).to eq('Nebula')
          end
        end
      end
    end

    context 'actual formatting' do
      let(:operation_name) { 'ExpressTokenRequest' }
      let(:payload) do 
        Safetypay::ExpressTokenRequest.new({
          MerchantOrderID: '12345',
          MerchantSalesID: 'Order 12345',
          ExpirationTime: 100,
          ShopperEmail: 'shopper@email.com',
          Amount: 113.13,
          TransactionOkURL: 'http://vai.car/ok',
          TransactionErrorURL: 'http://vai.car/fail'
        })
      end
      let(:doc) { Nokogiri::XML(subject) }

      it 'should work' do
        expect(doc.xpath("/soapenv:Envelope")).to_not be_empty
        expect(doc.xpath("/soapenv:Envelope/soapenv:Header")).to_not be_empty
        expect(doc.xpath("/soapenv:Envelope/soapenv:Body")).to_not be_empty
        expect(doc.xpath("//urn:Signature")).to_not be_empty
      end

      it 'should generate requested attributes' do
        currency_id = doc.xpath("//urn:CurrencyID")
        language = doc.xpath("//urn:Language")
        product_id = doc.xpath("//urn:ProductID")
        merchant_sales_id = doc.xpath("//urn:MerchantSalesID")
        merchant_order_id = doc.xpath("//urn:MerchantOrderID")
        shopper_email = doc.xpath("//urn:ShopperEmail")
        amount = doc.xpath("//urn:Amount")
        ok_url = doc.xpath("//urn:TransactionOkURL")
        error_url = doc.xpath("//urn:TransactionErrorURL")

        expect(currency_id).to_not be_empty
        expect(language).to_not be_empty
        expect(product_id).to_not be_empty
        expect(merchant_sales_id).to_not be_empty
        expect(merchant_order_id).to_not be_empty
        expect(shopper_email).to_not be_empty
        expect(amount).to_not be_empty
        expect(ok_url).to_not be_empty
        expect(error_url).to_not be_empty

        expect(currency_id.text).to eq('BRL')
        expect(language.text).to eq('EN')
        expect(product_id.text).to eq('2')
        expect(merchant_sales_id.text).to eq('Order 12345')
        expect(merchant_order_id.text).to eq('12345')
        expect(shopper_email.text).to eq('shopper@email.com')
        expect(amount.text).to eq('113.13')
        expect(ok_url.text).to eq('http://vai.car/ok')
        expect(error_url.text).to eq('http://vai.car/fail')
      end
    end
  end
end
