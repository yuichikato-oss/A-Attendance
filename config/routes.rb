Rails.application.routes.draw do

  root to: 'static_pages#top'
  get '/signup', to: 'users#new'
  
  # ログイン
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  
  resources :users do
    collection {post :import}
    
    member do
      get 'edit_basic_info'
      get 'edit_basic_info_admin'
      get 'working_list'
      patch 'update_basic_info'
      get 'attendance_log'
      get 'csv_export'
      get 'attendances/edit_one_month'
      patch 'attendances/update_one_month'
      
      get 'attendances/req_overtime'
      patch 'attendances/update_overtime'
    end
    resources :attendances, only: :update
  end
  resources :bases do
  end
end
