Rails.application.routes.draw do
  
  root to: 'static_pages#top'
  get '/signup', to: 'users#new'
  
end
