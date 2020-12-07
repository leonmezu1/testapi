Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :articles, only: %w[index show create update destroy]
  post 'login', to: 'access_tokens#create'
  delete 'logout', to: 'access_tokens#destroy'
end
