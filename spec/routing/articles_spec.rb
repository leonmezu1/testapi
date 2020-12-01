require 'rails_helper'

describe 'articles routes' do
  it 'should route articles to index' do
    expect(get('/articles')).to route_to('articles#index')
  end

  it 'should route to a specific article' do
    expect(get('/articles/1')).to route_to('articles#show', id: '1')
  end
end
