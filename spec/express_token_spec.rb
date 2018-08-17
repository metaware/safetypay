RSpec.describe Safetypay::ExpressToken do
  context 'initialization' do
    let(:token) { Safetypay::ExpressToken.new(raw_token) }
    
    context 'invalid?' do
      context 'empty hash' do
        let(:raw_token) { {} }
        it 'renders the token invalid' do
          expect(token.invalid?).to eq(true)
        end
      end

      context 'nil' do
        let(:raw_token) { nil }
        it 'renders the token invalid' do
          expect(token.invalid?).to eq(true)
        end
      end

      context 'error manager number > 0' do
        let(:raw_token) do 
          { error_manager: { error_number: 0, description: 'something' } }
        end
        it 'renders the token invalid' do
          expect(token.invalid?).to eq(true)
        end
      end

      context 'url to redirect to does not contain "safetypay"' do
        let(:mock_url) { "https://sandbox-gateway.safetypay-like-site.com/Express4/Checkout/index?TokenID=blah" }
        let(:raw_token) do
          { 
            shopper_redirect_url: mock_url,
            error_manager: {
              error_number: 0,
              description: "All Looks Good!"
            }
          }
        end

        it 'renders the token invalid' do
          expect(token.invalid?).to eq(true)
        end
      end
    end

    context 'valid?' do
      context 'when valid redirect url' do
        let(:mock_url) { "https://sandbox-gateway.safetypay.com/Express4/Checkout/index?TokenID=blah" }
        let(:raw_token) do
          { 
            shopper_redirect_url: mock_url,
            error_manager: {
              error_number: 0,
              description: "All Looks Good!"
            }
          }
        end

        it 'should be true' do
          expect(token.valid?).to eq(true)
        end
      end

      context 'when error number is a string' do
        let(:mock_url) { "https://sandbox-gateway.safetypay.com/Express4/Checkout/index?TokenID=blah" }
        let(:raw_token) do
          { 
            shopper_redirect_url: mock_url,
            error_manager: {
              error_number: "12323",
              description: "All Looks Good!"
            }
          }
        end

        it 'should be true' do
          expect(token.valid?).to eq(true)
        end

        it 'should cast error number to integer' do
          expect(token.error_manager[:error_number]).to eq(12323)
        end
      end
    end
  end
end
