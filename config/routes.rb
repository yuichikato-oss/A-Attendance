Rails.application.routes.draw do

  root to: 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users
end
