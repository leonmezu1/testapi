require 'rails_helper'

describe AccessTokensController do
  describe '#create' do
    shared_examples_for 'unauthorized_request' do
      let(:error) do
        {
          'status' => '401',
          'source' => { 'pointer' => '/code' },
          'title' => 'Authentication code is invalid',
          'detail' => 'You must provide a valid authentication code'
        }
      end

      it 'should have 401 status code' do
        subject
        expect(response).to have_http_status(401)
      end

      it 'should return a proper error body' do
        subject
        expect(json['errors']).to include(error)
      end
    end

    context 'when no code is provided' do
      subject { post :create }
      it_behaves_like 'unauthorized_request'
    end

    context 'when invalid code is provided' do
      let(:github_error) do
        double('Sawyer::Resource', error: 'bad_verification_code')
      end

      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token
        ).and_return(github_error)
      end

      subject { post :create, params: { code: 'invalid_code' } }
      it_behaves_like 'unauthorized_request'
    end

    context 'when success request' do
      let(:user_data) do
        {
          login: 'jsmith1',
          url: 'http://example.com',
          avatar_url: 'http://example.com/avatar',
          name: 'John Smith'
        }
      end

      before do
        allow_any_instance_of(Octokit::Client).to receive(
          :exchange_code_for_token
        ).and_return('validaccesstoken')

        allow_any_instance_of(Octokit::Client).to receive(
          :user
        ).and_return(user_data)
      end

      subject { post :create, params: { code: 'valid_code' } }
      it 'should return 201 status code' do
        subject
        expect(response).to have_http_status(:created)
      end

      it 'should return proper json body' do
        expect { subject }.to change { User.count }.by(1)
        user = User.find_by(login: 'jsmith1')
        expect(json_data['attributes']).to eq(
          { 'token' => user.access_token.token }
        )
      end
    end
  end
end
