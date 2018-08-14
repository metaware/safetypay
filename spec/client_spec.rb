RSpec.describe Safetypay::Client do
  context 'initialization' do
    subject { Safetypay::Client.new(api_key: api_key, signature_key: signature_key) }

    context 'fails' do
      let(:api_key) { nil }
      let(:signature_key) { nil }

      it 'fails initialization when api key or signature key are not assigned' do
        expect { subject }.to raise_error(Safetypay::FailedInitialization)
      end
    end

    context 'succeeds' do
      let(:api_key) { 'something' }
      let(:signature_key) { 'something' }

      it 'returns an instance of client' do
        expect(subject).to be_a_kind_of(Safetypay::Client)
      end
    end
  end
end
