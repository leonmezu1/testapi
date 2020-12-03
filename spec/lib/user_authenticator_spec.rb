require 'rails_helper'

describe UserAuthenticator do
  describe '.perform' do
    let(:authenticator) { described_class.new('sample_code') }
    subject { authenticator.perform }
    context 'when code is incorrect' do
      it 'should raise an error' do
        expect(authenticator.user).to be_nil
      end
    end

    context 'when code is correct' do
      it 'should save the user when does not exist' do
        expect { subject }.to change { User.count }.by(1)
      end
    end
  end
end
