require 'rails_helper'

describe 'articles routes' do
  it 'should route articles to index' do
    expect(get('/articles')).to route_to('articles#index')
  end

  it 'should route to a specific article' do
    expect(get('/articles/1')).to route_to('articles#show', id: '1')
  end

  it 'shuld route to articles create' do
    expect(post('/articles')).to route_to('articles#create')
  end

  it 'should route to articles edit' do
    expect(put('/articles/1')).to route_to('articles#update', id: '1')
    expect(patch('/articles/1')).to route_to('articles#update', id: '1')
  end
end
