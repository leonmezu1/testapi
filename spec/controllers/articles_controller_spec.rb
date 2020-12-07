require 'rails_helper'

describe ArticlesController do
  describe 'GET #index' do
    subject { get :index }
    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end
    it 'should return a proper response' do
      articles = create_list(:article, 2)
      articles.reverse!
      subject
      articles.each_with_index do |article, index|
        expect(json_data[index]['attributes'])
          .to eq({
                   'title' => article.title,
                   'content' => article.content,
                   'slug' => article.slug
                 })
      end
    end

    it 'should return articles in the proper order' do
      old_article = create :article
      newer_article = create :article
      subject
      expect(json_data.first['id']).to eq newer_article.id.to_s
      expect(json_data.last['id']).to eq old_article.id.to_s
    end

    it 'should paginate results' do
      create_list(:article, 3)
      get :index, params: { page: 2, per_page: 1 }
      expect(json_data.length).to eq 1
      expected_article = Article.recent.second.id.to_s
      expect(json_data.first['id']).to eq(expected_article)
    end
  end

  describe 'GET #show' do
    let(:article) { create :article }
    subject { get :show, params: { id: article.id } }

    it 'should return success response' do
      subject
      expect(response).to have_http_status(:ok)
    end

    it 'should return proper json' do
      subject
      expect(json_data['attributes'])
        .to eq({
                 'title' => article.title,
                 'content' => article.content,
                 'slug' => article.slug
               })
    end
  end

  describe 'POST #create' do
    subject { post :create }
    context 'When unauthorized' do
      it_behaves_like 'forbidden_requests'
    end

    context 'When a invalid code is provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'When authorized' do
      let(:access_token) { create :access_token }
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }
      context 'When invalid parameters are provided' do
        let(:invalid_attributes) do
          {
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end

        subject { post :create, params: invalid_attributes }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error json' do
          subject
          expect(json['errors'])
            .to include({
                          'source' => { 'pointer' => '/data/attributes/title' },
                          'detail' => "can't be blank"
                        })
        end
      end

      context 'when successful request sent' do
        let(:access_token) { create :access_token }
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        let(:valid_attributes) do
          {
            'data' => {
              'attributes' => {
                'title' => 'Awesome article',
                'content' => 'Super content',
                'slug' => 'awesome-article'
              }
            }
          }
        end

        subject { post :create, params: valid_attributes }

        it 'should have 201 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'should have proper json body' do
          subject
          expect(json_data['attributes']).to include(
            valid_attributes['data']['attributes']
          )
        end

        it 'should create the article' do
          expect { subject }.to(change { Article.count }.by(1))
        end
      end
    end
  end

  describe 'PUT #update' do
    let(:user) { create :user }
    let(:article) { create(:article, user: user) }
    let(:access_token) { user.create_access_token }

    subject { put :update, params: { id: article.id } }

    context 'When unauthorized' do
      it_behaves_like 'forbidden_requests'
    end

    context 'When a invalid code is provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end

    context 'When authorized' do
      before { request.headers['authorization'] = "Bearer #{access_token.token}" }

      context 'When invalid parameters are provided' do
        let(:invalid_attributes) do
          {
            id: article.id,
            data: {
              attributes: {
                title: '',
                content: ''
              }
            }
          }
        end

        subject { put :update, params: invalid_attributes }

        it 'should return 422 status code' do
          subject
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it 'should return proper error json' do
          subject
          expect(json['errors'])
            .to include({
                          'source' => { 'pointer' => '/data/attributes/title' },
                          'detail' => "can't be blank"
                        })
        end
      end

      context 'when successful request sent' do
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        let(:valid_attributes) do
          {
            'id': article.id,
            'data' => {
              'attributes' => {
                'title' => 'Awesome article EDITED',
                'content' => 'Super content EDITED',
                'slug' => article.slug
              }
            }
          }
        end

        subject { put :update, params: valid_attributes }

        it 'should have 200 status code' do
          subject
          expect(response).to have_http_status(:created)
        end

        it 'should have proper json body' do
          subject
          expect(json_data['attributes']).to include(
            valid_attributes['data']['attributes']
          )
        end

        it 'should change the articles count' do
          expect { subject }.to(change { Article.count }.by(1))
        end
      end

      context 'when trying to update a not owned article' do
        let(:other_user) { create :user }
        let(:other_article) { create(:article, user: other_user) }
        subject { patch :update, params: { id: other_article.id } }
        before { request.headers['authorization'] = "Bearer #{access_token.token}" }

        it_behaves_like 'forbidden_requests'
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create :user }
    let(:article) { create(:article, user: user) }
    let(:access_token) { user.create_access_token }

    subject { put :update, params: { id: article.id } }

    context 'When unauthorized' do
      it_behaves_like 'forbidden_requests'
    end

    context 'When a invalid code is provided' do
      before { request.headers['authorization'] = 'Invalid token' }
      it_behaves_like 'forbidden_requests'
    end
  end
end
